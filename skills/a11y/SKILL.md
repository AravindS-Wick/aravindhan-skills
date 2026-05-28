---
name: a11y
description: Review and fix accessibility issues (WCAG 2.2 Level AA). Use when the user asks for an accessibility review, runs /a11y, or wants to fix a11y issues in UI components, forms, or pages.
---

# Accessibility Review & Fix

Review and optionally fix accessibility issues. See `.agent/rules/accessibility.mdc` for standards.

## Steps

1. **Determine scope automatically**
   - Check `git status --short` for uncommitted changes
   - **If path provided in command** (e.g., `/a11y path/to/file.js`):
     - Use that specific file/directory
   - **Else if working tree is clean AND file is open**:
     - Auto-review currently open file (no prompt needed)
   - **Else if uncommitted changes exist**:
     - Ask: "Review uncommitted changes or current open file?"
   - **Else** (no file open, no changes):
     - Ask: "What file/directory would you like to review?"

2. **Immediately perform review**
   - Don't prompt for action upfront
   - Always start with review-only mode
   - Show full accessibility report first

3. **Announce scope and start review**
   - **Start with clear scope announcement:**
     ```
     ## Accessibility Review: {filename}
     **Scope:** {scope description}
     **Files:** {list of files}
     **Component Type:** {detected type}
     ```
   - Examples:
     - "**Scope:** Currently open file (working tree clean)"
     - "**Scope:** 3 files with uncommitted changes"
     - "**Scope:** Specific file: path/to/Component.tsx"

4. **Load accessibility context**
   - Reference `.agent/rules/accessibility.mdc` for WCAG 2.2 Level AA standards
   - Reference Intuit's 10 accessibility requirements
   - Check against common patterns (modals, forms, navigation, tables)

5. **Analyze the code**
   - **Detect component type** (form, modal, navigation, table, page-level route, child component, etc.)
   - **Check all 10 Intuit requirements:**
     1. Alt text for images
     2. H tags and skip links
     3. Clear and meaningful link text
     4. Accessible forms (labels, errors, ARIA)
     5. Keyboard accessibility
     6. Accessible data tables
     7. Unique page titles (**ONLY check for page-level/route components** - NOT child or reusable components)
     8. Page zoom (relative font sizes)
     9. Multimedia (captions/transcripts)
     10. Color, contrast & flashing
   - **Common mistakes check:** Missing alt text, divs as buttons, missing labels, insufficient contrast, removed focus outline, no focus management, skipped heading levels, silent dynamic updates, unlabeled icons, ARIA overuse, page title set in child components (should only be in page-level components)

6. **Generate accessibility review report**
   - **CRITICAL:** Output must have blank lines between EVERY section for proper markdown rendering
   - **Format structure with explicit line breaks:**
   
   ```
   ## Accessibility Review: {filename}
   
   **Scope:** {scope description}
   
   **File:** {path}
   
   **Component Type:** {detected type}
   
   ---
   
   ## 🚨 Critical Issues (WCAG Violations)
   
   ### 1. {Issue Title} (Lines X-Y)
   
   **Problem:** {description}
   
   **WCAG:** {criterion violated}
   
   **Current:**
   
   ```{startLine}:{endLine}:{filepath}
   {code}
   ```
   
   **Fix:**
   
   ```{language}
   {corrected code}
   ```
   
   ---
   
   ## ⚠️ High Priority Issues
   
   ### 1. {Issue Title} (Lines X-Y)
   
   **Problem:** {description}
   
   **WCAG:** {criterion violated}
   
   **Current:**
   
   ```{startLine}:{endLine}:{filepath}
   {code}
   ```
   
   **Fix:**
   
   ```{language}
   {corrected code}
   ```
   
   ---
   
   ## 📋 Medium/Low Priority Recommendations
   
   - Brief list item 1
   - Brief list item 2
   
   ---
   
   ## 🎯 Priority Summary
   
   | Priority | Count | Must Fix Before PR |
   |----------|-------|--------------------|
   | Critical | X     | ✅ Yes             |
   | High     | X     | ✅ Yes             |
   | Medium   | X     | ⚠️ Recommended     |
   
   ---
   
   ## 📋 Next Steps
   
   - [ ] Type "yes" to apply auto-fixes
   - [ ] Add jest-axe test if not present
   - [ ] Manual keyboard testing
   - [ ] Screen reader verification
   
   ---
   
   ## Would you like me to auto-fix these issues?
   
   **I can automatically fix:**
   
   - ✅ {Issue 1}
   - ✅ {Issue 2}
   
   **Requires manual review:**
   
   - 💡 {Issue 1} - {reason}
   - 💡 {Issue 2} - {reason}
   
   Type **"yes"** to apply auto-fixes, or **"no"** to skip.
   ```
   
   - **MANDATORY formatting rules (DO NOT SKIP):**
     - ALWAYS add a blank line after every heading (`##` or `###`)
     - ALWAYS add a blank line before and after every `---` separator
     - ALWAYS add a blank line before and after every code block
     - ALWAYS add a blank line before and after every list
     - ALWAYS add a blank line before and after every table
     - Use `##` for major sections, `###` for subsections
     - Use checkboxes `- [ ]` for actionable items
   - **Omit "What's Working Well" section** - focus on issues only
   - **Prioritize output** - Critical and High issues first with full details

