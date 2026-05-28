---
name: pr-monitor
description: Monitor PR CI checks with intelligent flaky test detection and optional auto-rerun. Use when the user wants to watch a PR, detect flaky tests, or automatically rerun failed CI. Invoke with /pr-monitor to monitor current PR or /pr-monitor <pr-number> for specific PR.
disable-model-invocation: true
---

# Monitor PR CI with Flaky Test Detection & Auto-Rerun

Monitors a GitHub PR's CI checks and automatically:
1. **Detects flaky/unrelated test failures** by analyzing test output
2. **Auto-reruns CI** when failures appear unrelated to code changes
3. Converts from draft to ready for review (if draft)
4. Adds a team as reviewers when all checks pass successfully

## Workflow

### 1. Gather inputs

- **PR number**: from command arg, current branch (`gh pr view --json number`), or ask user
- **Team**: check in order — user's message (`@org/team-name`), `$MC_PR_MONITOR_TEAM` env var, ask user
- **Flaky rerun mode**: check `$FLAKY_RERUN_MODE` (default: `prompt`)
  - `auto` — rerun CI automatically when flakiness detected
  - `prompt` — ask user before rerunning (default)
  - `off` — report only, never rerun

### 2. Deploy the monitoring script

Substitute `PR_NUMBER`, `TEAM`, and `FLAKY_RERUN_MODE` into `scripts/monitor.sh`, write to `/tmp/monitor_pr_${PR_NUMBER}.sh`, make executable, and run in background:

```bash
export PR_NUMBER=<number>
export TEAM=<team>
export FLAKY_RERUN_MODE=<mode>

sed -e "s/\${PR_NUMBER}/${PR_NUMBER}/g" \
    -e "s/\${TEAM}/${TEAM}/g" \
    -e "s/\${FLAKY_RERUN_MODE}/${FLAKY_RERUN_MODE}/g" \
    "$(dirname "$0")/scripts/monitor.sh" > /tmp/monitor_pr_${PR_NUMBER}.sh

chmod +x /tmp/monitor_pr_${PR_NUMBER}.sh
nohup /tmp/monitor_pr_${PR_NUMBER}.sh >> /tmp/pr_monitor.log 2>&1 &
MONITOR_PID=$!
```

Confirm to the user:
```
✅ Monitoring PR #${PR_NUMBER} (PID: ${MONITOR_PID})
🤖 Flaky rerun mode: ${FLAKY_RERUN_MODE}
📊 View progress: tail -f /tmp/pr_monitor.log
```

### 3. Handle exit code 2 (flaky detected, prompt mode)

If the script exits with code 2, the user needs to decide whether to rerun. Explain why the failure looks flaky (e.g. "Test file `LoginUserCreationServiceTest.php` wasn't modified in your PR") and ask: "Would you like me to rerun CI?" If yes, run `gh run rerun --failed` and restart the monitor.

## What the script does (see `scripts/monitor.sh`)

- Polls PR status every 60 seconds (2 hour timeout)
- On failure: checks if the failing test file was changed in the PR, or matches known flaky patterns (DB connection errors, infrastructure timeouts)
- On success: converts draft → ready, adds team as reviewers
- Max 2 auto-rerun attempts

## Flaky patterns detected

- `SQLSTATE[HY000] [2002] No such file or directory` — DB not available in CI
- `MC::loginDB()` / `Avesta_Db_Exception_NoSuchFileOrDirectory` — same
- Failing test file not present in PR diff
- Check name matches `timeout`, `infrastructure`, or `network`

## Configuration

```bash
export MC_PR_MONITOR_TEAM="mailchimp-monolith/platform-service_delivery"
export FLAKY_RERUN_MODE="auto"   # auto | prompt | off
```

## Checking progress

```bash
tail -f /tmp/pr_monitor.log      # Live log
gh pr checks ${PR_NUMBER}        # Current CI status
gh run rerun --failed            # Manual rerun
```

## Requirements

- `gh` CLI authenticated
- `jq` installed
- PR must be open
- Permission to rerun workflows
