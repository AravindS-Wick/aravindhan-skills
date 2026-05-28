---
name: work-on
description: Start working on a Jira ticket by gathering context (ticket details, branches, PRs) and offering actions. Use when the user runs /work-on, asks to work on a ticket, or wants Jira ticket context and branch/PR info.
---
# Work On

Start working on a Jira ticket by gathering all relevant context (ticket details, related branches, recent PRs) before taking action.

## Overview
Provides comprehensive context about a ticket including its current status, related git branches, recent PRs, and sprint membership. After displaying context, presents interactive options to create a branch, move the ticket status, or just use the context for awareness.

**Default:** Context display with interactive action menu.

## Usage

### By ticket key:
```
/work-on PROJ-1234
```

### By full Jira URL:
```
/work-on https://jira.your-company.com/browse/PROJ-1234
```

### Interactive mode (no params):
```
/work-on
```
Prompts for ticket key or URL.

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `ticket` | Yes* | Ticket key (PROJ-1234) or full Jira URL |

*Required unless using interactive mode

## Steps

### 1. Parse input and extract ticket key
- **If no params provided**: Enter interactive mode
  - Prompt: "Enter ticket key or Jira URL:"
  - Examples: "PROJ-1234", "https://jira.your-company.com/browse/PROJ-1234"
- **If ticket provided**: Extract ticket key
  - Support both `PROJ-1234` format and full URL
  - Validate format matches `[A-Z]+-\d+`
  - Example: Extract "PROJ-1234" from URL
- If invalid format:
  - Show error: "❌ Invalid ticket format. Expected: PROJ-1234 or full Jira URL"
  - Exit

### 2. Authenticate with Jira
- Call `eiam_login()` to get user credentials
- Store `userId` and `userTicket` for subsequent calls

### 3. Fetch ticket details
- Call `jira_search_issues(issueKeys=[ticket])`
- Extract key information:
  - Summary
  - Status
  - Assignee
  - Description (first 200 chars for context)
  - Story points
  - Priority
  - Epic (if linked)
  - Sprint information (if in sprint)
- If ticket not found:
  - Show error: "❌ Ticket {key} not found or not accessible"
  - Suggest: "Check ticket exists at https://jira.your-company.com/browse/{key}"
  - Exit

### 4. Check sprint membership
- If ticket has sprint data in response:
  - Identify active sprint(s)
  - Extract sprint name and dates
  - Calculate sprint progress (days elapsed/total)
- If in active sprint:
  - Flag prominently: "📅 In active sprint: {sprint_name} (Day {X}/{Y})"
- If not in sprint or sprint closed:
  - Note: "⚠️ Not in current sprint"

### 5. Search for related local branches
- Run: `git branch -a --list "*{ticket}*"`
- Parse results:
  - Local branches: `PROJ-1234-feature-name`
  - Remote branches: `origin/PROJ-1234-feature-name`
- Group results:
  - Current branch (if matches)
  - Other local branches
  - Remote-only branches
- For each branch, get metadata:
  - Last commit date: `git log -1 --format="%cr" {branch}`
  - Last commit message: `git log -1 --format="%s" {branch}`
  - Ahead/behind main: `git rev-list --left-right --count main...{branch}`
- Sort by most recently updated

### 6. Search for related PRs
- Run: `gh pr list --search "{ticket} in:title" --state all --limit 10 --json number,title,state,url,author,createdAt,closedAt`
- Filter to last 2 weeks:
  - Calculate cutoff: `today - 14 days`
  - Filter PRs where `createdAt >= cutoff OR closedAt >= cutoff`
- Group by state:
  - Open PRs (highest priority)
  - Recently merged PRs (within 2 weeks)
  - Recently closed PRs (within 2 weeks)
- For each PR, extract:
  - PR number and title
  - Author
  - State (Open/Merged/Closed)
  - Created date (relative, e.g., "3 days ago")
  - Closed/merged date if applicable
- Sort: Open first, then by most recent activity

### 7. Display consolidated context
Format output as clear, scannable markdown:

