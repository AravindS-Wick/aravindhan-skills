---
name: github-reviewed-pr-auto-merge
description: End-to-end automation for creating GitHub issues, branches, pushing features, opening PRs, conducting automated self-reviews with PR comments, and merging the PR once clear. Triggered whenever the user says "raise PR", "raise reviewed PR", or "automated PR merge".
---
# github-reviewed-pr-auto-merge

This skill provides full automation for shipping features securely through a structured issue-branch-PR-review-merge workflow. It ensures that no code is merged directly to `main` without tracking, verification, review logs, and automated confirmation.

---

## 📋 High-Level Workflow

```
1. CREATE ISSUE       → Create a GitHub issue for the feature/fix
2. CREATE BRANCH      → Checkout a clean feature branch off the default base branch
3. STASH-BACKUP       → Run a backup of uncommitted state before staging
4. COMMIT & PUSH      → Stage changes, run gates (lint + test), commit, and push
5. RAISE PR           → Create a detailed Pull Request linking to the issue ("Closes #x")
6. PR REVIEW          → AI inspects the PR diff, posting findings as review comments on GitHub
7. AUTO-MERGE         → If gates pass and review has no blocker findings, auto-merge the PR
8. CLEANUP            → Delete the local and remote branches on successful merge
```

---

## 🛠 Detailed Step-by-Step Instructions

When the user asks to "raise PR" or "merge this feature", perform the following operations:

### Step 1: Create a GitHub Issue
Generate a detailed title and description of the current changes. Use the GitHub CLI to create the issue:
```bash
GITHUB_TOKEN="" gh issue create --title "<Issue Title>" --body "<Detailed Description of changes/goals>"
```
*Note: Save the returned issue number (e.g. `#12`).*

### Step 2: Set up the Feature Branch
1. Find the default base branch (typically `main` or `master`):
   ```bash
   BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo main)
   ```
2. Fetch origin and checkout a clean feature branch:
   ```bash
   git fetch origin
   git checkout -b "feat/issue-<num>-<kebab-name>" "origin/$BASE"
   ```

### Step 3: Stage and Gate
1. Stage the files related to the feature:
   ```bash
   git add <staged-files>
   ```
2. Run project gates (e.g. `npm run lint` or `npm test`). If they fail:
   - Try to auto-fix (`eslint --fix` or equivalent).
   - If gates still fail, STOP and block the merge. Do NOT push broken builds.

### Step 4: Commit and Push
1. Commit with a clean Conventional Commit message:
   ```bash
   git commit -m "feat(scope): <description> (closes #<issue-num>)"
   ```
2. Push the branch to origin:
   ```bash
   GITHUB_TOKEN="" git push -u origin "feat/issue-<num>-<kebab-name>"
   ```

### Step 5: Open the Pull Request
Build a detailed PR description using the templates, listing:
- Purpose of changes
- Files changed and why
- Gates and test results
Run the command:
```bash
GITHUB_TOKEN="" gh pr create --title "<Conventional Commit Title> (Closes #<num>)" --body-file <pr-body-temp-file> --base "$BASE"
```
*Note: Retrieve the generated PR URL/number.*

### Step 6: Automated AI PR Review
1. Retrieve the PR diff:
   ```bash
   git diff "origin/$BASE"..."feat/issue-<num>-<kebab-name>"
   ```
2. Review the diff for:
   - Security vulnerabilities (exposed secrets, SQL injection, XSS).
   - Code quality and edge cases.
   - Clean, readable abstractions.
3. Post the review findings as a comment or code review review thread using the CLI:
   - For overview: `gh pr review <pr-num> --comment --body "<Review Findings Summary>"`
   - For specific required actions: `gh pr comment <pr-num> --body "<List of required fixes>"`

### Step 7: Auto-Merge and Branch Cleanup
If the gates pass and the review does not reveal critical blockers:
1. Merge the Pull Request:
   ```bash
   GITHUB_TOKEN="" gh pr merge <pr-num> --merge --delete-branch
   ```
2. Clean up local state:
   ```bash
   git checkout "$BASE"
   git pull origin "$BASE"
   git branch -d "feat/issue-<num>-<kebab-name>"
   ```
