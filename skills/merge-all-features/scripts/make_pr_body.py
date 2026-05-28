#!/usr/bin/env python3
"""
make_pr_body.py — assemble a PR body from the template + feature data.

Reads the template at references/pr-description-template.md (the markdown
block within it), substitutes {{PLACEHOLDER}} values from a feature JSON
provided on stdin, and prints the final PR body to stdout.

Usage:
    cat feature.json | python3 make_pr_body.py <skill-path>

Or:
    python3 make_pr_body.py <skill-path> < feature.json

The JSON must contain the keys: PURPOSE, FILE_CHANGES, WORK_DONE, USE_CASES,
SPLATTER_ZONE, NEW_IMPORTS, FEATURE_FLAGS, REQUIRED_REVIEWERS, LINT_RESULTS,
TEST_RESULTS. Missing keys are replaced with sensible defaults.
"""

import json
import re
import sys
from pathlib import Path


DEFAULTS = {
    "PURPOSE": "_(no purpose specified)_",
    "FILE_CHANGES": "_(no file changes listed)_",
    "WORK_DONE": "_(no description provided)_",
    "USE_CASES": "_(no use cases listed)_",
    "SPLATTER_ZONE": "Isolated change — no external callers identified.",
    "NEW_IMPORTS": "None.",
    "FEATURE_FLAGS": "None — change is live on merge.",
    "REQUIRED_REVIEWERS": "None auto-detected — add reviewers manually.",
    "LINT_RESULTS": "skipped",
    "TEST_RESULTS": "skipped",
}

# AI-attribution patterns to strip from any field before substitution.
FORBIDDEN_PATTERNS = [
    r"Co-Authored-By:.*",
    r"Co-Authored:.*",
    r"Co-Author:.*",
    r"Signed-off-by:.*[Cc]laude.*",
    r"🤖 Generated with.*",
    r"[Gg]enerated by [Cc]laude.*",
    r"[Gg]enerated with \[?[Cc]laude.*",
]


def extract_template(skill_path):
    """Pull the markdown block out of the template file."""
    template_path = Path(skill_path) / "references" / "pr-description-template.md"
    text = template_path.read_text()
    # Grab everything inside the first ```markdown ... ``` fence.
    m = re.search(r"```markdown\n(.*?)\n```", text, re.DOTALL)
    if not m:
        raise RuntimeError(f"could not find ```markdown block in {template_path}")
    return m.group(1)


def strip_forbidden(value):
    """Remove any AI-attribution trailers a careless template might include."""
    if not isinstance(value, str):
        return value
    for pattern in FORBIDDEN_PATTERNS:
        value = re.sub(pattern, "", value)
    return value.strip()


def render(template, data):
    out = template
    for key, default in DEFAULTS.items():
        value = data.get(key, default)
        value = strip_forbidden(value) or default
        out = out.replace("{{" + key + "}}", value)
    return out


def main():
    if len(sys.argv) < 2:
        print("usage: make_pr_body.py <skill-path>", file=sys.stderr)
        sys.exit(2)
    skill_path = sys.argv[1]
    raw = sys.stdin.read()
    if not raw.strip():
        print("make_pr_body.py: empty stdin", file=sys.stderr)
        sys.exit(2)
    data = json.loads(raw)
    template = extract_template(skill_path)
    body = render(template, data)
    # Final defensive sweep: strip any forbidden trailers that slipped through.
    body = strip_forbidden(body) or body
    print(body)


if __name__ == "__main__":
    main()
