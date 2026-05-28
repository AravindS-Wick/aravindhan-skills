---
name: flag-clean
description: Clean flag references from code and make behavior permanent. Use when the user asks to clean a feature flag from code, remove flag checks, or make flag behavior permanent.
---
# Flag clean

## Overview
Clean flag references from code and make behavior permanent. See `.agent/rules/flag-usage.mdc` for usage patterns.

**Important:** This cleans flag usage from code only. The flag definition in `config/flags.ini` should be deleted in a separate PR after this deploys successfully. Use the flag-delete skill for that second step.

## Steps

1. **Gather & validate inputs**
   - Flag name (e.g., "team.feature_name")
   - Jira ticket (ABC-1234 or full URL)
   - Confirm flag is at 0% or 100% and ready to clean
   - **Check working tree:** Verify clean state with no uncommitted changes
   - **If uncommitted changes exist:** STOP and ask user to commit/stash them first
   - **Validate:** Search for ALL usages before proceeding

2. **Search for all flag usages** using `script/flags/check_usage.py`
   - **Find all usage locations:** `./script/flags/check_usage.py --show-locations flag.name`
     - Shows exact file paths and line numbers for all references
     - Searches all patterns: PHP (`MC_Flag::isOn()`, `MC_FlagNames`), JS/React (`FLAGS.CONSTANT`), HTML templates, Dojo/Mojo, config files
     - Groups results by usage type for easier cleanup
   - **Manual verification:** Also check for:
     - Routes: `addFlaggedRoute('flag.name', ...)`
     - Build configs: rspack/webpack bundle entries
     - CODEOWNERS: entries for deleted files
   - See `.agent/rules/flag-usage.mdc` for complete patterns reference

3. **Identify dark code to delete**
   - Controllers gated by the flag
   - React components/bundles never shipped
   - Routes never registered
   - Entire feature directories
   - JavaScript or PHP that is no longer referenced

4. **Git operations (batched)** - Request `["git_write", "network"]` permissions upfront
   - Create branch from latest main: `{ticket-prefix}-{ticket-num}-clean-flag-{flag-name}`
     - Example: `XP-1234-clean-flag-old-feature`
   - Delete unused files (backend and frontend; entire directories if dark code)
   - Remove flag checks from active code
   - Simplify conditional logic (if flag was 100%, keep "on" branch; if 0%, keep "off" branch)
   - Remove from build configs (rspack, webpack)
   - Remove from CODEOWNERS
   - **DO NOT** touch `config/flags.ini` - that's a separate PR
   - Stage ALL modified and deleted files: `git add -A`
     - Verify ONLY flag cleanup changes are staged (no unrelated changes)
     - Explicitly exclude `config/flags.ini` if accidentally modified
   - Commit: `"[{TICKET}] clean {flag_name} from code"`
   - Push to origin

5. **Verify no references remain**
   - Search for: `flag.name`, `FLAG_NAME`, related component names
   - Only `config/flags.ini` should have the flag definition

6. **Create PR**
   - Read `.github/pull_request_template.md` for template structure
   - Create PR: `gh pr create --title "[{TICKET}] Clean {flag_name} from code" --body "{populated_template}"`
   - Populate ALL template sections:
     - **Background context:** Flag state (0% or 100%), why cleaning now, behavior becoming permanent
     - **Change summary:** Files deleted, logic simplified, permanent behavior description
     - **Steps to test:** Verify feature works as expected (if 100%) or is removed (if 0%)
     - **Risk mitigation table:**
       - 🚩 Flag/Experiment name: {flag_name} (being cleaned)
       - 🌊 Splatter zone: Areas affected by permanent behavior change
       - 👀 Monitoring: Grafana dashboards, Bugsnag filters for affected features
       - 💬 Slack Channel: {team_channel}
       - 🎟️ Jira ticket: https://jira.your-company.com/browse/{TICKET}
   - Apply label: `skill-used`
   - Submit as regular PR (not draft)

## Validation Rules

- ❌ **NEVER** remove flag definition from `config/flags.ini` in this PR
- ✅ Search for ALL usage patterns (PHP, JS, HTML, routes, configs)
- ✅ Delete entire directories if they're dark code
- ✅ Simplify logic based on flag state (keep enabled/disabled branch)

## Tools

- `script/flags/check_usage.py --show-locations` - Find all flag usage locations with line numbers
- See `script/flags/README.md` for complete documentation

## See Also
- `.agent/rules/flag-usage.mdc` - Complete flag usage patterns
- `.agent/skills/flag-delete/SKILL.md` - Delete flag definition after deployment
- `script/flags/README.md` - Flag management scripts documentation
