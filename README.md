# aravindhan-skills

> **Personal Claude AI Skills Library** — 148+ curated skills, a four-tier folder hierarchy, a mandatory rules engine, and one-command install for every machine.

[![Skills](https://img.shields.io/badge/core%20skills-148-6366f1?style=flat-square)](./skills/)
[![Library](https://img.shields.io/badge/library%20skills-66+-8b5cf6?style=flat-square)](./skills/library/)
[![Rules](https://img.shields.io/badge/rules-enforced-ef4444?style=flat-square)](./rules/)
[![Install](https://img.shields.io/badge/install-one%20command-22c55e?style=flat-square)](#quick-start)

---

## What Is This?

A fully version-controlled, self-installing Claude AI skills repository. Every skill is a folder with a `SKILL.md` — drop it in, run `./install.sh`, and it's live in every Claude Code session on the machine.

**Why this exists:**
- Skills should travel with you across machines, not be re-configured per session
- Premium skills (agent orchestration, multi-repo PRs, security audits) deserve to be curated and upgraded — not left at defaults
- A rules engine ensures every PR, every merge, every agent action follows a consistent standard
- The library tier gives you discovery access to 1,200+ community skills without polluting your core set

---

## Quick Start

```bash
git clone https://github.com/AravindS-Wick/aravindhan-skills ~/personal/aravindhan-skills
cd ~/personal/aravindhan-skills
./install.sh
```

That's it. `install.sh` creates symlinks from every skill folder into `~/.claude/skills/`. On a new machine, run the same three commands — skills follow the repo.

> **Override the install path**: `CLAUDE_SKILLS_DIR=/custom/path ./install.sh`

---

## Repository Structure

```
aravindhan-skills/
│
├── README.md                  # This file
├── install.sh                 # Symlinks all skills → ~/.claude/skills/
├── uninstall.sh               # Removes symlinks (skills stay in the repo)
├── doctor.sh                  # Diagnoses install state, broken symlinks, missing SKILL.md
├── bootstrap.sh               # Fresh machine setup (installs deps + skills)
├── .skill-manifest.json       # Registry: source, version, added date per skill
│
├── skills/                    # ★ CORE — curated, premium, production-grade skills
│   ├── merge-all-features/
│   ├── mcp-integration/
│   ├── agent-development/
│   ├── shannon/
│   └── ... (148 skills)
│
├── skills/basic/              # ◆ BASIC — foundational, utility skills
│   ├── docx/
│   ├── pdf/
│   ├── pptx/
│   └── ... (supporting formats & tools)
│
├── skills/library/            # ◇ LIBRARY — 66+ community & upstream skills
│   ├── 007/
│   ├── agent-orchestrator/
│   ├── ai-seo/
│   └── ... (imported, read-only, never override core)
│
├── skills/dependent/          # ↳ DEPENDENT — skills that require other skills
│   └── prompt-engineering-patterns/
│
├── rules/                     # 🔒 RULES ENGINE — applied to all PRs and merges
│   ├── README.md
│   ├── exclusive_rules.md     # Mandatory: branch, PR, CI, AI review
│   ├── agent_self_review_rules.md
│   ├── minor_optional_rules.md
│   └── skill_rules.md
│
├── scripts/
│   ├── add_skill.sh           # Add a single skill from a path
│   ├── import_from_dir.sh     # Bulk import from a folder
│   ├── validate_all.sh        # Validate every SKILL.md frontmatter
│   ├── detect_repos.sh        # Detect changed repos in multi-repo workspace
│   ├── group_features.py      # Group uncommitted changes by feature
│   ├── make_pr_body.py        # Generate structured PR descriptions
│   ├── run_gates.sh           # ESLint + Jest quality gates before commits
│   ├── stash_backup.sh        # Safe stash with backup
│   └── strip_trailers.sh      # Strip unwanted git commit trailers
│
└── docs/
    ├── ADDING-SKILLS.md
    └── CUSTOMIZING.md
```

---

## Folder Tiers Explained

### `skills/` — Core (Premium)

The **first-class, curated tier**. Every skill here has been built from scratch, adapted for production use, or promoted from the library after validation. These are the skills you rely on daily.

- Installed first by `install.sh`
- Take priority over any duplicate name in `library/`
- Each has a `README.md`, valid YAML frontmatter, and optional `rules.md`
- Subject to full AI self-review before merge

### `skills/basic/` — Basic (Foundational)

**Utility and format skills** that support other skills or provide standalone document-processing capabilities. Think: DOCX generation, PDF handling, PPTX manipulation, XLSX export.

- Installed after core
- Lower churn — stable, rarely updated
- Good place for format libraries and office document tooling

### `skills/library/` — Library (Community & Upstream)

**66+ imported skills** from the global Claude config and community collections. This tier gives you discoverability without mixing community skills into your curated core.

- **Never overrides a core skill** — if the same name exists in `skills/`, the library version is silently skipped
- Read-only by convention — don't customize here, promote to core instead
- Pulled from `~/.gemini/config/skills/` during library import

> To promote a library skill to core: copy it to `skills/`, customize it, and delete the library copy.

### `skills/dependent/` — Dependent

Skills that **require other skills to function**. These are not standalone — they call into core or library skills as part of their execution flow.

- Documented with an explicit `requires:` field in their frontmatter
- Installed last so dependencies are always resolved first

---

## Rules Engine

The `rules/` directory defines mandatory policies applied to **every PR raised against this repo**. These are enforced by convention and AI agents, not just documentation.

### `rules/exclusive_rules.md` — Hard Requirements

| Rule | Detail |
|---|---|
| 🚫 No direct pushes to `main` | Every change must go through a branch |
| 🔗 PR required | Linked to a GitHub Issue |
| ✅ CI must pass | All checks green before merge |
| 🤖 AI self-review | A secondary agent reviews the PR and posts findings |
| 📸 Visual validation | `before.png` + `after.png` required for any UI change |
| ❌ No merge with blockers | All AI-identified blocking issues must be resolved first |

### `rules/agent_self_review_rules.md` — AI Review Protocol

A secondary AI agent is spawned for every PR and performs:
1. Code correctness & logic review
2. Security pattern scanning (XSS, SQLi, CSRF, hardcoded secrets)
3. Skill YAML frontmatter validation
4. Bash safety checks (`set -u`, empty array patterns)
5. Findings posted as PR review comments

**Blocking findings** → must be resolved before merge.
**Non-blocking findings** → automatically converted to a follow-up story, prioritized as 2nd-most-important in the backlog, with a 3-working-day SLA.

### `rules/minor_optional_rules.md` — SLA & Backlog Policy

- Non-blocking issues get a GitHub Issue created automatically
- Labeled `follow-up` and `priority-2`
- Must be resolved within **3 working days**
- Attached as pending status to the repo's project board

### `rules/skill_rules.md` — Skill Standards

Every skill merged to `main` must:
- Have a valid `SKILL.md` with YAML frontmatter (`name`, `description`, `version`)
- Have a `README.md` explaining the skill's purpose, trigger conditions, and examples
- Pass `./scripts/validate_all.sh` with zero errors
- Optionally include a `rules.md` for skill-specific enforcement

---

## Premium Skills Catalog

### 🤖 Agent & Orchestration

| Skill | What it does |
|---|---|
| `merge-all-features` | End-to-end multi-repo PR shipping — parallel per-repo agents, ESLint+Jest gates, clean commits, detailed PRs, AI self-review |
| `agent-development` | Full guidance for building autonomous agents: system prompts, tools, triggers, colors, frontmatter |
| `agent-manager-skill` | Manage multiple local CLI agents via tmux sessions (start/stop/monitor/assign) with cron scheduling |
| `agent-memory-systems` | Cognitive architecture for agent memory — storage, retrieval, context compression, episodic + semantic memory |
| `orchestrate` | Sprint orchestrator — routes to the right skills for each development phase automatically |
| `skills-router` | Reads git context and message keywords to auto-load the correct skill — zero manual selection |
| `comprehensive-review` | Parallel specialized subagents for multi-angle code review (costly — use explicitly) |
| `cross-review` | Code review by a user-specified model (e.g. "review with opus") |

### 🔒 Security

| Skill | What it does |
|---|---|
| `shannon` | Autonomous AI pentester — white-box security assessment, source code analysis, real exploit execution |
| `security-audit` | OWASP Top 10, SQLi, XSS, CSRF, insecure deserialization, command injection, JWT misuse |
| `security-cmdexe` | Convert PHP exec/shell_exec to ShellBuilder pattern |
| `security-csrf` | Apply CSRF protection to controller actions and Autolyse services |
| `security-sqli` | SQL injection protection via prepared statements |
| `security-xss` | XSS protection for Avesta and React views |
| `security-unserialize` | Prevent serialization vulnerabilities |
| `global-security` | Pre-commit security gate: linting, secrets, vulnerable deps, bad branch names |
| `terrashark` | Terraform/OpenTofu hallucination prevention — identity churn, secret exposure, blast-radius checks |

### 🌐 Web & Browser

| Skill | What it does |
|---|---|
| `chrome-extensions` | Manifest V3 Chrome extension development with 10 reference docs (auth, CSP, content scripts, etc.) |
| `a11y` | WCAG 2.2 Level AA accessibility review and fix |
| `accesslint-audit` | Full accessibility audit with report or fix modes — live DOM via CDP or HTML-string fallback |
| `a11y-debugging` | Chrome DevTools MCP accessibility debugging (ARIA, focus, contrast, tap targets) |
| `playwright-skill` | Browser automation: screenshots, responsive testing, form automation, broken-link detection |
| `webapp-testing` | Native Python Playwright scripts for local web app testing |
| `web-asset-generator` | Favicons, PWA icons, Open Graph images, social meta images |
| `verify-endpoints` | Boot dev server, run curl validation, check status codes, auto-debug failures |

### 🎨 Design & UI

| Skill | What it does |
|---|---|
| `ui-ux-pro-max` | Comprehensive design guide — color palettes, typography, responsive layouts, UX patterns |
| `frontend-design` | Frontend designer-engineer patterns — not a layout generator |
| `bencium-innovative-ux-designer` | Distinctive, production-grade frontend — avoids generic AI aesthetics |
| `bencium-controlled-ux-designer` | Expert UI/UX guidance with user confirmation before design decisions |
| `ckm-design` | Brand identity, design tokens, logo generation, corporate identity, banners, icons |
| `ckm-slides` | Strategic HTML presentations with Chart.js, design tokens, responsive layouts |
| `canvas-design` | Algorithmic design philosophies expressed as visual outputs (PDF, PNG) |
| `algorithmic-art` | Generative algorithms — output .md (philosophy), .html (viewer), .js (algorithm) |
| `theme-factory` | Curated font + color theme collection — apply to any artifact |
| `frontend-slides` | Animation-rich HTML presentations from scratch or converted from PPTX |

### 📱 Mobile (Expo / React Native)

| Skill | What it does |
|---|---|
| `building-native-ui` | Complete Expo Router guide — styling, navigation, animations, native tabs |
| `expo-tailwind-setup` | Tailwind CSS v4 in Expo with react-native-css and NativeWind v5 |
| `expo-ui-swift-ui` | `@expo/ui/swift-ui` — SwiftUI Views and modifiers in Expo apps |
| `expo-ui-jetpack-compose` | `@expo/ui/jetpack-compose` — Jetpack Compose Views in Expo apps |
| `native-data-fetching` | Network requests, React Query, SWR, Expo Router loaders, offline support |
| `use-dom` | Expo DOM components — run web code in webview on native, incrementally migrate |
| `vercel-react-native-skills` | React Native + Expo deployment, list performance, animations, native modules |

### ⚙️ Backend & DevOps

| Skill | What it does |
|---|---|
| `mcp-integration` | Integrate Model Context Protocol servers into Claude Code plugins |
| `mcp-builder` | Create MCP servers for LLM-to-external-service integration |
| `planetscale` | Schema branching, indexing, N+1 prevention, query plans, safe online migrations |
| `deploy-to-vercel` | Deploy apps and websites to Vercel with preview and production support |
| `global-tester` | Run Jest, ESLint, pytest, vitest, stylelint, build, TypeScript across any codebase |
| `spartan-ai-toolkit` | Enforces quality gates (typecheck → lint → test → build) before agent code |
| `improve-codebase-architecture` | Reorganize codebases into Controllers / Services / Repositories pattern |

### 📊 Product & Analytics

| Skill | What it does |
|---|---|
| `biz-analyst` | KPIs, ROI calculation, business impact, metrics dashboards, growth forecasting |
| `product-designer` | UI component specs, WCAG 2.1 AA audit, design system consistency, token architecture |
| `market-researcher` | Competitor analysis, trend research, feature validation, market gap identification |
| `marketing-strategist` | GTM strategy, positioning statements, launch checklists, email sequences |
| `sprint-commander` | Sprint planning, velocity forecasting, retrospectives, dependency mapping |
| `po-guide` | User stories, acceptance criteria, RICE/MoSCoW prioritization, engineering task breakdown |
| `standup` | Sprint summary for team standups — state changes + stagnant tickets |

### 📝 PR & Git Workflow

| Skill | What it does |
|---|---|
| `pr-create-from-commits` | Create PR from recent commits with Jira status and PR template |
| `pr-review` | Review PR with code analysis, security checks, optional Playwright test discovery |
| `pr-monitor` | Watch PR CI checks with flaky test detection and optional auto-rerun |
| `pr-status` | List open PRs with merge readiness, CI status, approval state, conflict detection |
| `pr-request-review` | Ping the right Slack channel for PR review; bump existing thread or post fresh |
| `commit` | Conventional commit format with issue references — never commit without this |
| `work-on` | Start working on a Jira ticket — gathers context, branches, PRs |

### 🔍 Research & Web

| Skill | What it does |
|---|---|
| `firecrawl` | Web scraping, search, crawling, page interaction via Firecrawl CLI |
| `firecrawl-search` | Web search with full page content extraction — beyond built-in WebSearch |
| `firecrawl-scrape` | Clean markdown from any URL including JS-rendered SPAs |
| `firecrawl-agent` | Autonomous structured data extraction with JSON schema |
| `last30days` | Aggregate Reddit, X, and web opinions on any tool or trend from past 30 days |
| `morning-intelligence` | Personalized daily briefing based on role, focus areas, and news sources |

### 🏗️ Skill & Plugin Development

| Skill | What it does |
|---|---|
| `skill-creator` | Guide for creating effective skills — structure, progressive disclosure, frontmatter |
| `skill-development` | Full skill development workflow for Claude Code plugins |
| `plugin-structure` | Plugin directory layout, manifest configuration, component organization |
| `command-development` | Create slash commands with YAML frontmatter, dynamic arguments, user interaction |
| `hook-development` | Create Claude Code hooks (PreToolUse, PostToolUse, Stop, SessionStart, etc.) |
| `agent-development` | Build autonomous agents — system prompts, tools, triggers, colors |
| `template-skill` | Starter template for new skills |

---

## How `install.sh` Works

```
install.sh
  ├── 1. Locates CLAUDE_SKILLS_DIR (~/.claude/skills by default)
  ├── 2. Iterates skills/ recursively (core → basic → library → dependent)
  ├── 3. Creates symlinks: ~/.claude/skills/<name> → repo/skills/<name>
  ├── 4. Skips if name already symlinked to this repo (idempotent)
  ├── 5. Refuses to clobber non-symlink installs (protects manual installs)
  └── 6. Core skills take priority — library duplicates are silently skipped
```

**Editing a skill in this repo instantly updates the live installed version** — no reinstall needed, since symlinks point at the repo.

```bash
# Override install directory
CLAUDE_SKILLS_DIR=/custom/path ./install.sh

# Diagnose broken symlinks, missing SKILL.md, stale entries
./doctor.sh

# Validate all SKILL.md frontmatter
./scripts/validate_all.sh
```

---

## Adding a Skill

### From scratch

```bash
mkdir skills/my-new-skill
cat > skills/my-new-skill/SKILL.md << 'EOF'
---
name: my-new-skill
description: What this skill does and when to use it.
version: 0.1.0
---

# My New Skill

Instructions here...
EOF
echo "# My New Skill" > skills/my-new-skill/README.md
./scripts/validate_all.sh
./install.sh
```

### From an existing folder

```bash
./scripts/add_skill.sh /path/to/existing/skill
```

### Bulk-import a directory

```bash
./scripts/import_from_dir.sh /path/to/skill-collection --tag external
```

### Promote a library skill to core

```bash
cp -r skills/library/some-skill skills/some-skill
# Customize it
rm -rf skills/library/some-skill
./install.sh
```

---

## Provenance Tracking

Every skill is tracked in `.skill-manifest.json`:

```json
{
  "skills": {
    "merge-all-features": {
      "source": "built-in",
      "version": "0.1.0",
      "added": "2026-05-22",
      "customized": true,
      "tier": "core"
    },
    "agent-orchestrator": {
      "source": "library-import",
      "version": "0.1.0",
      "added": "2026-06-28",
      "customized": false,
      "tier": "library"
    }
  }
}
```

Tracking `customized: true` prevents accidental overwrites when re-pulling from the original source. Tracking `tier` tells `install.sh` the priority order.

---

## PR Workflow (Mandatory)

> These rules are enforced for every PR raised against this repo. See [`rules/exclusive_rules.md`](./rules/exclusive_rules.md) for full details.

```
1. Create a branch         git checkout -b feature/my-change
2. Make changes            (never commit directly to main)
3. Open a GitHub Issue     Link it in the PR body
4. Run validation          ./scripts/validate_all.sh && ./doctor.sh
5. Push & open PR          gh pr create --base main ...
6. CI must pass            All checks green
7. AI self-review          Secondary agent reviews, posts findings
8. Resolve blockers        All blocking issues fixed before merge
9. Screenshots (UI)        before.png + after.png committed for visual changes
10. Merge                  Only after steps 6–9 complete
```

**Non-blocking findings** from AI review → follow-up GitHub Issue created, labeled `priority-2`, resolved within **3 working days**.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `skill X already exists and is not a symlink to this repo` | Delete `~/.claude/skills/X` or rename your skill |
| Skills not showing up in Claude | Run `./doctor.sh`; check `CLAUDE_SKILLS_DIR` |
| Edits not reflected in session | Start a fresh Claude session — skills load per-session |
| `set -u` crash in scripts | Use `${arr[@]+"${arr[@]}"}` pattern for array expansions |
| Library skill overriding core | Core always wins — check `install.sh` dedup logic |

---

## Related Links

- [GitHub Issues](https://github.com/AravindS-Wick/aravindhan-skills/issues)
- [Pull Requests](https://github.com/AravindS-Wick/aravindhan-skills/pulls)
- [Rules Engine](./rules/)
- [Adding Skills Guide](./docs/ADDING-SKILLS.md)
- [Customizing Skills](./docs/CUSTOMIZING.md)
