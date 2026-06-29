# CLAUDE.md — Rules for Claude Code Agents

This file is automatically read by Claude Code when you open this repo in a session. These rules apply to every action you take here.

---

## Mandatory Workflow

**Never push directly to `main`.** Every change, no matter how small, must follow this flow:

```
1. git checkout -b feature/<description>
2. Make changes
3. ./scripts/validate_all.sh         ← must pass
4. git add . && git commit -m "..."  ← conventional commit format
5. git push -u origin feature/<description>
6. gh pr create --base main ...      ← link a GitHub Issue in the body
7. Wait for CI + AI self-review
8. Resolve any blocking findings
9. Merge
```

---

## Before Every Commit — Run This

```bash
./scripts/validate_all.sh
```

If it fails, fix the errors first. Do not commit with validation failures.

---

## Skill Tiers — Know the Difference

| Tier | Path | Rule |
|---|---|---|
| Core | `skills/` | First priority. Never override with library versions. |
| Basic | `skills/basic/` | Format utilities only. Low churn. |
| Library | `skills/library/` | Read-only. Promote to core to customize. |
| Dependent | `skills/dependent/` | Must declare `requires:` in frontmatter. |

---

## Every SKILL.md Needs This Frontmatter

```yaml
---
name: skill-name
description: One precise sentence. What it does AND when to trigger it.
version: 0.1.0
category: agent | security | web | design | mobile | backend | product | workflow | research | devtools
keywords: [keyword1, keyword2, keyword3]
---
```

Missing or invalid frontmatter = validation fails = PR blocked.

---

## PR Rules (from `rules/exclusive_rules.md`)

- ✅ Branch required — no direct pushes to `main`
- ✅ PR must link a GitHub Issue
- ✅ All CI checks must be green before merge
- ✅ AI self-review attached (run as a subagent with a different model)
- ✅ Before + after screenshots for any UI/visual change
- ❌ Never merge with unresolved blocking AI review findings

---

## Non-Blocking Issues

When AI review flags a non-blocking issue:
1. Create a GitHub Issue: `gh issue create --title "follow-up: <issue>" --label "priority-2"`
2. Reference it in the PR comment
3. It must be resolved within **3 working days**

---

## Conventional Commit Format

```
feat: add new skill for X
fix: correct SKILL.md frontmatter in Y
docs: update README with new tier docs
chore: regenerate CATALOG.md
refactor: restructure dependent skills
```

---

## Useful Commands

```bash
./install.sh                   # (Re)install all skills as symlinks
./doctor.sh                    # Diagnose broken symlinks or missing files
./scripts/validate_all.sh      # Validate all SKILL.md frontmatter

gh issue list                  # See open issues
gh pr list                     # See open PRs
gh pr create --base main ...   # Open a new PR
```

---

## What You Must NOT Do

- Push to `main` directly
- Commit with failing validation
- Edit `skills/library/` files in-place (promote to core instead)
- Create PRs without a linked Issue
- Skip the AI self-review step
- Merge PRs with blocking findings from AI review
- Run `npm install`, `pip install`, or any package manager (no runtime deps)
