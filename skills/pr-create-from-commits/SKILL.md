---
name: pr-create-from-commits
description: Create a PR from recent commits with Jira status and template. Use when the user asks to create a PR, open a pull request, or run pr-create-from-commits.
---

# Pull Request Create

## Overview
Create a PR based on recent commits. Includes automatic Jira ticket status management to ensure work is properly tracked before PR creation.

## Steps

1. **Gather context from git history and user**
   - Look at recent commits vs latest `main`. Use `git diff origin/main` for overall view
   - Understand code changes and their purpose
   - Identify Jira ticket from branch name or prompt user (ABC-1234 or full URL)
   - Ask user for missing required information (e.g., team Slack channel) if not obvious from changes
   - **Check for mixed changes:** Review if commits contain unrelated changes
     - If mixed concerns detected, WARN user and suggest separating into multiple PRs
     - Only proceed if user confirms changes belong together

2. **Check and update Jira ticket status**
   - Apply Jira status management (see `.agent/rules/jira-status-management.mdc`)
   - Automatically move ticket to "In Progress" if not already there
   - Gracefully handle MCP unavailability (don't block PR creation)
   - Show ticket status and any transitions performed

3. **Git operations (batched)** - Request `["git_write", "network"]` permissions upfront
   - Check if there are uncommitted changes:
     - If YES: Ask user if they want to commit them first before creating PR
     - Stage and commit if user confirms
   - Check if on feature branch:
     - If on `main`: Create new branch `{ticket-prefix}-{ticket-num}-{feature-summary}`
     - Example: `XP-1234-add-campaign-preview`
   - Push current branch to remote if not already pushed

4. **Create PR**
   - Read `.github/pull_request_template.md` for template structure
   - Create PR: `gh pr create --title "[{TICKET}] {Title}" --body "{populated_template}"`
   - Populate ALL template sections based on code analysis:
     - **Background context:** Related code, feature context, related PRs/tickets
     - **Change summary:** High-level implementation overview, alternatives considered, follow-up items
     - **Steps to test:** Flags to enable, user conditions, pages to visit, components to interact with
     - **Risk mitigation table:**
       - 🚩 Flag/Experiment name: {flag_name or N/A if no flag}
       - 🌊 Splatter zone: Affected areas, user segments, fallback behavior
       - 👀 Monitoring: Grafana dashboards, Bugsnag filters, Splunk queries
       - 💬 Slack Channel: {team_channel}
       - 🎟️ Jira ticket: https://jira.your-company.com/browse/{TICKET}
   - **Skills-used tag:** Run `script/agent/pr-skill-summary.sh` and append any output to the PR body.
   - Apply label: `skill-used`
   - Submit as regular PR (not draft)
   - **Note:** Be succinct and accurate. Ask user for clarification rather than guessing. Only use "unknown" or "n/a" when information genuinely cannot be determined.