```markdown
📋 {TICKET}: {Summary}

Status: {status} | Assignee: {assignee} | Story Points: {points} | Priority: {priority}

{Sprint info if applicable}

Description:
{First 200 chars of description}...
[View full: https://jira.your-company.com/browse/{TICKET}]

{Epic info if applicable}

---

🌿 Related Branches ({count}):
{If current branch matches}
  ✓ {branch_name} (current branch)
    Last commit: {message} ({time_ago})
    Status: {X commits ahead, Y commits behind main}

{Other local branches}
  • {branch_name}
    Last commit: {message} ({time_ago})
    Status: {X commits ahead, Y commits behind main}

{Remote-only branches}
  ◦ {branch_name} (remote only)
    Last commit: {message} ({time_ago})

{If no branches found}
  No related branches found

---

🔀 Recent PRs ({count} in last 2 weeks):
{Open PRs}
  🟢 #{number} {title} (Open)
     by {author} • opened {time_ago}
     {url}

{Recently merged PRs}
  ✅ #{number} {title} (Merged)
     by {author} • merged {time_ago}
     {url}

{Recently closed PRs}
  ⚫ #{number} {title} (Closed)
     by {author} • closed {time_ago}
     {url}

{If no PRs found}
  No related PRs in last 2 weeks

---
```

### 8. Present action menu
After displaying context, show interactive options:

```markdown
What would you like to do?

1. Create new branch from latest main
2. Checkout existing branch: {branch_name} (if branches exist)
3. Move ticket to "In Progress" (if not already)
4. View full ticket details (description, acceptance criteria, comments)
5. Nothing - just needed the context

Your choice (1-5):
```

**Menu logic:**
- Option 1: Always available
- Option 2: Only show if related branches exist
  - If multiple branches, show submenu to select which one
  - If current branch matches ticket, note: "(already checked out)"
- Option 3: Only show if ticket not already "In Progress"
  - If already "In Progress", change to "View available transitions"
- Option 4: Always available
- Option 5: Always available

### 9. Handle user selection

#### Option 1: Create new branch
- Prompt: "Enter brief branch description (e.g., 'add-user-dashboard'):"
- Validate input:
  - Convert to kebab-case
  - Remove special characters except hyphens
  - Limit to 50 chars
- Suggested format: `{TICKET}-{description}`
  - Example: `PROJ-1234-add-user-dashboard`
- Confirm with user: "Create branch: {branch_name}? (y/n)"
- If confirmed:
  - Ensure on latest main: `git fetch origin && git checkout main && git pull origin main`
  - Create branch: `git checkout -b {branch_name}`
  - Show: "✅ Created and checked out branch: {branch_name}"
- After branch creation, ask: "Move ticket to 'In Progress'? (y/n)"

#### Option 2: Checkout existing branch
- If multiple branches:
  - Show submenu:
    ```
    Select branch:
    1. {branch_1}
    2. {branch_2}
    ...
    
    Your choice (1-N):
    ```
- Checkout selected branch: `git checkout {branch_name}`
- Check if branch is behind main:
  - If behind: Show warning: "⚠️ Branch is {N} commits behind main. Consider rebasing."
  - Offer: "Rebase onto latest main? (y/n)"
- Show: "✅ Checked out branch: {branch_name}"

