---
name: po-guide
description: Manage and execute tasks for po-guide.
  Use when writing user stories (As a/I want/So that), creating Given/When/Then acceptance
  criteria, prioritizing backlog with RICE or MoSCoW scoring, predicting sprint risks,
  or translating stakeholder requirements into engineering tasks.
---
# Product Owner Guide

AI Product Owner — backlog management, user stories, prioritization, sprint planning.

## Quick Start

```bash
/po-guide                                   # Review current sprint/backlog context
/po-guide --feature=user-stories            # Generate user stories
/po-guide --feature=acceptance-criteria     # Write acceptance criteria
/po-guide --feature=prioritize              # Prioritize backlog (MoSCoW/RICE)
/po-guide --feature=roadmap                 # Feature roadmap planning
/po-guide --feature=sprint-risk             # Sprint risk prediction
/po-guide --feature=stakeholder             # Stakeholder communication draft
```

## Features

| Feature | What it does | Tokens |
|---------|-------------|--------|
| `user-stories` | Generate As a/I want/So that stories | 200-400 |
| `acceptance-criteria` | Given/When/Then AC for stories | 200-300 |
| `prioritize` | RICE/MoSCoW scoring + rationale | 300-400 |
| `roadmap` | Quarterly/monthly feature roadmap | 400-600 |
| `sprint-risk` | Blockers, dependencies, capacity risks | 200-400 |
| `stakeholder` | Status update / release notes draft | 200-300 |

## User Stories Generation

```bash
/po-guide --feature=user-stories --context="Add dark mode support"
```

**Output:**
```
## User Story: Dark Mode

**Story:** As a user, I want to switch to dark mode
so that I can reduce eye strain in low-light environments.

**Acceptance Criteria:**
- Given I'm on any page, when I click the theme toggle, then the UI switches to dark
- Given dark mode is active, when I refresh, then dark mode persists
- Given I'm using assistive tech, when dark mode activates, then contrast ratio ≥ 4.5:1

**Story Points:** 3
**Priority:** Medium
**Dependencies:** Token system (--av-theme-* variables)
```

## Sprint Risk Prediction

```bash
/po-guide --feature=sprint-risk
```

Analyzes:
- Open PRs blocking sprint items
- Dependency chains between tasks
- Team capacity vs committed scope
- Historical velocity vs current plan
- External blockers (API changes, third-party deps)

Output: Risk register with mitigation steps

## Backlog Prioritization (RICE)

```
Reach × Impact × Confidence ÷ Effort = Score

Feature A: 500 × 3 × 0.8 ÷ 2 = 600
Feature B: 200 × 2 × 0.9 ÷ 1 = 360
Feature C: 1000 × 1 × 0.5 ÷ 8 = 62.5

Recommendation: Ship A → B → (defer C)
```

## Memory Updates

After each session, updates:
- Sprint goals and commitments
- Backlog priority decisions
- Stakeholder feedback captured
- Risks identified and mitigations

## Integration

```
/dev-assistant --feature=decompose   # Break PO stories into dev tasks
/sprint-commander --feature=planning # Sprint planning with stories
/orchestrate --phase=sprint-start    # Full sprint kickoff workflow
```

---

**Token avg:** 200-500 per feature | **Framework:** Agile/Scrum/Kanban
