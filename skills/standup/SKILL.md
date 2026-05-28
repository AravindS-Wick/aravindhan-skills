---
name: standup
description: Generate sprint summary for team standups with state changes and stagnant tickets. Use when the user runs /standup, asks for a standup report, or wants sprint summary for a JIRA board.
---
# Standup

Generate sprint summary for team standups with focus on state changes and stagnant tickets.

## Overview
Analyzes active sprint tickets with focus on state changes, stale/blocked items, and team velocity. Provides detailed narrative with wins, concerns, and patterns. Works with any Mailchimp board through dynamic discovery - no configuration needed.

**Default:** Inline output with option to create gist.

## Usage

### Interactive search:
```
/standup
```
Prompts for team/board name, searches JIRA, lets you select from results.

### Quick search by name:
```
/standup XP
/standup "DB Engineering"
/standup Commerce
```
Searches boards matching the term, auto-selects if only one found.

### Direct board ID:
```
/standup 51025
```
Uses board ID directly (power user mode).

### With options:
```
/standup XP stale=45
/standup 51025 focus=blockers
/standup Commerce format=gist
/standup XP format=slack
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `stale` | 30 | Days to flag tickets as stale (⚠️ warning) |
| `critical` | 60 | Days to flag tickets as critical (🚨 urgent) |
| `focus` | all | Focus mode: `all`, `blockers`, `stale`, `changes`, `unassigned` |
| `format` | markdown | Output format: `markdown` (inline), `gist`, `slack`, `csv` |

## Steps

### 1. Parse input and determine search strategy
- **If no input provided**: Prompt user for search term
  - Ask: "Enter team name, board name, project key, or board ID:"
  - Examples: "XP", "Database", "Commerce", "51025"
- **If input is numeric** (e.g., "51025"): Treat as board ID, skip search
- **If input is text** (e.g., "XP", "DB Engineering"): Search boards by name

### 2. Search JIRA boards (if needed)
- Call `get_boards(name=search_term)`
- For each board result, check for active sprint:
  - Call `get_board_sprints(boardId, state='active')`
  - Mark boards with active sprints (✅) vs without (⚠️)
- Sort results:
  - Priority 1: Boards with active sprints (scrum boards)
  - Priority 2: Boards without active sprints
  - Within each group: Alphabetically by name
- Display results as numbered menu:
  ```
  Found N boards matching 'XP':
  
   1  XP Team Board                      ✅ Sprint 12 active
      Board: 51025 | Project: XP | Scrum
      
   2  Expert Experience                  ✅ Sprint 8 active  
      Board: 14593 | Project: EXPXP | Scrum
      
   3  XP Planning Board                  ⚠️ No active sprint
      Board: 52341 | Project: XP | Kanban
  
  Select board (1-3):
  ```

### 3. Handle search results
- **0 results**: 
  - Show: "No boards found for '{search_term}'. Try different spelling, project key (XP, MCDBEN), or partial board name."
  - Prompt to search again or exit
- **1 result**: 
  - Auto-select and show confirmation: "Using board: {name} ({id})"
  - Proceed to sprint fetch
- **2+ results**: 
  - Show numbered menu
  - Prompt user: "Select board (1-N):"
  - Validate selection is valid number

### 4. Validate board and get active sprint
- If board has no active sprint:
  - Show: "⚠️ Board '{name}' has no active sprint."
  - Offer options:
    ```
    Recent sprints:
    • Sprint 11 (Closed Dec 26)
    • Sprint 10 (Closed Dec 13)
    
    Analyze most recent closed sprint? (y/n):
    ```
  - If user declines: Exit gracefully
  - If yes: Use most recent closed sprint
- If multiple active sprints (rare):
  - Show list, prompt user to select
- Extract sprint metadata:
  - Sprint name, ID
  - Start date, end date
  - Days elapsed (today - start date)
  - Total days (end - start)
  - Sprint goal (if any)

### 5. Fetch sprint issues with state history
- Call `get_board_issues(boardId, sprintId)` with:
  - `fields`: ["key", "summary", "status", "priority", "issuetype", "assignee", "created", "updated", "storyPoints"]
  - `includeChangelog`: true (critical for state analysis)
  - `maxResults`: 50
- If total > 50: Paginate with `startAt` parameter
- For each issue, parse changelog for status field changes

### 6. Analyze state changes and patterns
For each issue:
- **Calculate days in current state**:
  - Find most recent status change in changelog
  - Days = (now - last_status_change_date)
  - If no changelog: Days = (now - created_date)
- **Track complete state history**:
  - Record all status transitions with dates
  - Calculate total time in each previous state
  - Identify if recently unblocked (e.g., "234 days blocked → NOW ACTIVE")
- **Count state transitions**: Total status field changes
- **Detect patterns**:
  - QA loop: >3 transitions between "In Progress" ↔ "Verify"
  - Backward movement: Any transition to less advanced state (In Progress → Open)
  - Long blocked: "Blocked" status for >14 days
  - Recent wins: Tickets unblocked or completed in last 7 days
  - Ancient tickets: >90 days in any state
  - Sprint carryover: Tickets appearing in multiple sprints
- **Flag severity**:
  - 🚨 Critical: >60 days (or custom critical threshold)
  - ⚠️ Warning: >30 days (or custom stale threshold)
  - ✅ Normal: <30 days
  - 🎉 Win: Recently unblocked after long period

### 7. Group and organize data
- **Primary grouping**: By assignee (alphabetically)
  - "Unassigned" group if assignee is null
  - Within each assignee: Sort by days in state (descending)
- **Create focused views**:
  - Critical issues section: All tickets >60 days
  - Blocked tickets section: All "Blocked" status with duration
  - Unassigned section: All tickets without assignee
- **Calculate sprint metrics**:
  - Total tickets in sprint
  - By status: Open, In Progress, Verify, Blocked, Closed
  - WIP percentage: (In Progress + Verify) / Total
  - Completion rate: Closed / Total
  - Days remaining in sprint

### 8. Generate markdown output
Create comprehensive markdown with narrative style:

#### **Header Section:**
```markdown
# 🎯 {Board Name} Sprint Summary: Sprint {Name}

