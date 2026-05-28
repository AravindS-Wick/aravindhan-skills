# PR Description Template

This is the template used to build the PR body for every feature. The subagent fills the `{{...}}` placeholders before opening the PR.

**Critical:** Do NOT add `Co-Authored-By:`, `Signed-off-by:`, "🤖 Generated with", or any AI attribution line. The description should read as if a human engineer wrote it.

---

```markdown
## Purpose

{{PURPOSE}}

## File Changes

{{FILE_CHANGES}}

## Work Done

{{WORK_DONE}}

## Use Cases

{{USE_CASES}}

## Splatter Zone (Blast Radius)

What this change could affect beyond the files in the diff:

{{SPLATTER_ZONE}}

## New Imports Required

{{NEW_IMPORTS}}

## Feature Flags

{{FEATURE_FLAGS}}

## Required Reviewers

{{REQUIRED_REVIEWERS}}

## Verification

- **Lint:** {{LINT_RESULTS}}
- **Tests:** {{TEST_RESULTS}}

## Notes for the Reviewer

- This PR is one slice of a larger multi-repo change. Other related PRs (if any) are listed above.
- Self-review has been posted as a comment on this PR. Please address the items in "Required Actions" before merging.
```

---

## Field guide — how to fill each placeholder

### `{{PURPOSE}}`
Plain-language explanation of why this feature exists. 2–4 sentences. Lead with the user-visible benefit if there is one; if it's internal, say what problem it solves for the team.

**Good:** "Adds JWT refresh-token rotation so users no longer get logged out after 15 minutes. Previously the access token expired with no refresh path; this introduces a refresh endpoint and rotates tokens on every use."

**Bad:** "Refactors auth code." (No why, no what.)

### `{{FILE_CHANGES}}`
Bulleted list. One line per file with a brief reason. Group by directory if there are more than ~8 files.

```
- `src/auth/refresh.ts` — new module implementing the rotate-on-use logic
- `src/auth/index.ts` — re-exports the refresh helpers
- `src/api/auth.controller.ts` — adds the POST /auth/refresh handler
- `src/auth/__tests__/refresh.test.ts` — covers happy path, expired token, reused refresh token
```

### `{{WORK_DONE}}`
Categorize the work. Use one or more of: `new feature`, `bug fix`, `refactor`, `performance`, `config`, `dependency upgrade`, `documentation`, `test coverage`. Add a sentence each on what was actually done.

### `{{USE_CASES}}`
When and by whom this code path will be hit. Concrete scenarios, not abstractions.

### `{{SPLATTER_ZONE}}` (this is what the user called the "spallter zone")
The blast radius. List anything that could be affected:
- callers of any function whose signature changed
- code paths that import the changed modules
- shared state, caches, or env vars touched
- migrations, DB schema changes, or any external service contract changes

If the change is genuinely isolated, say so: "Isolated — no external callers; only used internally within `src/auth/`."

### `{{NEW_IMPORTS}}`
New `import` lines added. Split between:
- **External packages** (with version): `jsonwebtoken@9.0.2`
- **Internal modules**: `./refresh`, `../utils/clock`

If none, write "None."

### `{{FEATURE_FLAGS}}`
Any feature flag, env var, or config toggle introduced to keep this change in check. Include the flag name, default value, and how to enable it.

```
- `AUTH_REFRESH_ENABLED` (default: `false`) — set to `true` to enable refresh-token rotation
```

If none, write "None — change is live on merge."

### `{{REQUIRED_REVIEWERS}}`
Auto-populated from `CODEOWNERS` for the changed paths, plus anyone the user named when invoking the skill. Format as `@username` for the platform.

If no CODEOWNERS exist and no one was named: "None auto-detected — add reviewers manually."

### `{{LINT_RESULTS}}` and `{{TEST_RESULTS}}`
Concrete summary from the gate run:

- Lint: `clean` or `2 warnings, 0 errors (see below)`
- Tests: `12 passed, 0 failed, 1 skipped (1.4s)`

If a gate was skipped (no config), write `skipped — no ESLint config detected`.
