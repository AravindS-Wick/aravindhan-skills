## 🔗 Related Issue
<!-- Closes #XX or Refs #XX -->
Closes #

## 📝 What This Changes
<!-- Brief description of what the skill does and why it's needed -->

## Skill Details
| Field | Value |
|---|---|
| Skill name | `skill-name` |
| Tier | `core` / `basic` / `library` / `dependent` |
| Category | agent / security / web / design / mobile / backend / product / workflow / research / devtools |
| Trigger phrase | "what you'd say to Claude to activate it" |

## ✅ PR Checklist

### Skill Quality
- [ ] `SKILL.md` has valid YAML frontmatter (`name`, `description`, `version`, `author`)
- [ ] Description includes 3–5 trigger keywords
- [ ] At least one usage example included
- [ ] `SKILL.md` is under 500 lines (or overflow moved to `references/`)
- [ ] Doesn't duplicate an existing core skill

### Code & Process
- [ ] Branch is `feat/skill-name` or `fix/skill-name` or `improve/skill-name`
- [ ] Commit message follows conventional commit format
- [ ] CI passes (frontmatter validation)
- [ ] `skills/CATALOG.md` updated if new skill added (run `python3 scripts/generate_catalog.py`)

### AI Self-Review
- [ ] I've read the skill as if I were Claude — the instructions are unambiguous
- [ ] I've tested this skill in a real Claude session and it produced the expected output

## 🖼️ Screenshots / Output
<!-- If this skill produces visual output, paste a before/after here. -->
<!-- Required for any skill that generates UI, reports, or visual assets -->

## 🤖 Test Session
<!-- Paste the Claude response showing the skill working -->
<details>
<summary>Claude output (click to expand)</summary>

```
Paste Claude's response here
```
</details>
