---
name: pr-review-triage
description: Monitor a Slack channel for new PR review requests, perform code reviews scoped to team-owned files, post findings to Slack threads, and approve or comment. Requires --channel, --team, and --repo arguments. Designed to run on /loop.
---
# PR Review Triage

## Overview

Checks a Slack channel for unreviewed PRs and performs code reviews scoped to a team's owned files. For each unreviewed PR: acknowledge in Slack, fetch the diff, scope the review to team-owned files, post findings to the thread, then ask for next steps. After approval, simply confirm "Approved." in the thread — nothing more.

Designed to run continuously via `/loop`.

## Required Arguments

| Argument    | Description                                                                 |
|-------------|-----------------------------------------------------------------------------|
| `--channel` | Slack channel name or ID to monitor (e.g. `#my-team-prs` or `C09DQD6H1TP`) |
| `--team`    | GitHub team slug for file ownership via `batch/owners show` (e.g. `mailchimp-monolith/platform-experience_delivery_platform`) |
| `--repo`    | Default GitHub repo for `gh pr` commands (e.g. `mailchimp-monolith/mailchimp`) |

All arguments are required. The skill does not prompt interactively.

## Steps

### 1. Parse and validate arguments

- Extract `--channel`, `--team`, and `--repo` from the invocation arguments.
- If `--channel` is a name (starts with `#`), resolve it to a channel ID using `slack_search_channels`.
- If any argument is missing, print usage and exit:
  > Usage: /pr-review-triage --channel <channel> --team <team-slug> --repo <owner/repo>

### 2. Read the channel for unreviewed PRs

- Use `slack_read_channel` on the resolved channel ID, limit 20–30 messages.
- For each PR message, **skip it** if any of the following are true:
  - The Slack message has an `approve` reaction
  - The Slack message has a `merged-intensifies` or similar merged reaction
  - A previous loop iteration already reviewed it (check thread for a prior review post from the authenticated gh user: `gh api user --jq .login`)
- For remaining candidates, check GitHub state in parallel:
  - `gh pr view <number> --repo <owner/repo> --json state,mergedAt,reviews`
  - Skip if `state` is MERGED or CLOSED
  - Skip if the authenticated gh user has already submitted a review

### 3. Determine repo

PR links may reference repos other than `--repo`. Extract the owner/repo from the PR URL when it differs from the default. Use the extracted repo for all `gh` commands for that PR.

### 4. Acknowledge in Slack thread

Immediately reply to the PR's Slack thread:
> Starting a review of this PR now.

Do this **before** fetching the diff so the author knows it's being picked up.

### 5. Fetch PR context

Run in parallel:
- `gh pr view <number> --repo <owner/repo> --json title,body,files,additions,deletions`
- `gh pr diff <number> --repo <owner/repo>`

### 6. Scope review to team-owned files

Run `batch/owners show` on each changed file path and filter to files matching `--team`. Explicitly note which files are deferred to other teams.

If no changed files are owned by `--team`, skip the review and post to the thread:
> No files in this PR are owned by `<team>`. Skipping review.

### 7. Check relevant agent rules

Before writing the review, consult applicable rules from `.agent/rules/`:
- **Always check:** `.agent/rules/flag-usage.mdc`, `.agent/rules/flag-config.mdc`
- **For PHP changes:** `.agent/rules/security-csrf.mdc`, `.agent/rules/security-sqli.mdc`, `.agent/rules/security-xss.mdc`, `.agent/rules/security-cmdexe.mdc`
- **For JS/React changes:** `.agent/rules/security-xss.mdc`
- **For Avesta views:** `docs/avesta-templating.md`
- **For tests:** `.agent/rules/tests-phpunit.mdc` or `.agent/rules/tests-avesta.mdc`

### 8. Write the review

Cover these areas, being concise:

**Code Quality**
- Correctness of the change
- Consistency with existing patterns
- Unnecessary complexity or duplication
- Non-standard usage (e.g. flag API, template syntax)

**Security**
- XSS, CSRF, SQLi, command injection per `.agent/rules/security-*.mdc`
- If none apply, state "No concerns."

**Test Coverage**
- Are tests present and sufficient?
- Are there paths or branches not covered?
- Flag if tests were removed without explanation

**Logging / Observability**
- New code paths that lack logging
- Missing error handling instrumentation

**Flag usage (if flags.ini is changed)**
- Flag starts at `enabled = 0.00` — yes or no
- Flag definition and first usage are in the **same PR** — flag the revert risk:
  > Including a new flag definition in the same PR as its first usage creates a non-atomic revert risk. If only the usage code or the flag definition is reverted, the codebase can be left inconsistent. Best practice is to land the flag in a prior PR.

**Scope note**
- If not all files are team-owned, explicitly state which files the review covers and which are deferred to the owning team.

### 9. Post review summary to Slack thread

Post the findings as a single Slack message in the PR's thread. Use bold (`*text*`) for section headers. Keep it scannable — bullet points, not paragraphs.

End with: "How would you like to proceed — approve, request changes, or comment only?"

### 10. Handle next steps

Wait for the user's instruction:

**"Approve"**
1. Run: `gh pr review <number> --repo <owner/repo> --approve --body "<findings summary>"`
2. Verify the approval registered: `gh pr view <number> --json reviews`
3. Post to Slack thread: "Approved." — nothing else.

**"Request changes"**
1. Run: `gh pr review <number> --repo <owner/repo> --request-changes --body "<specific items to address>"`
2. Post to Slack thread: "Requested changes. See the PR for details."

**"Comment only"**
1. Run: `gh pr review <number> --repo <owner/repo> --comment --body "<findings>"`
2. Post to Slack thread: "Posted findings as a comment on the PR."

**After any action:** Move to the next unreviewed PR if there are more. Otherwise stop.

## Key Rules

- **Never approve or comment on a PR without explicit user instruction** — always ask first
- **After approving, say "Approved." and stop** — do not add asks or follow-ups in the same message
- **Scope reviews to team-owned files** — note which files are deferred to other teams
- **Always acknowledge the thread before starting** — authors should know it's being picked up
- **Run in parallel where possible** — fetch multiple PRs' states at once, fetch diff and body together

## Loop behavior (`/loop`)

When run via `/loop`, after processing all current unreviewed PRs:
- State how many PRs were reviewed or skipped
- Wait for the next interval
- On next run, re-check the channel for new PRs posted since the last check (most recent messages first)
