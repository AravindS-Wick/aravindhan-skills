---
name: flag-create
description: Create new Mailchimp feature flag and PR. Use when the user asks to create a feature flag, add a new flag, or define a flag in config/flags.ini.
disable-model-invocation: true
---

# Create flag

Create a new Mailchimp feature flag and PR -- see `.agent/rules/flag-config.mdc` for format details. If there's an existing implementation for the flag, create a second branch.

## Steps

1. **Gather & validate inputs**
   - Flag name (with or without prefix: "deprecate_adv_segments" or "aorg.deprecate_adv_segments")
   - Flag prefix/team (e.g., "aorg", "xp", "sms") - determines placement and GitHub team owner
   - Jira ticket (ABC-1234 or full URL)
   - Scheme (if specified)
   - **Conflict rule:** Explicit flag prefix wins over ticket prefix. Ask if ambiguous.
   - Validate: flag prefix exists in rule docs, GitHub team in `.github/capabilities.json`
   - **Check working tree:** Verify clean state with no uncommitted changes
   - **If uncommitted changes exist:** STOP and ask user to commit/stash them first

2. **Check and update Jira ticket status**
   - Apply Jira status management (see `.agent/rules/jira-status-management.mdc`)
   - Automatically move ticket to "In Progress" if not already there
   - Gracefully handle MCP unavailability (don't block flag creation)
   - Show ticket status and any transitions performed

3. **Git operations (batched)** - Request `["git_write", "network"]` permissions upfront
   - **Flag branch (always):** Create branch from latest main: `{ticket-prefix}-{ticket-num}-create-flag-{flag-name}`
     - Example: `XP-1234-create-flag-new-feature`
     - Find insertion point: grep for `^\[{prefix}\.` in `config/flags.ini`
     - Add flag near team flags with: Jira comment, description, owners[], enabled=0.00, enabled_e2e=0.00, scheme (if specified), js_readable (if specified)
     - Stage ONLY `config/flags.ini`. **PRs that change config/flags.ini must not change any other files.**
     - Commit: `"[{TICKET}] create new flag: {full_flag_name}"`
     - Push to origin but do not create a PR yet.
   - **Implementation branch (only if there is an existing implementation, i.e. `git status` has other changes that are related to the flag):**:
     - Create a **separate** branch from latest main (e.g. `{ticket-prefix}-{ticket-num}-{short-description}`). Do **not** put implementation on the flag branch.
     - Put only the implementation changes on this branch (no `config/flags.ini` changes). Implementation should be gated behind the new flag.
     - Commit and push the implementation branch but do not create a PR yet.

4. **Create PR(s)**
   - **Always:** Create a PR for the **flag branch only**. Read `.github/pull_request_template.md` for template structure.
     - `gh pr create --title "[{TICKET}] Create new flag: {flag_name}" --body "{populated_template}"`
     - Populate ALL template sections:
       - **Background context:** Feature purpose, related work, why flag is needed
       - **Change summary:** New flag definition with prefix, team ownership, initial state (and note that implementation will be in a separate PR if applicable)
       - **Steps to test:** "No testing needed - flag at 0.00% in all environments"
       - **Risk mitigation table:**
         - 🚩 Flag/Experiment name: {full_flag_name}
         - 🌊 Splatter zone: "No impact - 0.00% rollout"
         - 👀 Monitoring: N/A (not yet deployed)
         - 💬 Slack Channel: {team_channel}
         - 🎟️ Jira ticket: https://jira.your-company.com/browse/{TICKET}
     - Apply label: `skill-used`
     - Submit as regular PR (not draft)
   - **If an implementation branch was created:** Do **not** create a PR for it by default. At the end of your work, **prompt the user:** "Do you want me to create a PR for the implementation branch (e.g. `{ticket-prefix}-{ticket-num}-{short-description}`) now?" and only create that PR if they confirm.

## See Also
- `.agent/skills/flag-ramp/SKILL.md` - Ramp the flag to users after it ships
- `.agent/skills/flag-clean/SKILL.md` - Remove flag checks once fully rolled out
- `.agent/skills/flag-delete/SKILL.md` - Delete the flag definition as the final step
