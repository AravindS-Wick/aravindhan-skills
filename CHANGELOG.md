# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added
- GitHub Pages skill browser — searchable, filterable by category
- Fuse.js client-side fuzzy search across all 153 core skills
- Category filter pills (10 categories)
- Skill detail modal with install commands
- Full SEO: Open Graph, Twitter cards, JSON-LD structured data, sitemap.xml

### Infra
- GitHub Actions CI — validates frontmatter, posts skill counts on PR
- `CONTRIBUTING.md` with step-by-step guide and SKILL.md template
- Issue templates: add skill, improve skill, bug report
- PR template with AI self-review checklist

---

## [1.1.0] — 2026-06-29

### Added
- `AGENTS.md` — instructions for AI agents working in this repo (Claude, GPT, Gemini, Devin)
- `CLAUDE.md` — in-session rules and workflow for Claude Code agents
- `llms.txt` — AI crawler readable summary (llmstxt.org standard)
- `skills/CATALOG.md` — flat machine-readable index of all core skills
- `public/social-preview.png` — GitHub social sharing image
- `update.sh` — one-command skill update script
- GitHub repo metadata: description, 10 topics, Discussions enabled

### Community
- 10 GitHub topics applied for discoverability
- Repository Discussions enabled

---

## [1.0.0] — 2026-06-28

### Added
- 153 curated core skills across 10 categories
- 4-tier skill hierarchy: `skills/`, `skills/basic/`, `skills/library/`, `skills/dependent/`
- `skills/library/` — 1,271 community skills imported from upstream sources
- `install.sh` — one-command install script with symlink setup
- `doctor.sh` — validates your installation and checks for common issues
- `scripts/validate_all.sh` — validates SKILL.md frontmatter across all tiers
- `rules/` — mandatory workflow rules (branching, PR, CI, AI review)
- Complete `README.md` with tier documentation, premium skill catalog, and quick-start
- `.skill-manifest.json` — machine-readable manifest for all skills

### Core Skills Highlights
- `merge-all-features` — multi-repo PR shipping with parallel agents
- `shannon` — autonomous AI pentester
- `comprehensive-review` — parallel multi-agent code review
- `agent-development` — build autonomous Claude agents
- `orchestrate` — sprint orchestrator
- `global-security` — pre-commit security gate
- `ui-ux-pro-max` — premium design guide
- `playwright-skill` — browser automation
- `building-native-ui` — complete Expo Router guide
- `mcp-builder` — create MCP servers

---

## How to Contribute

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add your skill to the library.
