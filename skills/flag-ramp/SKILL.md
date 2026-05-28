---
name: flag-ramp
description: Change an existing feature flag's percentage rollout. Use when the user asks to ramp a flag, change rollout percentage, or update enabled/enabled_e2e.
disable-model-invocation: true
---

# Flag ramp

## Overview
Take an existing flag and change the percentage rollout. See `.agent/rules/flag-config.mdc` for how flags are configured.

## Steps

1. **Gather & validate inputs**
   
   **Flag name handling:**
   - If flag name is provided in initial command invocation, immediately look for JIRA ticket in `config/flags.ini` comment (e.g., `; XP-4000`)
   - If flag name is NOT provided, ask for it first, then look for JIRA ticket in flag comment
   - Extract ticket from comment if present
   - Only prompt user for ticket if not found in flag comment
   
   **Then gather remaining inputs:**
   - Flag name (if not already provided) that correlates to `config/flags.ini`. If there isn't an exact match, validate with author
   - New target percentage
   - Environment to impact: Production maps to `enabled`, Preprod/E2E maps to `enabled_e2e`

2. **Validate before proceeding**
   - To do these checks, use the *latest* version of the `main` branch's `config/flags.ini` file.
   - Exact match of a current flag exists
   - Only updating a single flag
   - `enabled_e2e` must be 100% (1.00) before `enabled` can start rolling out
   - No ramp can exceed 100%
   - Percentage notation in 0.00 format. If provided with integers, convert user input percentage to decimal format (divide by 100):
     - User inputs `1` → write `0.01` (1%)
     - User inputs `10` → write `0.10` (10%)
     - User inputs `25` → write `0.25` (25%)
     - User inputs `50` → write `0.50` (50%)
     - User inputs `100` → write `1.00` (100%)
     - User inputs `1.00` or `1.0` → assume they want `1.00` (100%)

3. **Give warnings and wait for confirmation if**
   - Ramping up production flag > 50% at a time. Advise standard scheme: 1%, 5%, 25%, 50%, 100%. **STOP and ask for explicit confirmation before proceeding.**
   - Ramping up E2E flag to anything but 100%. These need 0% or 100%. **STOP and ask for explicit confirmation before proceeding.**

4. **Check working tree before proceeding**
   - Verify clean state with no uncommitted changes
   - **If uncommitted changes exist:** STOP and ask user to commit/stash them first

5. **Git operations (batched)** - Request `["git_write", "network"]` permissions upfront
   - Create branch from latest main: `{ticket-prefix}-{ticket-num}-ramp-flag-{flag-name}-{environment}-to-{percentage}`
     - `{environment}` is `prod` for Production and `e2e` for Preprod/E2E
     - Example (prod): `XP-1234-ramp-flag-new-feature-prod-to-25`
     - Example (e2e): `XP-1234-ramp-flag-new-feature-e2e-to-100`
   - Update matched flag in `config/flags.ini`: modify ONLY `enabled` or `enabled_e2e` field
   - Stage ONLY modified file: `git add config/flags.ini`
   - Commit: `"[{TICKET}] ramp {flag_name} to {percentage}%"`
   - Push to origin

6. **Create PR**
   - Read `.github/pull_request_template.md` for template structure
   - Create PR: `gh pr create --title "[{TICKET}] Ramp {flag_name} — {environment} to {percentage}%" --body "{populated_template}"`
   - Populate ALL template sections:
     - **Background context:** Link to flag creation PR or feature documentation
     - **Change summary:** "Ramping {flag_name} from {old_pct}% to {new_pct}% in {environment}"
     - **Steps to test:** Environment-specific testing instructions, feature behavior to verify
     - **Risk mitigation table:**
       - 🚩 Flag/Experiment name: {flag_name}
       - 🌊 Splatter zone: "{percentage}% of {environment} users, {feature area description}"
       - 👀 Monitoring: Relevant Grafana dashboards, Bugsnag filters, Splunk queries
       - 💬 Slack Channel: {team_channel}
       - 🎟️ Jira ticket: https://jira.your-company.com/browse/{TICKET}
   - Apply label: `skill-used`
   - Submit as regular PR (not draft)

## See Also
- `.agent/skills/flag-create/SKILL.md` - Create a new flag
- `.agent/skills/flag-clean/SKILL.md` - Remove flag checks once at 100%
- `.agent/skills/flag-delete/SKILL.md` - Delete the flag definition as the final step
