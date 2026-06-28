---
name: pr-merge-tracker
description: Sequentially updates, polls, and merges open PRs, interactively pausing for conflict resolution or check failures.
---
# pr-merge-tracker

An automated, interactive script to merge open PRs one-by-one in chronological order (by PR number). It automatically keeps branches up-to-date with `main`, monitors status checks using a progressive delay, squash-merges passing branches, and pauses to allow manual fixes (conflict resolution, fixing lint/test failures) before resuming.

## Prerequisites

- Python 3.x
- `gh` CLI installed and authenticated (`gh auth status`)
- Git repository clean (unstaged/uncommitted changes should be stashed or committed before running)

## CLI Arguments

Run the script from the root of any git repository:

```bash
python3 /Users/aravindhan/.gemini/config/skills/pr-merge-tracker/scripts/merge_prs.py [options]
```

- `--resolve-files <paths>`: Comma-separated relative paths of index/export files to auto-resolve conflict markers (e.g. `packages/react/src/index.ts,packages/vue/src/index.ts,src/index.scss`).
- `--dry-run`: Simulation mode. Lists the PRs that would be processed, checks their status, but performs no updates or merges.
- `--interactive`: Ask confirmation before updating or merging each PR (enabled by default). Use `--non-interactive` to disable.

## Workflow

1. **Prerequisite Check**: Validates `gh` auth status (unsetting `GITHUB_TOKEN` from the agent env if present to prevent override).
2. **Fetch PRs**: Retrieves all open PRs in the repository, sorted by number ascending (creation order).
3. **Loop PRs**: For each PR:
   - Check/Update branch: Runs `gh pr update-branch` to catch up with `main`.
   - If a conflict occurs, attempts local merge + auto-resolution of files specified in `--resolve-files`.
   - If conflicts remain in other files, pauses execution and prompts the agent/user to resolve the conflict, push, and press Enter to retry.
   - Polls CI checks: Sleeps **60 seconds**, checks status. If not complete, sleeps **20 seconds**, checks. If not complete, sleeps **30 seconds**, checks. If checks are still running, polls every 15 seconds until complete.
   - If checks fail, pauses and asks the agent/user to fix the failure, push, and press Enter to retry.
   - Squash-merges the PR once all checks pass.
