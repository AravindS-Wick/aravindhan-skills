#!/usr/bin/env python3
"""
group_features.py — heuristic grouping of uncommitted changes into features.

Reads `git status --porcelain=v1 -uall` and `git diff HEAD`, then emits a
JSON plan of features grouped by intent. The output is a starting point —
the orchestrator should always show it to the user for confirmation.

Usage:
    python3 group_features.py <repo-path>

Output: JSON to stdout, schema documented in references/feature-grouping.md.
"""

import json
import os
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path


def run(cmd, cwd):
    result = subprocess.run(
        cmd, cwd=cwd, capture_output=True, text=True, check=False
    )
    return result.stdout, result.stderr, result.returncode


def list_changes(repo):
    out, _, _ = run(["git", "status", "--porcelain=v1", "-uall"], repo)
    files = []
    for line in out.splitlines():
        if not line.strip():
            continue
        # Porcelain v1: XY <path> or XY <orig> -> <path> for renames
        status = line[:2]
        rest = line[3:]
        if " -> " in rest:
            rest = rest.split(" -> ", 1)[1]
        files.append({"status": status.strip(), "path": rest.strip()})
    return files


def module_root(path):
    """Best-effort 'module' for clustering. src/auth/foo.ts -> src/auth"""
    p = Path(path)
    parts = p.parts
    if len(parts) <= 1:
        return parts[0] if parts else ""
    # Common patterns: src/<module>/..., packages/<pkg>/...
    if parts[0] in ("src", "lib", "app") and len(parts) >= 2:
        return "/".join(parts[:2])
    if parts[0] == "packages" and len(parts) >= 3:
        return "/".join(parts[:3])
    # Top-level files (README.md, package.json, etc.) — each is its own group
    if len(parts) == 1:
        return parts[0]
    return parts[0]


CONFIG_FILES = {
    "package.json", "tsconfig.json", ".eslintrc", ".eslintrc.js",
    ".eslintrc.json", "jest.config.js", "jest.config.ts", "tailwind.config.js",
    "vite.config.ts", "webpack.config.js", ".prettierrc",
}
LOCK_FILES = {
    "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "Cargo.lock", "go.sum",
}
GENERATED_DIRS = {"dist", "build", "coverage", ".next", "node_modules", "out"}


def is_generated(path):
    parts = Path(path).parts
    return any(part in GENERATED_DIRS for part in parts)


def is_test(path):
    return ("__tests__" in path or ".test." in path or ".spec." in path)


def source_for_test(test_path):
    """Map src/__tests__/foo.test.ts -> src/foo.ts (best effort)."""
    p = Path(test_path)
    name = p.name
    name = re.sub(r"\.(test|spec)\.", ".", name)
    parts = list(p.parts)
    if "__tests__" in parts:
        parts.remove("__tests__")
    parts[-1] = name
    return str(Path(*parts))


def _added_lines(repo, files):
    """
    Yield 'added' lines (i.e. new content) across the given files.

    For tracked files with modifications, this is `+` lines from `git diff HEAD`.
    For untracked files, the entire file content is new — read it directly.
    """
    paths = [f for f in files if not is_generated(f)]
    if not paths:
        return

    # Figure out which files are tracked vs untracked.
    tracked = []
    untracked = []
    for p in paths:
        _, _, rc = run(["git", "ls-files", "--error-unmatch", p], repo)
        if rc == 0:
            tracked.append(p)
        else:
            untracked.append(p)

    # Tracked: diff HEAD, take + lines (skip +++).
    if tracked:
        out, _, _ = run(["git", "diff", "HEAD", "--", *tracked], repo)
        for line in out.splitlines():
            if line.startswith("+") and not line.startswith("+++"):
                yield line[1:]

    # Untracked: whole file is added.
    for p in untracked:
        full = os.path.join(repo, p)
        try:
            with open(full, "r", encoding="utf-8", errors="replace") as fh:
                for line in fh:
                    yield line.rstrip("\n")
        except (OSError, IsADirectoryError):
            continue


