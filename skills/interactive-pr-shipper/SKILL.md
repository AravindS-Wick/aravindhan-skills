---
name: interactive-pr-shipper
description: Fully customizable end-to-end PR shipping workflow with interactive checkbox options, saved user preferences, GitHub issue creation, AI PR reviews, test gates, and automated merging. Use when shipping features or invoking "/ship-pr".
---
# /ship-pr (interactive-pr-shipper)

Customizable end-to-end feature shipping workflow with interactive user preferences, automated issue creation, quality gates, AI PR reviews, and sequential merges.

---

## ⚙️ Interactive Configuration & Saved Preferences

When this skill is invoked:
1. **Check for Saved Config**: Look for `.pr_shipper_config.json` in the workspace root or app data config folder.
2. **Interactive Selection**:
   - If the user explicitly asks to "edit options" OR if `.pr_shipper_config.json` does not exist:
     Prompt the user using `ask_question` with `is_multi_select: true` to pick enabled workflow stages:
     - `(Recommended) Issue Creation: Create GitHub Issue and link PR (Closes #issue)`
     - `(Recommended) AI PR Review: Post self-review checklist comment on PR`
     - `(Recommended) Stash Backup: Create backup/stash tag before staging files`
     - `(Recommended) Quality Gates: Run Jest unit tests, ESLint & Playwright E2E`
     - `(Recommended) Auto-Merge: Sequentially rebase onto main and merge PRs`
3. **Persist Settings**: Save selected options to `.pr_shipper_config.json` for future runs.

---

## 🚀 Execution Workflow

### Stage 1: Feature Grouping & Stash Backup
- Group uncommitted files by logical feature area.
- If **Stash Backup** enabled: Run stash backup (`backup/<feature>/<timestamp>`).

### Stage 2: Quality Gates
- If **Quality Gates** enabled: Execute Jest, ESLint, and Playwright E2E browser tests.

### Stage 3: GitHub Issue Creation & Branch Setup
- If **Issue Creation** enabled: Call GitHub API to create issue and reference `Closes #<issue_num>` in PR description.
- Create feature branch `feat/<feature-name>` off latest `main`.

### Stage 4: Pull Request Creation & AI Review
- Build comprehensive PR description (Purpose, File Changes, Blast Radius, Test Results).
- If **AI PR Review** enabled: Post automated review comment with quality checklist.

### Stage 5: Sequential Rebase & Auto-Merge
- If **Auto-Merge** enabled: Rebase feature branch onto `main` to resolve conflicts and merge PR into `main`.
