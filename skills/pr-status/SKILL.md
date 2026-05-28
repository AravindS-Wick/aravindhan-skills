---
name: pr-status
description: List open PRs for the current repository with merge readiness classification (Ready to merge / Awaiting approval / Blocked), CI status, approval state, conflict detection, and rebase guidance. Use when the user runs /pr-status, asks to see their open PRs, wants to check merge readiness, or asks which PRs need attention.
---
# PR Status

Surface an accurate, actionable snapshot of the user's open PRs for the current repository. Classifies each PR by merge readiness based on approval state, CI results, and conflict detection. Recommends rebase where it would help.

**Trigger:** User invokes `/pr-status` or asks to see open PRs, check PR status, review merge readiness, or which PRs need attention.

**Default scope:** PRs authored by `@me` in the current repo (`--author @me`). User can override with `author=login` or `repo=owner/repo`.

---

## Prerequisites

- Must be in a git repository: `git rev-parse --is-inside-work-tree`
- `gh` CLI must be authenticated: `gh auth status`
- **GitHub Enterprise:** set `GH_HOST=github.your-company.com` before `gh` commands (or export it):
  ```bash
  export GH_HOST=github.your-company.com
  ```
  This environment is on github.your-company.com — always set `GH_HOST` here unless explicitly told otherwise.

If not in a git repo or `gh` is not authenticated, show the appropriate error from **Error Handling** and exit.

---

## Step 1 — Validate environment

```bash
git rev-parse --is-inside-work-tree 2>/dev/null || { echo "NOT_GIT_REPO"; exit 1; }
GH_HOST=github.your-company.com gh auth status 2>&1| grep -q "Logged in" || { echo "GH_NOT_AUTH"; exit 1; }
```

---

## Step 2 — Fetch open PRs

```bash
export GH_HOST=github.your-company.com

gh pr list --author @me --state open \
  --json number,title,url,headRefName,baseRefName,reviewDecision,\
statusCheckRollup,mergeable,mergeStateStatus,isDraft,createdAt,updatedAt
```

- If `--repo` override provided by user, add `--repo owner/repo`.
- Filter out drafts (`isDraft == true`) from results.
- If result is empty array, show **No open PRs** message and exit.

---

## Step 3 — Classify each PR

For each non-draft PR:

### 3a. Approval

| `reviewDecision` | Meaning |
|-----------------|---------|
| `APPROVED` | Approved — no approval blocker |
| `REVIEW_REQUIRED` | Needs at least one approval |
| `CHANGES_REQUESTED` | Reviewer requested changes |
| `""` (empty) | No reviewers assigned yet — treat as REVIEW_REQUIRED |

### 3b. CI status

Iterate `statusCheckRollup`. Each entry is one of:

- **CheckRun** (GitHub Actions): has `conclusion` field — `SUCCESS`, `FAILURE`, `CANCELLED`, `SKIPPED`, `TIMED_OUT`, `ACTION_REQUIRED`, `NEUTRAL`; and `status` field.
- **StatusContext** (Jenkins/IBP): has `state` field — `SUCCESS`, `FAILURE`, `PENDING`, `ERROR`.

**Failing states:** `FAILURE`, `ERROR`, `TIMED_OUT`, `ACTION_REQUIRED` on non-skipped checks.

**Critical checks** (any failure here = CI blocked):
- `continuous-integration/jenkins/pr-merge`
- `pr-merge`
- `[IBP] Avesta Test Suite (8.x)`
- `[IBP] PHPUnit Tests (8.x)`
- `[IBP] Phan Static Analysis`
- `[IBP] Changes Have CODEOWNERS`
- `[IBP] Jira Commit Checker`
- `[IBP] Stamp Validation`
- `[IBP] Validate Configs`
- `complete_test_run` (Playwright gate)

**Pending checks:** any check with `status` = `IN_PROGRESS` or `QUEUED`, or `state` = `PENDING` — note as "CI pending" but don't block classification yet.

**CI result:**
- `CI_GREEN` — no failures on critical checks, no pending
- `CI_PENDING` — checks still running
- `CI_BLOCKED` — one or more critical checks failed

### 3c. Merge conflicts

| `mergeable` | Meaning |
|-------------|---------|
| `MERGEABLE` | No conflicts |
| `CONFLICTING` | Merge conflicts exist; rebase/resolve required |
| `UNKNOWN` | GitHub hasn't computed yet; note as unknown |

`mergeStateStatus` gives composite state:
- `CLEAN` — ready
- `BEHIND` — branch behind base; rebase recommended
- `BLOCKED` — branch protection rules blocking
- `DIRTY` — conflicts
- `UNSTABLE` — CI failing
- `UNKNOWN` — not yet computed

### 3d. Classification

| Classification | Criteria |
|---------------|----------|
| **Ready to merge** | `reviewDecision == APPROVED` AND `CI_GREEN` AND `mergeable != CONFLICTING` AND `mergeStateStatus != BEHIND` |
| **Approved, CI pending** | `reviewDecision == APPROVED` AND `CI_PENDING` AND `mergeable != CONFLICTING` — classify as **Ready to merge** with a "CI pending" note |
| **Awaiting approval** | Not approved AND (`CI_GREEN` OR `CI_PENDING`) AND `mergeable != CONFLICTING` |
| **Blocked** | Any: `mergeable == CONFLICTING` OR `CI_BLOCKED` OR (`reviewDecision == CHANGES_REQUESTED`) OR (`APPROVED` but `mergeStateStatus == BLOCKED`) |

