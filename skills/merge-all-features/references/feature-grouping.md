# Feature Grouping Rubric

How to take a pile of uncommitted changes in a repo and split them into discrete features for separate commits/PRs.

The default is **one feature per commit per PR**. Only merge features into a single commit when:
- The user explicitly says "lump features X and Y together"
- Or the changes are inseparable (e.g., a function signature change and its single caller in the same file)

## Inputs

For each repo, you have:
- `git status --porcelain=v1 -uall` — list of changed/added/deleted/untracked files
- `git diff HEAD` — the actual diff content
- Any user hints from the conversation (file names, module names, intent words)

## Algorithm

Apply in this order. Stop merging at the first rule that says "keep separate".

### 1. User hints win
If the user named features explicitly (e.g., "the auth refresh and the payment fix"), use those names and assign files to them by relevance.

### 2. Group by intent, not by directory
Files in the same directory aren't automatically the same feature. A `src/auth/login.ts` change to fix a typo and an `src/auth/refresh.ts` new file are two features even though they share a directory.

### 3. Test files follow their source
`src/foo.ts` + `src/__tests__/foo.test.ts` + `src/foo.spec.ts` → same feature.

### 4. Lockfile rule
`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Cargo.lock`, `go.sum` — these go with the feature that bumped the corresponding manifest (`package.json`, `Cargo.toml`, etc.). If multiple features touched dependencies, group the lockfile changes with whichever feature introduced them first (lowest order number).

### 5. Config files
`tsconfig.json`, `.eslintrc`, `jest.config.*`, `tailwind.config.*` — usually their own feature unless they were obviously changed to enable a specific feature's code (e.g., a new path mapping added because a new module needs it).

### 6. Generated files
`dist/`, `build/`, `coverage/`, `.next/`, etc. — should NOT be committed. Flag for the user; do not silently include.

### 7. Diff-coupling check
Read the actual diff. If a new export in file A is imported by a new line in file B, they're the same feature regardless of directory. Build an import-graph over just the diff.

### 8. Hunk-by-hunk fallback
If a single file has multiple unrelated changes (e.g., README.md has a typo fix AND a new section about a new feature), split by hunk. Use `git add -p` semantics — stage hunks separately for separate commits.

## Output shape

```json
{
  "repo": "/path/to/repo",
  "features": [
    {
      "name": "add-jwt-refresh",
      "type": "feat",
      "scope": "auth",
      "summary": "implement JWT refresh-token rotation",
      "files": [
        "src/auth/refresh.ts",
        "src/auth/index.ts",
        "src/auth/__tests__/refresh.test.ts"
      ],
      "order": 1,
      "imports_introduced": [
        "jsonwebtoken@9.0.2 (external)",
        "./refresh (internal, from src/auth/index.ts)"
      ],
      "flags_introduced": [
        "AUTH_REFRESH_ENABLED (default: false)"
      ],
      "splatter_zone": [
        "src/api/auth.controller.ts — adds new POST handler; existing handlers unchanged",
        "No other consumers — refresh.ts is new and only exported via index.ts"
      ]
    }
  ]
}
```

## Ordering features (the `order` field)

Commit in dependency order — anything that gets imported should be committed before its importer. Rough hierarchy:

1. Types / interfaces / schema definitions
2. Constants, configs, env additions
3. Core libs and utilities
4. Modules that use the core libs
5. API / controller layer
6. Tests
7. Documentation, READMEs, changelogs

If two features have no dependency between them, order by smallest-first (smaller features merge faster, lower review fatigue).

## When in doubt, ask

If the grouping isn't obvious, the orchestrator should show the user the proposed grouping and ask to adjust BEFORE spawning subagents. A 10-second confirmation is worth more than a wrongly-grouped PR.
