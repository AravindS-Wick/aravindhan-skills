# Adding skills to this repo

Three paths in.

## Path 1: Write from scratch

```bash
mkdir skills/my-new-skill
$EDITOR skills/my-new-skill/SKILL.md
```

Minimum viable `SKILL.md`:

```markdown
---
name: my-new-skill
description: One-paragraph description that includes (a) what the skill does and (b) specific user phrases or contexts that should trigger it. Up to 1024 chars total. Be a little "pushy" — Claude tends to undertrigger skills.
---

# My New Skill

What this skill does in detail. Use imperative voice in instructions to Claude.

## Steps

1. First, do X.
2. Then, do Y.

## Edge cases

- If Z happens, handle it like...
```

After writing:
```bash
./scripts/validate_all.sh my-new-skill
./install.sh
```

Start a new Claude session and the skill is available.

## Path 2: Import a single existing skill

```bash
./scripts/add_skill.sh /path/to/some/skill-folder
# or with a rename:
./scripts/add_skill.sh /path/to/some/skill-folder my-renamed-skill
```

The folder must contain a `SKILL.md`. Copies in, validates, ready to install.

## Path 3: Bulk import from a folder

```bash
./scripts/import_from_dir.sh /Users/aravindhan/personal/sk --tag work
./scripts/import_from_dir.sh /Users/aravindhan/personal/claude-code-skills --tag external
```

This walks the source directory, finds every `SKILL.md`, copies each parent folder in. It also runs a scan for org-specific patterns (internal URLs, hardcoded paths, embedded credentials) and writes a `CUSTOMIZE.md` inside any skill that needs review.

Use `--dry-run` first to see what would happen:
```bash
./scripts/import_from_dir.sh /Users/aravindhan/personal/sk --dry-run
```

## Bundled files

Beyond `SKILL.md`, a skill can include:

- `references/` — markdown loaded into context as needed (best for longer reference material that doesn't need to be in the main SKILL.md)
- `scripts/` — executable code (shell, Python, etc.) the skill can invoke
- `assets/` — templates, icons, fonts, anything the skill produces output with

The skill-creator convention is for SKILL.md to stay under ~500 lines and offload depth to references. Same goes here.

## Naming convention

- Use kebab-case for skill folder names
- Match the `name:` in frontmatter to the folder name (the validator enforces this)
- Avoid generic names that collide with built-in skills (`pdf`, `docx`, `xlsx`, etc.)
- Prefix work-specific versions if you keep them alongside generic ones: `work-deploy-x` vs `deploy-x`

## Testing

For skills with verifiable outputs, write a small eval. The simplest version: a folder with input files and expected output snippets. Run the skill, diff against expected. Skill-creator has a full eval framework if you want to go deeper.