7. **Prompt user for auto-fix after showing review**
   - Ask: **"Would you like me to auto-fix these issues?"**
   - Explain what will be fixed automatically vs. what requires manual review
   - Wait for user confirmation before proceeding

8. **If user confirms auto-fix: Categorize and apply fixes**
   - **Categorize findings by safety level:**
     - **Safe auto-fixes:** Missing alt text, missing labels, missing button types, redundant ternaries, self-closing tags
     - **Suggest only:** Focus management, keyboard handlers, ARIA patterns requiring context, color contrast (needs design review), heading hierarchy changes (structural)
   
   - **Apply safe auto-fixes:**
     - Missing alt text: Add `alt=""` for decorative images
     - Missing form labels: Add `<label htmlFor="id">` with sensible text
     - Missing button type: Add `type="button"` to buttons
     - Missing ARIA on icon buttons: Add `aria-label` with descriptive text
     - Redundant boolean ternary: Simplify `{condition ? true : false}` to `{condition}`
     - Self-closing tags: Fix `<Component></Component>` to `<Component />`
     - Missing required/aria-required: Add to form fields
     - Missing aria-invalid on errors: Add when error state exists
   
   - **Generate fix report:**
     ```
     ## Accessibility Auto-Fix: {filename}
     **Scope:** {scope description}
     
     ---
     
     ### ✅ Auto-Fixed Issues ({count})
     
     #### 1. {Issue Title} (Line X) - {Priority}
     **Before:**
     {old code}
     
     **After:**
     {new code}
     
     **WCAG:** {criterion if applicable}
     
     ---
     
     ### 💡 Manual Fixes Required ({count})
     
     #### 1. {Issue Title} (Lines X-Y) - {Priority: Critical/High}
     **Problem:** {description}
     **WCAG:** {criterion violated}
     
     **Suggested Fix:**
     {code example}
     
     **Why manual:** {explanation}
     
     ---
     
     ### 📊 Summary
     | Type | Count | Status |
     |------|-------|--------|
     | Auto-fixed | X | ✅ Applied |
     | Manual required (Critical) | X | ⚠️ Action needed |
     | Manual required (High) | X | ⚠️ Action needed |
     | Suggestions | X | ℹ️ Optional |
     
     ### 📋 Next Steps
     - [ ] Review auto-fixed changes
     - [ ] Address {X} critical manual fixes
     - [ ] Run tests: `npm test {test-file}`
     - [ ] Add jest-axe test if missing
     ```

9. **Apply changes to file**
   - Use search_replace tool for each fix
   - Make one fix at a time
   - Verify each change before moving to next
   - **Batch related fixes** (e.g., all missing alt text in one pass)

10. **Validate changes**
    - Ensure syntax is valid
    - Check imports still work
    - Verify no duplicate attributes added
    - Confirm proper indentation preserved
    - Run linter if applicable

11. **Ask user if they want to commit and create PR**
    - **Prompt:** "Would you like me to commit these changes and create a PR?"
    - If YES, proceed to git workflow
    - If NO, stop here (changes remain uncommitted)

12. **Git workflow** (if user confirms) - Request `["git_write", "network"]` permissions upfront
   - Extract Jira ticket from branch name
   - Check if on feature branch:
     - If on `main`: Create new branch `{ticket-prefix}-{ticket-num}-a11y-{filename}`
     - Example: `XP-1234-a11y-login-page`
   - Stage ONLY modified file(s): `git add {modified_files}`
   - Commit: `"[{TICKET}] Fix accessibility issues in {filename}"`
   - Push to origin

