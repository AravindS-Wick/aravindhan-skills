# Contributing to aravindhan-skills

Welcome! This is an open-source Claude AI skills library built for the community. Every skill you add makes Claude more powerful for everyone.

---

## What Is a Skill?

A skill is a `SKILL.md` file inside a folder that tells Claude exactly how to handle a specific task — when to trigger, what to do, what tools to use, and what output to produce.

```
skills/
└── my-skill-name/
    └── SKILL.md          # Required — instructions + YAML frontmatter
    └── scripts/          # Optional — helper scripts
    └── examples/         # Optional — reference examples
    └── resources/        # Optional — templates, assets
    └── references/       # Optional — long docs (keeps SKILL.md < 500 lines)
```

---

## Quality Bar

Skills that get merged:
- ✅ Solve a real, recurring problem
- ✅ Have clear trigger keywords in the description
- ✅ Include at least one usage example
- ✅ Are under 500 lines in `SKILL.md` (use `references/` for overflow)
- ✅ Don't duplicate an existing core skill

Skills that get rejected:
- ❌ Too vague ("helps with coding")
- ❌ Only works for one person's specific stack
- ❌ No clear trigger — Claude wouldn't know when to use it
- ❌ Missing YAML frontmatter

---

## Step-by-Step: Add a Core Skill

```bash
# 1. Fork & clone
git clone https://github.com/<YOUR_USERNAME>/aravindhan-skills ~/skills-contrib
cd ~/skills-contrib

# 2. Create your skill folder
mkdir skills/my-skill-name
touch skills/my-skill-name/SKILL.md

# 3. Write the skill (use template below)
# 4. Create a feature branch
git checkout -b feat/add-my-skill-name

# 5. Commit
git add skills/my-skill-name/
git commit -m "feat: add my-skill-name skill

Solves: <what problem>
Trigger: <what user says>"

# 6. Push & open a PR
git push origin feat/add-my-skill-name
# Then: https://github.com/AravindS-Wick/aravindhan-skills/compare
```

---

## SKILL.md Template

```markdown
---
name: my-skill-name
description: >
  One sentence that tells Claude exactly when to activate this skill.
  Include 3–5 trigger keywords. Example: "Use when the user asks to
  analyze performance, profile slow code, or says 'why is this slow'."
version: 1.0.0
author: your-github-username
tier: core
category: devtools
tags: [performance, profiling, debugging]
---

# My Skill Name

## When to Use

Activate this skill when:
- The user mentions [trigger 1]
- The user asks to [trigger 2]
- The user says "[exact phrase]"

## What This Skill Does

Short description of what Claude will do when this skill is active.

## Instructions

1. Step one...
2. Step two...
3. Step three...

## Example Usage

**User**: "Why is my React component re-rendering 50 times?"
**Claude with this skill**: [what Claude does]

## Output Format

Describe what the skill produces.
```

---

## Skill Tiers

| Tier | Folder | Who can add |
|---|---|---|
| `core` | `skills/` | PRs welcome — highest quality bar |
| `basic` | `skills/basic/` | Format utilities, rarely needed |
| `library` | `skills/library/` | Community imports, no curation required |
| `dependent` | `skills/dependent/` | Skills that require other skills |

**New contributions default to `core/`** — if reviewers think it belongs in `library/`, they'll say so.

---

## Label System

When opening your PR, we'll add these labels automatically. You don't need to set them:

| Label | Meaning |
|---|---|
| `tier:core` | Skill in `skills/` |
| `cat:agent` | Agent & orchestration |
| `cat:security` | Security & pentesting |
| `cat:web` | Web & browser |
| `cat:design` | Design & UI |
| `cat:mobile` | Mobile (Expo/React Native) |
| `cat:backend` | Backend & DevOps |
| `cat:product` | Product & analytics |
| `cat:workflow` | PR & git workflow |
| `cat:research` | Research & web |
| `cat:devtools` | Dev tools |
| `good-first-issue` | Great for new contributors |
| `priority-2` | Non-blocking, due within 3 working days |

---

## Review Process

1. **CI runs automatically** — validates frontmatter, checks SKILL.md structure
2. **AI self-review** — an agent posts a review comment with findings
3. **Maintainer review** — 48-hour SLA for first response
4. **Merge** — CATALOG.md auto-regenerates, skill appears on the skills browser

---

## Good First Issues

Look for [`good-first-issue`](https://github.com/AravindS-Wick/aravindhan-skills/labels/good-first-issue) labeled issues. These are:
- Adding a description to a skill that lacks one
- Improving trigger keywords on an existing skill
- Adding usage examples to a skill
- Fixing a broken script in `scripts/`

---

## Code of Conduct

Be excellent to each other. This is a skills library, not a debate club. PRs are reviewed on technical merit.

---

## Questions?

- Open a [Discussion](https://github.com/AravindS-Wick/aravindhan-skills/discussions) for design questions
- Open an [Issue](https://github.com/AravindS-Wick/aravindhan-skills/issues/new/choose) for bugs or skill requests
- Check existing skills in `skills/` for patterns to follow
