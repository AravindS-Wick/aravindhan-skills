---
name: aravindhan-ui
description: >
  Full project brain for @aravi1008/ui design system and all related repos
  (monorepo, storybook, framework packages). Use this skill whenever the user
  mentions @aravi1008/ui, aravindhan-ui, av- components, the design system,
  or any of the related packages. Loads complete architecture, decisions,
  roadmap, and coding rules so you NEVER start fresh.
---

# @aravi1008/ui — Full Project Brain

> This skill is the single source of truth for the entire @aravi1008/ui ecosystem.
> Read it fully before doing anything. Update the memory files after every session.

---

## 1. Identity

| Key | Value |
|-----|-------|
| npm package | `@aravi1008/ui` |
| npm scope | `aravi1008` (NOT `aravindhan`) |
| Published | https://www.npmjs.com/package/@aravi1008/ui |
| Version | See `package.json` in packages/core |
| Author | Aravindhan Sivaraman — sole owner, no co-authors ever |
| License | MIT |

---

## 2. Repository Map

| Repo | GitHub | Purpose | Status |
|------|--------|---------|--------|
| `aravindhan-ui` | `AravindS-Wick/aravindhan-ui` | Original repo — will be archived after monorepo migration | Active (bugs being fixed) |
| `aravindhan-ui-monorepo` | `AravindS-Wick/aravindhan-ui-monorepo` | Future home of all packages | Planned (Wave 6) |
| `aravindhan-ui-storybook` | `AravindS-Wick/aravindhan-ui-storybook` | Docs site (Astro+Starlight, Cloudflare Pages) | Planned (Wave 5) |

**Local path:** `/Users/aravindhan/personal/aravindhan-ui-package/aravindhan-ui/`

---

## 3. Tech Stack

### Core Package
- **CSS:** SCSS with `@use`/`@forward`, no `@import`
- **Build:** Rollup (CSS via rollup-plugin-postcss, JS via rollup)
- **Tokens:** Style Dictionary v4 (JSON → CSS/SCSS/JS)
- **Package manager:** npm (staying; pnpm only in future monorepo — easier for clients/hiring managers)
- **Testing:** Jest + jsdom, coverage ≥85%
- **Linting:** ESLint + Stylelint (0 errors)
- **Versioning:** semantic-release on main merge → auto npm publish
- **Monorepo future:** Turborepo + Changesets (replaces semantic-release)

### Docs Site (planned)
- Astro + Starlight
- Pagefind (static search)
- Cloudflare Pages (free, unlimited bandwidth)

### Framework Packages (planned)
- `@aravi1008/ui-react` — React 18+, TypeScript
- `@aravi1008/ui-vue` — Vue 3 Composition API
- `@aravi1008/ui-angular` — Angular standalone components
- `@aravi1008/ui-svelte` — Svelte 5 runes
- `@aravi1008/ui-rn` — React Native (stub, no CSS)
- `@aravi1008/ui-flutter` — Flutter/Dart (stub)

All framework packages are **thin wrappers** — they map props to `av-` CSS classes.
The core CSS package does all real work. Framework packages are ~30 files each.

---

## 4. Naming Conventions (NEVER violate)

| Type | Pattern | Example |
|------|---------|---------|
| CSS class | `av-<component>` | `av-btn`, `av-modal` |
| CSS class modifier | `av-<component>-<modifier>` | `av-btn-primary`, `av-modal-lg` |
| CSS custom property | `--av-<category>-<name>` | `--av-theme-color-primary` |
| SCSS variable | `$av-<name>` | `$av-color-primary` |
| JS export | `camelCase` | `setTheme`, `modal`, `createTable` |
| JS internal | `_camelCase` | `_scrollLockCount`, `_toastQueue` |
| Data attribute | `data-av-<name>` | `data-av-modal-open`, `data-av-theme` |
| File (SCSS partial) | `_<name>.scss` | `_button.scss` |
| Branch | `feat/<name>`, `fix/<name>`, `chore/<name>` | `fix/body-scroll-lock` |
| Commit | `type(scope): description` | `fix(modal): add body scroll lock` |

---

## 5. Git Rules (ABSOLUTE — never bypass)

