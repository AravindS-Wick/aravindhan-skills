---
name: pr-review
description: Review a PR with code analysis, security checks, and optional Playwright test discovery. Use when the user runs /pr-review, asks to review a PR or their changes, says "look at this PR", "check my diff", "review before I push", or wants feedback on code changes. Fetches PR via gh pr view; offers Playwright test check/create when running locally with Playwright repo.
---
# PR Review: Code Review + Playwright Test Discovery

## Overview
Review a PR with code analysis, security checks, and verdict. Asks for PR link or number first, then fetches summary and steps to test via `gh pr view`. Checks environment (local vs CWS)—if local with Playwright repo, offers to find existing tests or create new ones for visual changes.

**Note:** Playwright tests live in a **separate repo** (not the monolith's `playwright/` directory). Playwright options only apply when that repo is available in the workspace.

## Steps

1. **Gather PR context (first)**
   - **Immediately ask:** "Please provide the PR link or number (e.g. `https://github.your-company.com/.../pull/12345` or `12345`)." Do not check the current branch first.
   - If user says to use current branch, then run `gh pr view` (no args).
   - Run `gh pr view <url-or-number>` to get:
     - Title, body, summary
     - Steps to test (from PR description)
     - PR state (open, merged, closed)
   - **If PR is merged:** Ask: "I see this PR is merged. Did you still want to review it?" If user says no, stop. If yes, proceed.
   - Use this context throughout the review.

2. **Environment check (two parts)**
   - **Part 1:** Ask: "Where are you running this? **Local** or **CWS**?"
   - **Part 2 (if Local):** Ask: "Do you have the Playwright repo in your workspace?"
   - **If Local + Playwright repo in workspace**:
     - "I'll run the base review, then offer Playwright options: check for existing tests covering your changes, and optionally create tests if needed."
   - **If Local + no Playwright repo** or **CWS**:
     - "I'll run the base review. Playwright options (check/create tests) won't be available—run locally with the Playwright repo in your workspace if you need those."

3. **Base review**
   - Use `git diff origin/main` and `gh pr view` output (summary, steps to test) to understand changes
   - Analyze: code quality, patterns, security (XSS, CSRF, SQLi per `.agent/rules/`), accessibility where relevant
   - **Test coverage:** Determine if Jest (JS/React) or PHPUnit (PHP) tests are needed for the changed code. Check for existing tests; flag if coverage is lacking.
   - **Logging:** Where applicable (new code paths, error handling, significant logic), flag if logging is missing or insufficient.
   - Use PR steps to test when suggesting Playwright coverage or validating the review
   - Provide verdict: approve / request changes / discuss
   - Suggest visual check when changes affect UI (components, styles, layout)
   - Be succinct; ask for clarification rather than guessing
   - **After review:** Ask: "Would you like me to draft these findings (tests, logging, or other suggestions) as PR comments?" If yes, format them for `gh pr review` or inline comments.

4. **If Local + Playwright repo in workspace and visual change**
   - Ask: "Should I check for existing Playwright tests covering this area?"
   - **If yes**: Search the Playwright repo's test directory for:
     - Component names, file paths, route names from the PR diff
     - Keywords from the PR's "Steps to test" section
     - Feature terms (e.g. "Add country", "SMS Settings", event names)
     - Use grep and/or semantic search
   - Report findings: list matching tests or "No existing tests found"
   - **If no existing tests**: Ask: "Should I create a Playwright test?"
   - **If yes on create**: Create the test in the Playwright repo following existing patterns; note that user should run tests to verify

5. **If CWS or Playwright repo not in workspace**
   - Skip Playwright steps after base review
   - Optionally remind: "To get Playwright options, run this command locally with the Playwright repo in your workspace."