#### Option 3: Move ticket to "In Progress"
- Call `getTransitionsForJiraIssue(cloudId, issueIdOrKey=ticket, expand="transitions.fields")` — find the "In Progress" transition ID and discover any required screen fields upfront
- Confirm: "Move {TICKET} from {current_status} to In Progress? (y/n)"
- If confirmed:
  1. **Populate required fields:** For each required field on the transition screen, use a sensible default (e.g., `0` for numeric fields, current user's account ID for assignee/user fields)
  2. **Transition:** Call `transitionJiraIssue(cloudId, issueIdOrKey=ticket, transition={id}, fields={...required_fields})`
  3. **Verify success:** Call `getJiraIssue(cloudId, issueIdOrKey=ticket)` and confirm status changed
  - Show: "✅ Ticket moved to In Progress"
  - Add comment: "Starting work on this ticket"

#### Option 4: View full ticket details
- Call `jira_search_issues(issueKeys=[ticket], includeComments=true)`
- Display full markdown:
  ```markdown
  # {TICKET}: {Summary}
  
  **Status:** {status}
  **Assignee:** {assignee}
  **Reporter:** {reporter}
  **Priority:** {priority}
  **Story Points:** {points}
  **Created:** {date}
  **Updated:** {date}
  
  ## Description
  {Full description with formatting}
  
  ## Acceptance Criteria
  {If present in description}
  
  ## Comments ({count})
  {Recent comments, most recent first}
  
  ---
  {author} • {date}
  {comment text}
  ---
  
  [View in Jira](https://jira.your-company.com/browse/{TICKET})
  ```
- After displaying, return to action menu

#### Option 5: Exit
- Show: "👍 Context provided. Happy coding!"
- Exit gracefully

### 10. Error handling and edge cases

#### Ticket not found:
```
❌ Ticket PROJ-1234 not found or not accessible.

Possible reasons:
• Ticket doesn't exist
• You don't have permission to view it
• Ticket key is misspelled

Try: Check ticket exists at https://jira.your-company.com/browse/PROJ-1234
```

#### Already on matching branch:
```
✓ Already on branch: PROJ-1234-add-user-dashboard

Branch status: 2 commits ahead of main, 0 behind
Last commit: Add user dashboard component (3 hours ago)

{Continue with action menu, but note current state}
```

#### Ticket already In Progress:
```
ℹ️ Ticket is already In Progress (assigned to you)

{Show "View available transitions" instead of "Move to In Progress"}
```

#### No git repository:
```
⚠️ Not in a git repository

Ticket context:
{Show ticket details}

Action menu limited to:
1. View full ticket details
2. Move ticket to "In Progress"
3. Exit
```

#### PR search fails (gh not authenticated):
```
⚠️ Cannot search PRs (gh not authenticated)

Ticket and branch context:
{Show ticket and branch info}

{Continue with action menu, skip PR section}
```

## Validation Rules

### Must validate:
- ✅ Ticket key format is valid (`[A-Z]+-\d+`)
- ✅ Ticket exists and is accessible
- ✅ Git commands available (if showing branch info)
- ✅ User confirms before destructive actions

### Graceful degradation:
- ❌ Don't fail if no branches found (show "No branches")
- ❌ Don't fail if PR search fails (show warning, continue)
- ❌ Don't fail if not in git repo (limit features)
- ❌ Don't fail if sprint info missing (skip sprint section)

## Examples

### Example 1: Starting fresh work
```
User: /work-on MCAUT-7540

AI: Authenticating with Jira...
    Fetching ticket details...
    Searching branches and PRs...
    
    📋 MCAUT-7540: Add trigger filter processing
    
    Status: Open | Assignee: Jane Smith | Story Points: 5 | Priority: P2
    📅 In active sprint: Sprint 15 (Day 8/14)
    
    Description:
    Implement trigger filter processing for advanced
    segmentation in automation workflows...
    [View full: https://jira.your-company.com/browse/MCAUT-7540]
    
    ---
    
    🌿 Related Branches (0):
    No related branches found
    
    ---
    
    🔀 Recent PRs (0):
    No related PRs in last 2 weeks
    
    ---
    
    What would you like to do?
    
    1. Create new branch from latest main
    2. Move ticket to "In Progress"
    3. View full ticket details
    4. Nothing - just needed the context
    
    Your choice (1-4):

User: 1

AI: Enter brief branch description (e.g., 'add-user-dashboard'):

User: trigger-filter-processing

AI: Create branch: MCAUT-7540-trigger-filter-processing? (y/n)

User: y

AI: Fetching latest main...
    ✅ Created and checked out branch: MCAUT-7540-trigger-filter-processing
    
    Move ticket to 'In Progress'? (y/n)

User: y

AI: ✅ Ticket moved to In Progress
    
    👍 All set! Happy coding on MCAUT-7540
```

### Example 2: Continuing work with existing branches
```
User: /work-on AORG-7698

AI: 📋 AORG-7698: Add contact API endpoint
    
    Status: Blocked | Assignee: Sam Chen | Story Points: 8 | Priority: P1
    📅 In active sprint: Sprint 22 (Day 5/14)
    
    Description:
    Create new REST API endpoint for adding contacts to audiences...
    
    ---
    
    🌿 Related Branches (2):
      • AORG-7698-add-contact-endpoint
        Last commit: WIP: Add validation logic (2 days ago)
        Status: 5 commits ahead of main, 2 commits behind
    
      ◦ origin/AORG-7698-initial-implementation (remote only)
        Last commit: Initial endpoint structure (1 week ago)
    
    ---
    
    🔀 Recent PRs (1):
      ⚫ #12892 [AORG-7698] Initial endpoint structure (Closed)
         by Sam Chen • closed 5 days ago
         https://github.your-company.com/mailchimp-monolith/mailchimp/pull/12892
    
    ---
    
    What would you like to do?
    
    1. Create new branch from latest main
    2. Checkout existing branch
    3. View available transitions (ticket is Blocked)
    4. View full ticket details
    5. Nothing - just needed the context
    
    Your choice (1-5):

User: 2

AI: Select branch:
    1. AORG-7698-add-contact-endpoint (local, 2 days old)
    2. origin/AORG-7698-initial-implementation (remote only, 1 week old)
    
    Your choice (1-2):

User: 1

AI: ✅ Checked out branch: AORG-7698-add-contact-endpoint
    
    ⚠️ Branch is 2 commits behind main. Consider rebasing.
    Rebase onto latest main? (y/n)

User: n

AI: 👍 Ready to continue work on AORG-7698
```

### Example 3: Already on matching branch
```
User: /work-on EEE-11054

AI: 📋 EEE-11054: Feature flag setup for email editor
    
    Status: In Progress | Assignee: Taylor Johnson | Story Points: 3
    
    ---
    
    🌿 Related Branches (1):
      ✓ EEE-11054-flag-setup (current branch)
        Last commit: Add feature flag configuration (10 minutes ago)
        Status: 3 commits ahead of main, 0 behind
    
    ---
    
    🔀 Recent PRs (0):
    No related PRs in last 2 weeks
    
    ---
    
    ℹ️ Already working on this ticket!
    • Branch: EEE-11054-flag-setup (current)
    • Status: In Progress
    
    What would you like to do?
    
    1. View available transitions
    2. View full ticket details
    3. Nothing - just needed the context
    
    Your choice (1-3):
```

### Example 4: Ticket not in current sprint
```
User: /work-on FLP-4045

AI: 📋 FLP-4045: Refactor analytics dashboard
    
    Status: Open | Assignee: Unassigned | Story Points: 13
    ⚠️ Not in current sprint
    
    Description:
    Major refactor of analytics dashboard to improve
    performance and data loading...
    
    {Rest of context display}
```

## Notes

- **Context-first approach** - Shows all relevant information before asking for action
- **Non-destructive** - Always confirms before making changes
- **Awareness** - Helps avoid duplicate work by showing existing branches/PRs
- **Sprint-aware** - Highlights if ticket is in active sprint
- **Flexible** - Works with or without git repo, with or without PR access
- **Fast execution** - Typical run time 3-5 seconds

## Branch Naming Convention

Default format: `{TICKET}-{kebab-case-description}`

**Examples:**
- `MCAUT-7527-trigger-filter-processing`
- `AORG-7698-add-contact-api-endpoint`
- `EEE-11054-feature-flag-setup`
- `FLP-4045-analytics-dashboard-refactor`

**Rules:**
- No username prefix
- Kebab-case (lowercase with hyphens)
- Remove special characters except hyphens
- Limit description to 50 chars
- Ticket number always first

## Integration with Other Commands

Works well in sequence with:
1. `/work-on PROJ-1234` - Gather context, create branch, move to In Progress
2. *Do work, make commits*
3. `/pr-create-from-commits` - Create PR from work
4. *After PR merged, ticket automatically closed*

## See Also

- **PR creation**: `.agent/skills/pr-create-from-commits/SKILL.md`
- **Standup**: `.agent/skills/standup/SKILL.md`
- **Git workflows**: `.agent/rules/git-workflows.mdc`

## Changelog

- **v1.1** - Use expand=transitions.fields upfront to discover required screen fields before transitioning; populate with sensible defaults
- **v1.0** - Initial version with context gathering, branch management, and interactive actions
