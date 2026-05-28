# Monitor PR CI Skill

Automatically monitors GitHub PR CI checks and when all checks pass:
1. Converts PR from draft to ready for review (if draft)
2. Adds your team as reviewers

## What it does

- ✅ Watches PR CI checks in the background
- ✅ When **ALL** checks pass:
  - Converts from draft to ready (if draft)
  - Adds your team as reviewers
- ❌ Exits silently if any check fails (doesn't convert or add reviewers)
- ⏱️ Exits silently if checks take longer than 2 hours (doesn't convert or add reviewers)

## How to use

Just ask Cursor to monitor a PR:

```
"Monitor this PR and add my team as reviewers when CI passes"
"Watch PR #12345 for CI completion and request reviews"
"Add reviewers when the CI finishes on this PR"
"Convert from draft and add reviewers when it's green"
```

## Team configuration

The skill needs to know which team to add as reviewers. You can specify it in three ways:

### 1. Mention team in your request (recommended)
```
"Monitor this PR and add @mailchimp-monolith/frontend as reviewers when done"
"Watch PR #12345 and request reviews from @mailchimp-monolith/ads-team"
```

### 2. Set personal environment variable
Add to your `.zshrc` or `.bashrc`:
```bash
export MC_PR_MONITOR_TEAM="@mailchimp-monolith/platform-service_delivery"
```

### 3. Let Cursor ask you
If you don't specify, Cursor will ask which team to add as reviewers.

### Other settings
- **Check interval**: Every 60 seconds
- **Timeout**: 2 hours

## What happens

1. Cursor creates a monitoring script for your PR
2. Runs it in the background
3. Script checks CI status every minute
4. **Only when ALL checks pass:**
   - Converts PR from draft to ready (if draft)
   - Adds your team as reviewers on the PR
5. If **any** check fails or timeout, it exits silently without converting or adding reviewers

## Checking progress

```bash
# View all monitor progress
tail -f /tmp/pr_monitor.log

# Check current CI status
gh pr checks <PR_NUMBER>
```

## Requirements

- `gh` CLI must be authenticated (run `gh auth login` if needed)
- You must have permission to comment on the PR
- PR must be open

## Examples

**Monitor current PR:**
```
You: "Add my team as reviewers when CI passes on this PR"
Cursor: Which team should I add as reviewers? 
You: @mailchimp-monolith/platform-service_delivery
Cursor: ✅ Monitoring PR #297794. Will add them as reviewers when complete.
```

**Monitor with explicit team:**
```
You: "Watch PR #12345 and add @mailchimp-monolith/ads-team as reviewers"
Cursor: ✅ Monitoring PR #12345 for @mailchimp-monolith/ads-team
```