13. **Create PR** (if git workflow completed)
   - **Environment detection:**
     - Try to detect if running in Cloud Workspace (check for `CLOUD_WORKSPACE` env var or test `gh` availability)
     - If `gh pr create` is not available or fails, proceed with manual PR creation flow
   
   - **LOCAL (gh available):**
     - Read `.github/pull_request_template.md` for template structure
     - Create PR: `gh pr create --title "[{TICKET}] Fix accessibility issues in {filename}" --body "{populated_template}" --label a11y-cursor-command`
     - Populate ALL template sections (see below for details)
     - Apply labels: `a11y-cursor-command`, `accessibility`
     - Submit as regular PR (not draft)
   
   - **CLOUD WORKSPACE or gh unavailable:**
     - Read `.github/pull_request_template.md` for template structure
     - Prepare populated PR template body (see below for details)
     - Display to user:
       ```
       ## ✅ Changes Committed and Pushed
       
       Branch: {branch-name}
       Commit: [{TICKET}] Fix accessibility issues in {filename}
       
       ## 📝 Create PR Manually
       
       **Cloud Workspace Limitation:** PR creation via CLI is not supported.
       
       **Click here to create PR:**
       https://github.your-company.com/mailchimp-monolith/mailchimp/compare/main...{branch-name}?expand=1
       
       **PR Title (copy this):**
       [{TICKET}] Fix accessibility issues in {filename}
       
       **PR Body (copy this):**
       {populated_template}
       
       **Labels to add:** `a11y-cursor-command`, `accessibility`
       ```
   
   - **Template sections to populate** (for both local and cloud):
     - **Background context:** Accessibility audit findings, WCAG compliance requirements
     - **Change summary:** List of fixed issues (Critical, High, Medium) with before/after
     - **Steps to test:** 
       - Test with keyboard navigation (Tab, Enter, Escape)
       - Test with screen reader (VoiceOver on macOS, NVDA on Windows)
       - Test at 200% browser zoom
       - Verify color contrast with browser tools
     - **Risk mitigation table:**
       - 🚩 Flag/Experiment name: N/A (accessibility fix)
       - 🌊 Splatter zone: "{component/page name} - visual/markup changes only"
       - 👀 Monitoring: Manual accessibility testing, jest-axe tests
       - 💬 Slack Channel: #mc-accessibility or {team_channel}
       - 🎟️ Jira ticket: https://jira.your-company.com/browse/{TICKET}

14. **Generate final checklist**
    - Show user remaining manual tasks:
      ```markdown
      ## ✅ Auto-Fixed Issues ({count})
      
      - [x] {Issue 1}
      - [x] {Issue 2}
      
      ## ⚠️ Manual Fixes Required ({count})
      
      - [ ] {Issue 1} - See PR description for details
      - [ ] {Issue 2} - See PR description for details
      
      ## 🧪 Testing Checklist
      
      - [ ] Keyboard navigation test
      - [ ] Screen reader test (VoiceOver/NVDA)
      - [ ] 200% zoom test
      - [ ] Color contrast verification
      - [ ] Add jest-axe test if missing
      
      ## 📎 PR Created
      
      PR #{pr_number}: {pr_url}
      ```

## Safety Rules (Auto-fix mode)

**Always auto-fix:**
- Empty alt text for decorative images
- Missing form field labels (with sensible defaults)
- Missing button types
- Missing aria-label on icon-only buttons
- Boolean ternary simplification
- Self-closing tag syntax

**Never auto-fix (suggest only):**
- Focus management logic (requires understanding flow)
- Keyboard event handlers (requires context)
- Complex ARIA patterns (role="dialog", aria-activedescendant, etc.)
- Color contrast issues (requires design review)
- Heading hierarchy changes (structural/content decision)
- Content/copy changes (requires product review)
- Removing functionality (always additive changes only)
- Page title additions (only suggest for page-level/route components, never for child or reusable components)

## Validation Checklist

Before submitting PR, verify:
- [ ] All Critical and High priority issues addressed
- [ ] Auto-fixed changes are syntactically correct
- [ ] No duplicate attributes added
- [ ] Manual fixes documented in PR description
- [ ] jest-axe test added/updated if applicable
- [ ] Keyboard navigation tested
- [ ] Screen reader tested (VoiceOver or NVDA)
- [ ] 200% zoom tested
- [ ] Color contrast verified
- [ ] PR has `a11y-cursor-command` and `accessibility` labels

## Notes

- **Streamlined workflow** - Auto-reviews open file when working tree is clean, then prompts for fixes
- **Context-aware** - Automatically detects forms, modals, navigation patterns
- **WCAG 2.2 Level AA** - Follows Intuit standard
- **jest-axe integration** - Mentions existing automated tests (6.0.1)
- **Review-first approach** - Always shows report before applying any changes
- **Safe auto-fixes** - Only applies non-breaking changes automatically
- **Full git workflow** - Optionally commits, pushes, and creates PR with proper labels
- **PR template** - Populates all sections with accessibility-specific content
- **Cloud Workspace compatible** - Detects environment and provides manual PR creation flow when `gh` CLI is unavailable

## See Also

- `.agent/rules/accessibility.mdc` - Complete accessibility guide with WCAG standards
- `web-config/test/setupTests.js` - jest-axe configuration
- [WCAG 2.2 Quick Reference](https://www.w3.org/WAI/WCAG22/quickref/)
- [Intuit Accessibility Guidelines](https://wiki.your-company.com/pages/viewpage.action?spaceKey=standards&title=Accessibility)
- `#mc-design-system-cmty` Slack channel - Design system and component questions
- `#mc-accessibility` Slack channel - Accessibility questions and support

