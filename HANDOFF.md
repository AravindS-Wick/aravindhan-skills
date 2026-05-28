# Handoff prompt for Claude Code on the Mac

This file is what you (Aravindhan) paste into Claude Code running on your Mac to finish what was started in the web chat. The web Claude can't see `/Users/aravindhan/...` paths — Claude Code can.

## How to use

1. Unzip this loader scaffold somewhere you want it to live, e.g.:
   ```bash
   unzip aravindhan-skills.zip -d ~/personal/
   cd ~/personal/aravindhan-skills
   ```

2. Open Claude Code in that directory.

3. Paste the prompt below.

---

## Paste this into Claude Code

```
I'm continuing work from a web chat. You're now in my aravindhan-skills loader
repo at the current directory. There are three things to do, in this order.

CONTEXT:
- This repo (~/personal/aravindhan-skills) is a personal skills loader. It
  symlinks every directory under skills/ into ~/.claude/skills/. The README
  has the full design.
- One skill is already pre-installed: merge-all-features. Leave it alone unless
  there's an issue.
- Two source directories on this Mac have skills I want to bring in:
    /Users/aravindhan/personal/sk                  ← work-org skills, need customization
    /Users/aravindhan/personal/claude-code-skills  ← external collection, lighter customization

TASKS:

1. Initialize this as a git repo if it isn't one:
     git init && git add -A && git commit -m "chore: initial loader scaffold"
   Then make scripts executable:
     chmod +x install.sh uninstall.sh doctor.sh scripts/*.sh

2. Bulk import from both source directories (dry-run first so I can review):
     ./scripts/import_from_dir.sh /Users/aravindhan/personal/sk --tag work --dry-run
     ./scripts/import_from_dir.sh /Users/aravindhan/personal/claude-code-skills --tag external --dry-run
   Show me the list of skills it would import from each. For each skill, briefly
   describe what it does based on its SKILL.md description. Group by source.

3. After I confirm, do the real imports (without --dry-run). Then for EACH
   imported skill from the 'work' source:
     a. Read skills/<name>/CUSTOMIZE.md if one was created.
     b. Read skills/<name>/SKILL.md and any references/scripts in the skill.
     c. Identify the org-specific bits using docs/CUSTOMIZING.md as the
        playbook (internal URLs, hardcoded paths, company names, embedded
        credentials, account IDs, tool-specific assumptions).
     d. Propose specific edits — show me a diff per skill, briefly explain the
        change for each. Don't auto-apply; wait for me to OK each one or batch
        OK all of them.
     e. Once I approve, apply the edits, delete CUSTOMIZE.md from that skill,
        update .skill-manifest.json to mark customized: true with a one-line note.

4. For skills from the 'external' source: skim each, flag any that have
   obvious issues (broken paths, missing dependencies, conflicts with existing
   skills). Don't customize unless something's clearly broken.

5. Run ./scripts/validate_all.sh — fix any frontmatter issues.

6. Run ./install.sh and report back what got linked, what was skipped, and
   why. Show me ./doctor.sh output.

7. Commit the result: git add -A && git commit -m "feat: import and
   customize work + external skills"

CRITICAL RULES:
- Never carry forward any credentials, tokens, API keys, or secrets — even
  expired ones. If you see one during step 3, strip it immediately and
  call it out explicitly so I can rotate the actual secret upstream.
- Don't add Co-Authored-By, Signed-off-by Claude, or "Generated with"
  trailers to any commit message. Clean commits only.
- If a skill at /Users/aravindhan/personal/sk has the same folder name as
  one at /Users/aravindhan/personal/claude-code-skills, pause and ask me
  which to keep (or how to rename).
- If you find sub-folders that aren't actually skills (no SKILL.md), skip
  them silently — don't import them.
- If anything blocks you on one skill, mark it as **BLOCKED** in bold,
  surface the reason, and KEEP GOING on the rest. Don't let one bad skill
  stop the whole import.

Start with task 1.
```

---

## After Claude Code finishes

Verify by hand:

```bash
./doctor.sh
ls -la ~/.claude/skills/
```

Open a fresh Claude session and try invoking one of the imported skills by its trigger phrase. If it doesn't fire, check that the skill's `description` field is descriptive enough — see `docs/ADDING-SKILLS.md` on writing descriptions Claude will trigger on.

## When you have more skills to add later

Same flow:
```bash
cd ~/personal/aravindhan-skills
./scripts/import_from_dir.sh /path/to/new/source --tag whatever --dry-run
# review, then real run, customize, install
./install.sh
```

Or for a single skill:
```bash
./scripts/add_skill.sh /path/to/one/skill
./install.sh
```