def get_new_imports(repo, files):
    """Scan added content for new import lines among the given files."""
    imports = set()
    for line in _added_lines(repo, files):
        stripped = line.strip()
        m = re.match(r"^import\s+(?:.+?\s+from\s+)?['\"]([^'\"]+)['\"]", stripped)
        if m:
            imports.add(m.group(1))
        m = re.match(r"^const\s+.+?=\s*require\(['\"]([^'\"]+)['\"]\)", stripped)
        if m:
            imports.add(m.group(1))
    return sorted(imports)


def get_new_flags(repo, files):
    """Scan added content for likely feature flag introductions."""
    flags = set()
    for line in _added_lines(repo, files):
        for m in re.finditer(
            r"\b(?:process\.env|env)\.([A-Z][A-Z0-9_]*(?:_(?:ENABLED|FLAG|FEATURE|TOGGLE))?)",
            line,
        ):
            flags.add(m.group(1))
    return sorted(flags)


def group(repo):
    repo = os.path.abspath(repo)
    files = list_changes(repo)
    if not files:
        return {"repo": repo, "features": []}

    # Drop generated files; surface them separately for the orchestrator to warn about.
    generated = [f["path"] for f in files if is_generated(f["path"])]
    files = [f for f in files if not is_generated(f["path"])]

    # Bucket by module_root, but pull test files to their source's bucket.
    buckets = defaultdict(list)
    deferred_tests = []
    for f in files:
        path = f["path"]
        if is_test(path):
            deferred_tests.append(path)
            continue
        if path in LOCK_FILES or Path(path).name in LOCK_FILES:
            buckets["__lockfile__"].append(path)
            continue
        if Path(path).name in CONFIG_FILES:
            buckets["__config__"].append(path)
            continue
        buckets[module_root(path)].append(path)

    # Place tests with their source module if we can find it.
    for test_path in deferred_tests:
        src = source_for_test(test_path)
        placed = False
        for key, paths in buckets.items():
            if src in paths or any(src.startswith(module_root(p) + "/") for p in paths):
                buckets[key].append(test_path)
                placed = True
                break
        if not placed:
            buckets[module_root(test_path)].append(test_path)

    # Build feature objects.
    features = []
    order = 0

    # Config and lockfile get early order numbers if present.
    for special, type_, scope in [
        ("__config__", "chore", "config"),
        ("__lockfile__", "build", "deps"),
    ]:
        if special in buckets:
            order += 1
            paths = sorted(buckets.pop(special))
            features.append({
                "name": f"{type_}-{scope}-update",
                "type": type_,
                "scope": scope,
                "summary": f"update {scope} files",
                "files": paths,
                "order": order,
                "imports_introduced": get_new_imports(repo, paths),
                "flags_introduced": get_new_flags(repo, paths),
                "splatter_zone": [
                    "config/dep change — verify CI still passes and no consumer scripts broke",
                ],
            })

    # Remaining buckets become features.
    for key in sorted(buckets.keys()):
        paths = sorted(buckets[key])
        if not paths:
            continue
        order += 1
        # Derive name + scope from the bucket key.
        scope_parts = Path(key).parts
        scope = scope_parts[-1] if scope_parts else "misc"
        # Type heuristic: all tests? -> "test". Mostly README/docs? -> "docs".
        if all(is_test(p) for p in paths):
            type_ = "test"
        elif all(p.endswith(".md") for p in paths):
            type_ = "docs"
        else:
            type_ = "feat"
        features.append({
            "name": f"{type_}-{scope}",
            "type": type_,
            "scope": scope,
            "summary": f"changes under {key}",
            "files": paths,
            "order": order,
            "imports_introduced": get_new_imports(repo, paths),
            "flags_introduced": get_new_flags(repo, paths),
            "splatter_zone": [
                f"callers and importers of files in {key} — verify with grep",
            ],
        })

    result = {"repo": repo, "features": features}
    if generated:
        result["warnings"] = [
            f"generated/build artifacts in staging: {sorted(generated)} — do not commit these",
        ]
    return result


def main():
    if len(sys.argv) < 2:
        print("usage: group_features.py <repo-path>", file=sys.stderr)
        sys.exit(2)
    plan = group(sys.argv[1])
    print(json.dumps(plan, indent=2))


if __name__ == "__main__":
    main()