- **No `Co-Authored-By` lines** in any commit, ever
- **Never delete branches** after merge
- **Never push directly to main** — always PR
- **Never `--no-verify`** unless user explicitly approves
- **Never `--force` push to main`**
- Branch naming: `feat/`, `fix/`, `chore/`, `docs/`, `refactor/`
- PR title must match commit format

---

## 6. Quality Gates (all must pass before any PR merges)

| Gate | Threshold |
|------|-----------|
| ESLint | 0 errors, 0 warnings |
| Stylelint | 0 errors |
| Jest tests | All pass |
| Statement coverage | ≥85% |
| Branch coverage | ≥85% |
| Function coverage | ≥80% |
| Line coverage | ≥85% |
| npm audit | 0 high/critical |
| Build | exit 0, dist/ populated |

---

## 7. Package Exports

```
@aravi1008/ui           → dist/index.js (ESM) / dist/index.cjs (CJS)
@aravi1008/ui/css       → dist/index.css
@aravi1008/ui/css/min   → dist/index.min.css
@aravi1008/ui/scss      → src/index.scss
@aravi1008/ui/less      → src/index.less
@aravi1008/ui/tokens    → dist/tokens/tokens.js
@aravi1008/ui/tokens/css → dist/tokens/variables.css
@aravi1008/ui/tokens/scss → dist/tokens/variables.scss
@aravi1008/ui/themes/*  → dist/themes/<name>.css
@aravi1008/ui/components → dist/components.js (ESM) / dist/components.cjs (CJS)
@aravi1008/ui/icons     → dist/icons/sprite.svg
@aravi1008/ui/icons/*   → dist/icons/<name>.svg
```

---

## 8. Component Inventory

### CSS Components (25)
accordion, alert, avatar, badge, breadcrumb, button, card, drawer, dropdown,
form, input-group, modal, navbar, pagination, progress, skeleton, spinner,
stat, stepper, switch, table, tabs, timeline, toast, tooltip

### Interactive JS Components (8, in src/components.js)
modal, drawer, dropdown, toast, accordion, tabs, navbar, createTable

### New Components (to be added — Wave 4)
combobox, popover, file-upload, command-palette (+ virtual list in createTable)

### Themes (6)
light (default), dark (auto via prefers-color-scheme), forest, ocean, professional, corporate

### Icons (150 SVGs in dist/icons/sprite.svg)
All stroke-based, currentColor, viewBox 0 0 24 24

---

## 9. The Complete Roadmap

### Wave 1 — Foundation (in `aravindhan-ui`) — ✅ PRs #14-15 OPEN
- ~~`chore/migrate-pnpm`~~ — DROPPED (stay npm; pnpm only in future monorepo)
- `fix/body-scroll-lock` (PR #14) — `_scrollLockCount` counter prevents premature unlock; both modal+drawer use same counter
- `fix/toast-queue-limit` (PR #15) — `_toastQueue`, `_toastMaxVisible=5`, `toast.configure({ maxVisible })`, `toast._reset()` (test-only)

### Wave 2 — Bug Fixes (in `aravindhan-ui`) — ✅ PRs #16-20 OPEN
- `fix/focus-trap-live-query` (PR #16) — live DOM query inside keydown handler (not cached at open)
- `fix/dropdown-typeahead` (PR #17) — single-char typeahead, case-insensitive
- `fix/accordion-animation` (PR #18) — `grid-template-rows: 0fr→1fr`; `av-accordion-body` needs `overflow:hidden; min-height:0`
- `fix/table-render-xss` (PR #19) — `sanitize` on `TableColumn`: data escapes by default; render does not (opt-in)
- `feat/spa-mutation-observer` (PR #20) — `initAll({ observe: true })` returns `() => void` cleanup

### Wave 3 — New Utilities (in `aravindhan-ui`) — ✅ PR #21 OPEN
- `feat/missing-utilities` (PR #21) — aspect-ratio, scroll (use shorthand not longhand), animation keyframes + reduced-motion, print utilities

### Wave 4 — New Components (in `aravindhan-ui`)
- `feat/combobox` — accessible combobox with filter, ARIA pattern
- `feat/popover` — CSS anchor positioning + JS fallback
- `feat/file-upload` — drag-drop zone with file validation
- `feat/command-palette` — Cmd+K palette with search + keyboard nav
- `feat/virtual-list` — createTable virtualization for 500+ rows

### Wave 5 — Docs Site (`aravindhan-ui-storybook` repo)
- Astro + Starlight scaffold
- 40+ MDX pages (one per component + utilities + tokens + icons)
- ComponentPreview.astro — live demo + code tab + copy
- IconGrid.astro — searchable 150+ icon grid
- TokenGrid.astro — color swatches, spacing scale
- ThemePicker.astro — live 6-theme switcher
- Pagefind integration
- Cloudflare Pages deploy (free, unlimited bandwidth)

### Wave 6 — Monorepo Migration (new `aravindhan-ui-monorepo` repo)
- Turborepo + pnpm workspaces
- Changesets for independent package versioning
- Copy core via git subtree (preserves history)
- Archive old `aravindhan-ui` repo

### Wave 7 — Framework Packages (in monorepo)
- `packages/react/` → `@aravi1008/ui-react` (React 18 + Next.js)
- `packages/vue/` → `@aravi1008/ui-vue` (Vue 3 + Nuxt)
- `packages/angular/` → `@aravi1008/ui-angular` (standalone components)
- `packages/svelte/` → `@aravi1008/ui-svelte` (Svelte 5 runes)
- `packages/rn/` → `@aravi1008/ui-rn` (stub — React Native, no CSS)
- `packages/flutter/` → `@aravi1008/ui-flutter` (stub — Dart)

### Wave 8 — Docs Update
- Add React/Vue/Angular/Svelte usage tabs to every component page in storybook

---

## 10. CSS Usage Pattern

This is a **CSS-class-based system** (like Bootstrap), NOT a React component system (like MUI).

```html
<!-- CSS only — works everywhere -->
<button class="av-btn av-btn-primary av-btn-lg">Primary</button>
<div class="av-alert av-alert-info">Alert</div>
<div class="av-modal-backdrop" id="m1">
  <div class="av-modal av-modal-md">...</div>
</div>

<!-- JS for interactive behavior -->
<script type="module">
  import { initAll, toast } from '@aravi1008/ui/components';
  initAll();
  toast.show({ title: 'Hello', type: 'success' });
</script>

<!-- Theme switching -->
<html data-av-theme="dark">
<script type="module">
  import { setTheme, initTheme } from '@aravi1008/ui';
  initTheme('light'); // restore from localStorage or OS pref
</script>
```

---

## 11. Framework Usage Pattern (after Wave 7)

```tsx
// React / Next.js
import '@aravi1008/ui/css';
import { Button, Alert, Modal } from '@aravi1008/ui-react';
<Button variant="primary" size="lg">Click</Button>
<Alert variant="outlined" color="info">Alert</Alert>
```

```vue
<!-- Vue 3 / Nuxt -->
import '@aravi1008/ui/css'
import { Button, Alert } from '@aravi1008/ui-vue'
<Button variant="primary">Click</Button>
```

```ts
// Angular
// In angular.json styles: ["node_modules/@aravi1008/ui/dist/index.css"]
import { AvButtonComponent } from '@aravi1008/ui-angular';
<av-button variant="primary">Click</av-button>
```

---

## 12. Key Architecture Decisions (never revisit without good reason)

| Decision | Rationale |
|----------|-----------|
| CSS-class pattern (not JSX) | Framework-agnostic — works with React, Vue, Angular, HTMX, plain HTML |
| `av-` prefix | Short for "aravindhan", zero collision risk |
| 6 themes via `data-av-theme` | Scoped by attribute, no CSS specificity wars |
| Style Dictionary for tokens | JSON source of truth, generates CSS/SCSS/JS all at once |
| semantic-release → Changesets | Monorepo needs independent per-package versioning |
| Cloudflare Pages for docs | Unlimited bandwidth, free forever, no cold starts |
| Astro + Starlight for docs | Framework-agnostic, vanilla JS demos embed perfectly |
| Pagefind for docs search | Static, no server, zero cost |
| Monorepo (Turborepo) | One CI, shared tooling, atomic cross-package PRs |
| React Native = stub | CSS doesn't exist on native; needs full rebuild, deferred |
| Flutter = stub | Dart language; completely separate ecosystem, deferred |

---

## 13. After Every Session — Update Protocol

At the end of every chat session that makes progress on this project:

1. Update `STATUS.md` in the package repo with what changed
2. Update the memory file: `/Users/aravindhan/.claude/projects/-Users-aravindhan-personal-aravindhan-ui-package/memory/project_aravindhan_ui.md`
3. If new decisions were made, add them to Section 12 of this skill
4. If wave status changed, update Section 9 of this skill
5. Note: this skill lives at `/Users/aravindhan/.claude/skills/aravindhan-ui/skill.md`

---

## 14. How to Resume Any Session

At the start of any new chat about this project:
1. Claude Code auto-loads this skill (it's in global skills)
2. Read `/Users/aravindhan/personal/aravindhan-ui-package/aravindhan-ui/docs/STATUS.md` for live state
3. Check current git branch and recent commits
4. Continue from where the last session left off

Even on a new device — if `~/.claude/` is synced (via dotfiles, iCloud, etc.) this full brain travels with you.
