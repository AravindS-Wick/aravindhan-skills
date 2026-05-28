---
name: flag-delete
description: Delete flag definition from config/flags.ini after code references are removed. Use when the user asks to delete a flag definition or remove a flag from config.
disable-model-invocation: true
---

# Flag delete

## Overview
Delete flag definition from `config/flags.ini` after all code references have been removed. See `.agent/rules/flag-config.mdc` for flag format.

**Prerequisites:** 
- All flag references removed from code (via `flag-clean` or manually)
- Code changes deployed to production successfully
- No runtime errors or issues detected

## Steps

1. **Gather & validate inputs**
   - Flag name (e.g., "xp.fusion_playground")
   - Jira ticket (ABC-1234 or full URL)
   - **Check working tree:** Verify clean state with no uncommitted changes
   - **If uncommitted changes exist:** STOP and ask user to commit/stash them first

2. **Verify code references are gone** using `script/flags/check_usage.py`
   - **Quick check:** `./script/flags/check_usage.py flag.name`
     - Expected: ✅ [SAFE TO DELETE]
     - If ❌ [UNSAFE TO DELETE], use `--show-locations` to find remaining references
   - **Detailed check (optional):** `./script/flags/check_usage.py --show-locations flag.name`
     - Shows exact file paths and line numbers for any remaining usage
     - Searches all patterns: PHP (`MC_Flag::isOn()`, `MC_FlagNames`), JS/React (`FLAGS.CONSTANT`), HTML templates, Dojo/Mojo, config files
   - **If ANY code references exist:** STOP - remove them first using the flag-clean skill or manually
   - **Only proceed if:** Script reports ✅ [SAFE TO DELETE] (only `config/flags.ini` contains the flag)

3. **Git operations (batched)** - Request `["git_write", "network"]` permissions upfront
   - Create branch from latest main: `{ticket-prefix}-{ticket-num}-delete-flag-{flag-name}`
     - Example: `XP-1234-delete-flag-old-feature`
   - **Delete flag using script:** `./script/flags/delete_config.py flag.name`
     - Script handles proper boundary detection (comments + section + all fields)
     - Use `--dry-run` flag first to preview: `./script/flags/delete_config.py --dry-run flag.name`
   - Stage ONLY modified file: `git add config/flags.ini`
   - Commit: `"[{TICKET}] delete {flag_name} flag definition"`
   - Push to origin

4. **Create PR**
   - Read `.github/pull_request_template.md` for template structure
   - Create PR: `gh pr create --title "[{TICKET}] Delete {flag_name} flag definition" --body "{populated_template}"`
   - Populate ALL template sections:
     - **Background context:** Link to flag cleanup PR, confirmation all code references removed
     - **Change summary:** "Removing flag definition after successful code cleanup and deployment"
     - **Steps to test:** "No testing needed - flag no longer referenced in code"
     - **Risk mitigation table:**
       - 🚩 Flag/Experiment name: {flag_name} (being removed)
       - 🌊 Splatter zone: "No impact - code references already removed"
       - 👀 Monitoring: Verify no errors in Bugsnag/Splunk after deployment
       - 💬 Slack Channel: {team_channel}
       - 🎟️ Jira ticket: https://jira.your-company.com/browse/{TICKET}
   - Apply label: `skill-used`
   - Submit as regular PR (not draft)

## Validation Rules

- ❌ **NEVER** delete flag definition if ANY code references remain
- ✅ Thoroughly search for ALL reference patterns (PHP, JS, HTML, routes, configs)
- ✅ Confirm no runtime errors or issues

## Tools

- `script/flags/check_usage.py` - Check if flag is used in code
- `script/flags/check_usage.py --show-locations` - Find exact usage locations
- `script/flags/delete_config.py` - Delete flag from config file
- See `script/flags/README.md` for complete documentation

## See Also
- `.agent/rules/flag-config.mdc` - Flag definition format
- `.agent/skills/flag-clean/SKILL.md` - Clean flag from code (Step 1)
- `script/flags/README.md` - Flag management scripts documentation
