# aravindhan-skills

Personal Claude skills, version-controlled and installable anywhere with one command.

This repo holds every Claude skill Aravindhan uses — built from scratch, adapted from work skills, or pulled from external collections. Drop a skill into `skills/`, run `./install.sh`, and it's available in every Claude Code session on the machine.

---

## ⚠️ MANDATORY WORKFLOW RULES (2nd Most Important Policy)

All developers and AI agents operating in this repository must strictly adhere to the following rules (detailed in [rules/](file:///Users/aravindhan/personal/aravindhan-skills/rules/)):

1. **Branch Naming**: Only use `feature/<short-name>` or `bugfix/<short-name>`.
2. **Visual Validation**: If there are UI/visual changes, you must capture `before.png` and `after.png` screenshots, commit them to the branch, and embed them in the PR body.
3. **PR Check Compliance**: All automated tests, linter checks, and build steps must pass before merging.
4. **AI Self-Review**: Every PR must undergo a self-review by another AI agent (subagent) using a different model before approval.
5. **Timeline SLA**: Review comments or linter issues must be resolved by an agent within **3 working days**. Non-blockers can be logged and deferred.

---

## Layout

```
aravindhan-skills/
├── README.md                 # this file
├── install.sh                # symlink skills recursively into ~/.claude/skills/
├── uninstall.sh              # remove symlinks
├── doctor.sh                 # diagnose install state
├── .skill-manifest.json      # registry: source, version, description per skill
├── rules/                    # mandatory workflow rules and guidelines
│   ├── README.md             # rules overview
│   ├── exclusive_rules.md    # strict branch, PR, and SLA rules
│   ├── agent_self_review.md  # AI PR review protocol
│   ├── minor_optional.md     # blocker categorization and deferral rules
│   └── skill_rules.md        # integration rules for repository skills
├── skills/                   # premium/core skills (e.g. merge-all-features)
│   ├── basic/                # simple utility/basic skills (e.g. pdf, pptx, docx)
│   ├── dependent/            # shared helper/dependency skills
│   └── library/              # bulk imported skills library (1,200+ skills)
├── scripts/
│   ├── add_skill.sh          # add a single new skill from a path
│   ├── import_from_dir.sh    # bulk import from a folder of skills
│   └── validate_all.sh       # validate every SKILL.md recursively
└── docs/
    ├── ADDING-SKILLS.md
    └── CUSTOMIZING.md        # genericizing org-specific skills
```

---

## How install works

`install.sh` does three things:

1. Finds Claude's skill directory (`~/.claude/skills` by default; override with `CLAUDE_SKILLS_DIR`).
2. For every subdirectory of `./skills/`, creates a symlink in that directory pointing at the local repo path.
3. Updates `.skill-manifest.json` with what was installed.

Symlinks, not copies — so editing a skill in this repo immediately updates the installed version. `git pull` updates skills everywhere they're installed.

If a name already exists in `~/.claude/skills/` and isn't a symlink to this repo, `install.sh` refuses to clobber it.

---

## Adding a new skill

### From scratch
1. Make `skills/my-new-skill/`
2. Add a `SKILL.md` with YAML frontmatter (`name`, `description`)
3. Add `references/`, `scripts/`, `assets/` as needed
4. Run `./scripts/validate_all.sh`
5. Run `./install.sh`

### From an existing folder
```bash
./scripts/add_skill.sh /path/to/existing/skill
```

### Bulk-import a folder of skills
```bash
./scripts/import_from_dir.sh /Users/aravindhan/personal/sk --tag work
./scripts/import_from_dir.sh /Users/aravindhan/personal/claude-code-skills --tag external
```

Walks the source directory, finds every `SKILL.md`, copies each parent folder into `skills/`. Flags any skill that needs customization (org-specific paths, internal URLs, hardcoded company names). See `docs/CUSTOMIZING.md`.

---

## Provenance

`.skill-manifest.json` tracks where each skill came from:

```json
{
  "skills": {
    "merge-all-features": {
      "source": "built-in",
      "version": "0.1.0",
      "added": "2026-05-22",
      "customized": false
    }
  }
}
```

Knowing what's customized matters when re-pulling from the original source later — you don't want to clobber your customizations.

---

## Troubleshooting

**"skill X already exists and is not a symlink to this repo"** — something else installed a skill with that name. Delete `~/.claude/skills/X` or rename yours.

**Skills not showing up** — run `./doctor.sh`. If `~/.claude/skills` isn't where Claude looks on your system, set `CLAUDE_SKILLS_DIR` before installing.

**Edits not reflected** — start a fresh Claude session; skills load per-session.

---

## Pre-installed skills

| Skill | What it does |
|---|---|
| `merge-all-features` | End-to-end multi-repo feature shipping with parallel per-repo agents, ESLint+Jest gates, clean commits (no co-author trailers), detailed PRs, self-review |