If a PR is `APPROVED` but `mergeStateStatus == BEHIND`, classify as **Ready to merge** with a rebase note.

### 3e. Rebase assessment

Recommend rebase when:
1. `mergeable == CONFLICTING` → "Rebase needed — merge conflicts"
2. `mergeStateStatus == BEHIND` → "Branch is behind `main`; rebase recommended"
3. `CI_BLOCKED` AND `mergeStateStatus == BEHIND` → "Rebase may resolve failing checks (branch behind main)"

Do **not** recommend rebase for:
- Failures caused by files the PR itself modified (fix the code)
- CODEOWNERS or Jira compliance failures (process issue, not stale branch)
- Playwright/infra failures with no divergence from main

---

## Step 4 — Format output

Output a single markdown table sorted by status priority (Ready → Awaiting → Blocked), then most recently updated first within each group.

```markdown
# My Open PRs

| # | Title | Approval | CI | Notes |
|---|-------|----------|----|-------|
| [#{number}]({url}) | {title} | ✅ Approved | ✅ Green | |
| [#{number}]({url}) | {title} | ⏳ Review required | ✅ Green | |
| [#{number}]({url}) | {title} | ⏳ Review required | 🔄 Pending | |
| [#{number}]({url}) | {title} | ❌ Changes requested | ✅ Green | |
| [#{number}]({url}) | {title} | ✅ Approved | 🔴 `[IBP] Avesta Test Suite` failing | ⚠️ Rebase (behind main) |
```

**Column values:**

Approval column:
- `✅ Approved`
- `⏳ Review required`
- `❌ Changes requested`
- `⏳ No reviewer` (empty reviewDecision)

CI column:
- `✅ Green`
- `🔄 Pending`
- `🔴 {failing_check_name}` — name of first critical failing check; if multiple, list all separated by `, `

Notes column (only populated when relevant):
- `⚠️ Rebase (behind main)` — when `mergeStateStatus == BEHIND`
- `⚠️ Merge conflicts` — when `mergeable == CONFLICTING`
- `❓ Merge status unknown` — when `mergeable == UNKNOWN`

Omit the Notes column entirely if no PR has a note.

If there are no open PRs, output: `No open PRs in this repository for @me.`

---

## Step 5 — Verbose mode (optional)

If user invokes `/pr-status --verbose` or asks for failing check details, append a CI detail table after the main table for each blocked PR:

```markdown
## CI Details — #{number} {title}

| Check | Status | Link |
|-------|--------|------|
| `[IBP] Avesta Test Suite (8.x)` | 🔴 FAILURE | [view]({targetUrl}) |
| `complete_test_run` | 🔴 FAILURE | [view]({detailsUrl}) |
| `Jest tests with Nx Agents` | 🔄 PENDING | [view]({detailsUrl}) |
| `[IBP] PHPUnit Tests (8.x)` | ✅ SUCCESS | |
```

**Link field:** Use `targetUrl` for `StatusContext` entries (Jenkins/IBP checks) and `detailsUrl` for `CheckRun` entries (GitHub Actions). Omit the link cell if the field is absent.

Only include failing and pending checks in the default verbose view; add a `--all-checks` note if user wants all checks listed.

---

## Error Handling

### Not a git repository
```
❌ Not in a git repository.

/pr-status works from the root of a git repo (e.g. /workspace/mailchimp).
```

### gh not authenticated
```
❌ GitHub CLI not authenticated.

Run: gh auth login --hostname github.your-company.com
```

### No open PRs
```
No open PRs in this repository for @me.
```

### Partial data (mergeable UNKNOWN, checks still running)
- Proceed with available data; note in output: "Merge/rebase status unavailable for some PRs (UNKNOWN)"
- Don't block output; show best-effort classification

---

## Parameters / knobs

| Knob | Default | Effect |
|------|---------|--------|
| `--verbose` / `verbose` | off | Show per-PR failing check names |
| `author=login` | `@me` | Show another user's PRs |
| `repo=owner/repo` | current repo | Scope to a different repo |
| `--all` | off | Include drafts |

---

## Integration

- Complements `/work-on` (ticket-focused context; `/pr-status` is PR-snapshot)
- Complements `/pr-monitor` (live CI polling for one PR; `/pr-status` is a point-in-time snapshot across all open PRs)
- Use `/pr-request-review` after identifying PRs awaiting approval

---

## Example output

```markdown
# My Open PRs

| # | Title | Approval | CI | Notes |
|---|-------|----------|----|-------|
| [#313602](https://github.your-company.com/mailchimp-monolith/mailchimp/pull/313602) | [XP-6425] Improve work-on skill: auto-discover transition screen fields | ✅ Approved | ✅ Green | |
| [#313400](https://github.your-company.com/mailchimp-monolith/mailchimp/pull/313400) | [XP-5916] Remove skipped Jest tests (Batch 2) | ⏳ Review required | ✅ Green | |
| [#313380](https://github.your-company.com/mailchimp-monolith/mailchimp/pull/313380) | [XP-5929] Remove skipped tests from Main/Campaigns | ⏳ Review required | 🔄 Pending | |
| [#313200](https://github.your-company.com/mailchimp-monolith/mailchimp/pull/313200) | [XP-6090] Add flag tags | ✅ Approved | 🔴 `continuous-integration/jenkins/pr-merge` | ⚠️ Merge conflicts |
```

---

## Changelog

- **v1.1** — Table-based output format; verbose mode uses check table
- **v1.0** — Initial skill: approval, CI, conflict, rebase classification; grouped output; verbose mode
