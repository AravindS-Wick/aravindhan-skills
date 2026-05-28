# aravindhan-skills

Personal Claude skills, version-controlled and installable anywhere with one command.

This repo holds every Claude skill Aravindhan uses — built from scratch, adapted from work skills, or pulled from external collections. Drop a skill into `skills/`, run `./install.sh`, and it's available in every Claude Code session on the machine.

---

## Quick start

```bash
git clone <this-repo> ~/personal/aravindhan-skills
cd ~/personal/aravindhan-skills
./install.sh
```

That symlinks every directory under `skills/` into `~/.claude/skills/`. New skills are picked up automatically next time you run install.

On a second machine? Same three commands. The skills travel with the repo.

---

## Layout

```
aravindhan-skills/
├── README.md                 # this file
├── install.sh                # symlink skills into ~/.claude/skills/
├── uninstall.sh              # remove symlinks (skills remain in the repo)
├── doctor.sh                 # diagnose install state
├── .skill-manifest.json      # registry: source, version, description per skill
├── skills/
│   ├── merge-all-features/   # pre-installed: multi-repo PR shipping
│   └── <other skills>/
├── scripts/
│   ├── add_skill.sh          # add a single new skill from a path
│   ├── import_from_dir.sh    # bulk import from a folder of skills
│   └── validate_all.sh       # validate every SKILL.md frontmatter
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