**Sprint Period:** {start_date} - {end_date} ({total_days} days)
**Current Day:** {today} (Day {elapsed}/{total})
**Total Issues:** {count} tickets
**Board:** [Board Link](https://jira.your-company.com/secure/RapidBoard.jspa?rapidView={boardId}) | **Project:** {projectKey}
```

#### **Summary by Assignee (Alphabetically):**
For each assignee, create section with:
- **Table format**:
  - Ticket (clickable link)
  - Summary
  - Status
  - Days in State
  - Last Change (date)
  - Activity Pattern / Notes
- **Status narrative**: Summary of assignee's work with concerns/wins
- **State change history**: For tickets with interesting patterns
  - "234 days blocked → NOW ACTIVE ✅" (recently unblocked)
  - "In Progress → Open" (backward movement)
  - "Multiple verify toggles" (QA loop)
- **Epic focus**: If assignee working on specific epic

#### **Critical Issues Section:**
- Top 5-6 longest stuck tickets with detailed history
- Show complete state transition narrative
- Highlight recent wins (unblocks)
- Flag critical blockers requiring escalation

#### **State Change Patterns Section:**
- Tickets with frequent transitions (QA loops)
- Backward movement examples
- Tickets spanning multiple sprints
- Pattern analysis with recommendations

#### **Sprint Metrics Section:**
- Status breakdown table
- By Epic breakdown
- By Priority breakdown

#### **Key Insights & Concerns:**
- 🎉 Wins This Week (completions, unblocks)
- ⚠️ Areas of Concern (ancient tickets, high WIP, blockers)
- Narrative analysis of patterns

#### **Recommended Actions:**
- Immediate actions (before sprint end)
- Sprint retrospective topics
- Sprint health indicators table

#### **Team Velocity Section:**
- Most active contributors
- Specialist focus areas

#### **Historical Context:**
- Tickets spanning multiple sprints
- Pattern notes about long-running work

### 9. Output the report (format-dependent)
- **markdown (default)**: Display full report inline in chat
- **gist**: Create shareable gist
  - Write markdown to temporary file: `/tmp/standup-{projectKey}-{YYYY-MM-DD}.md`
  - Create gist using gh CLI:
    ```bash
    gh gist create /tmp/standup-{projectKey}-{date}.md \
      --desc "{Board Name} Standup - Sprint {N} - {date}" \
      --public
    ```
  - Display gist URL and inline summary
- **slack**: Format condensed version for Slack, offer gist option
- **csv**: Export CSV file to `/tmp/standup-{projectKey}-{date}.csv`

### 10. Detect Slack channel (heuristic)
Use pattern matching to suggest channel:
- Project "XP" → "#xp-team"
- Project contains "DBEN" → "#dbeng-help"  
- Board name contains "Commerce" → "#mc-commerce"
- Board name contains "Mobile" → "#mc-mobile"
- Board name contains "Analytics" → "#mc-analytics"
- Fallback: "#mc-{projectKey-lowercase}"

Display as: "**Suggested Channel:** {channel_name}"

### 11. Handle focus modes
If `focus` parameter provided:
- **blockers**: Filter to show only "Blocked" status tickets
- **stale**: Filter to show only tickets >stale_threshold days
- **changes**: Show only tickets that changed state in last 7 days
- **unassigned**: Show only tickets without assignee
- **all** (default): Show everything

### 12. Handle output formats
- **markdown** (default): Display full markdown inline in chat
  - Complete narrative with all sections
  - Formatted tables with emojis
  - Clickable JIRA links
  - No gist creation (faster, cleaner)
- **gist**: Create GitHub gist and display summary
  - Write to `/tmp/standup-{projectKey}-{date}.md`
  - Create public gist with gh CLI
  - Display gist URL + condensed summary inline
- **slack**: Format with Slack markdown (condensed):
  ```
  📊 *{Board} Sprint {N} Standup*
  📅 Sprint: {dates} (Day {X}/{Y})
  
  🎯 *Sprint Health*
  • In Progress: X tickets (Y%)
  • Blocked: X tickets
  
  🚨 *Critical*
  • <link|TICKET> - X days stuck
  
  💬 Share in: {channel}
  ```
  - Offer: "Create gist for full details? (y/n)"
- **csv**: Export as CSV with columns: Ticket, Summary, Status, Assignee, Days in State, Priority, Epic, State Transitions, Days Blocked (if applicable)

## Validation Rules

### Must validate:
- ✅ Board exists and is accessible
- ✅ Board has at least one sprint (active or recent)
- ✅ Sprint has at least 1 ticket
- ✅ Search term produces results (or prompt to retry)

### Graceful degradation:
- ❌ Don't fail if changelog is empty (use created date)
- ❌ Don't fail if assignee is null (group as "Unassigned")
- ❌ Don't fail if sprint has no goal (show "No goal set")
- ❌ Don't fail on large sprints (paginate, show progress)

## Examples

### Example 1: Interactive discovery (inline output)
```
User: /standup

AI: Enter team name, board name, project key, or board ID:
    Examples: "XP", "Database", "Commerce", "51025"

User: XP

AI: Searching boards for 'XP'...
    
    Found 2 boards:
    1. XP Team Board (51025) ✅ Sprint 12 active
    2. XP Planning Board (52341) ⚠️ No active sprint
    
    Select (1-2):

User: 1

AI: Using board: XP Team Board (51025)
    Active sprint: XP Sprint 12 FY26 (Dec 29 - Jan 9)
    Analyzing 74 tickets...
    
    [Full markdown report displayed inline]
    
    💬 Share in: #xp-team
    📎 Want a gist? Use: /standup 51025 format=gist
```

### Example 2: Quick search (inline output)
```
User: /standup XP

AI: Found board: XP Team Board (51025)
    Active sprint: XP Sprint 12 FY26
    Analyzing 74 tickets...
    
    [Full markdown report displayed inline with all sections]
    
    💬 Share in: #xp-team
    📎 Want to create a gist? Add format=gist
```

### Example 3: Direct board ID with gist
```
User: /standup 51025 format=gist

AI: Board: XP Team Board
    Sprint: XP Sprint 12 FY26 (Day 10/12)
    Analyzing 74 tickets...
    
    ✅ Created gist: https://github.your-company.com/gist/...
    
    [Condensed summary displayed inline]
```

### Example 4: Focus on blockers (inline)
```
User: /standup XP focus=blockers

AI: XP Team Board - Sprint 12
    
    [Detailed report showing only blocked tickets with full context]
    
    🚨 **2 Blocked Tickets:**
    
    1. [XP-5479] Create audience/add-contact endpoint (Elina)
       - Status: Blocked for 36 days (since Dec 2, 2025)
       - History: Open → In Progress (19 days) → Blocked (36 days)
       - Action: Needs unblocking or reassignment
    
    2. [XP-5506] Lazy Load Checkout/UpgradeMoment (George)
       - Status: Blocked for 28 days (since Dec 8, 2025)
       - History: Open → In Progress (5 days) → Blocked (28 days)
       - Action: Identify blocking dependency
```

## Error Handling

### No boards found:
```
No boards found for '{search_term}'.

Try:
• Different spelling (e.g., "Experience" vs "XP")
• Project key (XP, MCDBEN, MCCOM)
• Partial board name
• Board ID if you know it (e.g., 51025)

Search again? (y/n):
```

### No active sprint:
```
⚠️ Board 'XP Team Board' has no active sprint.

Recent closed sprints:
• Sprint 11 (Ended Jan 5, 2026)
• Sprint 10 (Ended Dec 15, 2025)

Options:
1. Analyze most recent sprint (Sprint 11)
2. Search for different board
3. Exit

Choose (1-3):
```

### Board not accessible:
```
❌ Cannot access board {id}. 

Possible reasons:
• Board doesn't exist
• You don't have permission
• Board ID is incorrect

Try searching by team name instead of board ID.
```

## Enhanced State Analysis

### Calculating State Transition Narratives
For tickets with interesting history, create narratives:

**Pattern 1: Recently Unblocked (Win!)**
```
🎉 Unblocked after 234 days!
History: Blocked May 16 → Unblocked Jan 5 (8 months)
Status: Now In Progress (2 days)
```

**Pattern 2: QA Loop**
```
Multiple verify toggles
State Changes: 10 transitions since Jun 2025
Pattern: In Progress ↔ Verify cycling (4 times)
Suggests: Acceptance criteria or edge case issues
```

**Pattern 3: Backward Movement**
```
Moved back to Open
History: Open → In Progress (25 days) → Open (5 days)
Concern: Why moved backward? Scope change or blocked?
```

**Pattern 4: Ancient Stuck**
```
🚨 CRITICAL - 108 days In Progress
Last Activity: Sep 19, 2025 (no update 3.5 months)
Action Needed: Escalate or reassign immediately
```

### Detecting Major Wins
Look for:
- Tickets blocked >60 days that recently unblocked
- Burst of completions (3+ tickets closed in 3 days)
- Long-running tickets finally completed
- P0/P1 items moving to Verify/Closed

### Pattern Detection Rules
- **QA Loop**: >3 status transitions with In Progress ↔ Verify
- **Backward Movement**: Any transition to "earlier" state (map: Closed > Verify > In Progress > Open > Backlog)
- **Ancient Blocker**: Ticket blocked or in same state >90 days
- **Sprint Carryover**: Ticket in >3 sprints
- **Velocity Burst**: Assignee closes 3+ tickets in one week

## Notes

- **Zero configuration** - works immediately with any Mailchimp board
- **Self-discovering** - finds boards and sprints automatically  
- **Maintenance-free** - no registry files to update
- **Fast execution** - ~5-10 seconds for typical sprint (50-100 tickets)
- **Rich narrative** - celebrates wins, identifies concerns, detects patterns
- **Cross-team compatible** - works for XP, DB Eng, Commerce, Mobile, etc.
- **Default inline** - faster, cleaner output without gist creation

## Output Sample

The generated report includes:

### **Main Sections:**
1. **Sprint Overview** - Dates, progress, board link
2. **Summary by Assignee** - Detailed tables with state history
3. **Critical Issues** - Top 5-6 longest stuck with narrative
4. **State Change Patterns** - QA loops, backward movement analysis
5. **Sprint Metrics** - Status/Epic/Priority breakdown
6. **Key Insights & Concerns** - Wins and risks with narrative
7. **Recommended Actions** - Immediate and retrospective items
8. **Team Velocity** - Contributor analysis and focus areas
9. **Historical Context** - Multi-sprint tickets and patterns

### **Key Features:**
- ✅ Celebrates wins (unblocks, completions, velocity)
- 🚨 Highlights critical issues with escalation recommendations
- 📊 Pattern detection (QA loops, backward movement, ancient tickets)
- 📈 State transition history (e.g., "234 days blocked → NOW ACTIVE")
- 🎯 Actionable recommendations for team
- 📅 Historical context for long-running work

All JIRA ticket IDs are clickable links to actual tickets.

## See Also

- **Reference format**: https://github.your-company.com/gist/99aed799682fc39ebee01a9f4277e495 (model for output style)
- **Related ticket**: https://jira.your-company.com/browse/XP-5799

## Changelog

- **v2.0** - Default to inline markdown output (gist optional), enhanced state change narratives, celebration of wins, pattern analysis matching reference gist format
- **v1.0** - Initial version with gist-first output

