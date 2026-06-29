# AGENTS.md — AI Agent Instructions

This file is read by AI agents (Claude, Gemini, GPT, Codex, Devin, etc.) that clone or work inside this repository. Follow every rule here exactly.

---

## What This Repo Is

A personal Claude AI skills library with **158+ curated skills**, a four-tier folder hierarchy, and a mandatory rules engine. Skills are Claude Code agent instructions stored as `SKILL.md` files. They extend what Claude can do in a session.

This is **not** a Python package, npm module, or web app. Do not install dependencies, run `npm install`, or try to build anything.

---

## Folder Hierarchy — What Goes Where

```
skills/              ← CORE (158 skills) — curated, premium, production-grade
                       Install first. Takes priority over all other tiers.

skills/basic/        ← BASIC (3 skills) — format/utility (DOCX, PDF, PPTX)
                       Low churn. Stable libraries and document tooling.

skills/library/      ← LIBRARY (1271 skills) — community & upstream imports
                       NEVER override a core skill. Read-only by convention.
                       To customize a library skill, promote it to core first.

skills/dependent/    ← DEPENDENT — require other skills to function
                       Install last. Must declare requires: in frontmatter.

rules/               ← RULES ENGINE — applied to every PR and merge
                       These are mandatory. Read before touching any PR.
```

**Golden rule**: If the same skill name exists in `skills/` (core) and `skills/library/`, the core version always wins. `install.sh` handles this automatically.

---

## Rules Every Agent Must Follow

> These are non-negotiable. See `rules/exclusive_rules.md` for full details.

1. **Never push directly to `main`** — create a branch first
2. **Every PR must link a GitHub Issue** — no orphan PRs
3. **All CI checks must pass** before requesting a merge
4. **Attach an AI self-review** to every PR (run as a secondary agent/subagent)
5. **UI changes require screenshots** — `before.png` and `after.png` committed to the branch
6. **No merge with blocking findings** from AI review
7. **Non-blocking findings** → create a follow-up GitHub Issue, label `priority-2`, resolve within 3 working days

---

## How to Add a Skill

```bash
# 1. Create a branch
git checkout -b feature/add-my-skill

# 2. Create the skill folder in the right tier
mkdir skills/my-skill   # core skill
# OR
mkdir skills/library/my-skill   # library import

# 3. Add SKILL.md with valid frontmatter
cat > skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: What this skill does and when to trigger it.
version: 0.1.0
category: devtools
keywords: [keyword1, keyword2, keyword3]
---

# My Skill

Instructions here...
EOF

# 4. Add README.md (required before merge)
echo "# My Skill\n\nWhat it does, when to use it, examples." > skills/my-skill/README.md

# 5. Validate
./scripts/validate_all.sh

# 6. Install locally
./install.sh

# 7. Open a PR
gh pr create --base main --title "feat: add my-skill" --body "Closes #<issue>"
```

---

## Promoting a Library Skill to Core

```bash
cp -r skills/library/some-skill skills/some-skill
# Customize it for your use case
rm -rf skills/library/some-skill
./install.sh
```

---

## Validation & Diagnostics

```bash
./scripts/validate_all.sh   # Validates all SKILL.md frontmatter recursively
./doctor.sh                 # Diagnoses broken symlinks, missing SKILL.md
./install.sh                # (Re)installs all skills as symlinks
```

All three must pass cleanly before any commit lands on `main`.

---

## What You Must NOT Do

- Do not run `npm install`, `pip install`, or any package manager — there are no dependencies
- Do not modify `skills/library/` content in-place — promote to core instead
- Do not commit directly to `main`
- Do not skip `./scripts/validate_all.sh` before committing
- Do not create PRs without a linked Issue
- Do not merge PRs with failing CI or unresolved blocking review comments
- Do not delete or overwrite `rules/` files without a PR

---

## Key Files Reference

| File | Purpose |
|---|---|
| `README.md` | Full human-readable documentation |
| `AGENTS.md` | This file — AI agent instructions |
| `CLAUDE.md` | Claude Code specific rules |
| `llms.txt` | AI crawler summary |
| `rules/exclusive_rules.md` | Mandatory PR rules |
| `rules/agent_self_review_rules.md` | AI self-review protocol |
| `.skill-manifest.json` | Registry of all skills with provenance |
| `install.sh` | Symlinks all skills into `~/.claude/skills/` |
| `scripts/validate_all.sh` | Frontmatter validation |
