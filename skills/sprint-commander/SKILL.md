---
name: sprint-commander
description: >
  Use when planning a sprint, forecasting velocity based on historical data, running
  retrospectives, identifying long-running PRs or blocked tasks, or mapping task
  dependencies to sequence work across a sprint.
---

# Sprint Commander

AI Scrum Master — sprint ceremonies, velocity, blockers, retrospectives.

## Quick Start

```bash
/sprint-commander                           # Sprint health snapshot
/sprint-commander --feature=planning        # Sprint planning session
/sprint-commander --feature=retrospective   # Retrospective analysis
/sprint-commander --feature=blockers        # Identify + resolve blockers
/sprint-commander --feature=velocity        # Velocity forecast
/sprint-commander --feature=standup         # Daily standup summary
/sprint-commander --feature=dependencies    # Map task dependencies
```

## Features

| Feature | What it does | Tokens |
|---------|-------------|--------|
| `planning` | Sprint scope, estimates, capacity | 300-500 |
| `retrospective` | Retro analysis, patterns, actions | 300-400 |
| `blockers` | Identify blockers + resolution paths | 200-300 |
| `velocity` | Forecast based on historical data | 200-300 |
| `standup` | Async standup summary/format | 100-200 |
| `dependencies` | Map and sequence task dependencies | 200-300 |

## Sprint Planning

```bash
/sprint-commander --feature=planning --sprint=8
```

**Output:**
```
## Sprint 8 Planning

### Capacity
- Available: 32 story points (8 days × 4 SP/day)
- Recommended commit: 28 SP (15% buffer)

### Recommended Sprint Backlog
1. feat/auth-oauth [8 SP] — High priority, no blockers
2. fix/modal-a11y [3 SP] — Low risk
3. feat/color-tokens [5 SP] — Medium risk (design dep)
4. chore/update-deps [2 SP] — Quick win

### Risks
⚠️ feat/color-tokens depends on design review (not scheduled)
   → Schedule design sync Day 1 or defer to Sprint 9

### Definition of Done
- Tests pass, coverage ≥85%, PR reviewed, STATUS.md updated
```

## Retrospective Analysis

```bash
/sprint-commander --feature=retrospective
```

Synthesizes from git log + STATUS.md:
- What went well (velocity, quality, shipping)
- What didn't (blockers, delays, tech debt added)
- Patterns (recurring issues, systemic problems)
- Action items with owners + deadlines

## Velocity Forecasting

Uses:
- Last 3-5 sprints average velocity
- Current sprint commitment
- Team capacity changes
- Predicts: completion probability, risk areas

## Blocker Resolution

```bash
/sprint-commander --feature=blockers
```

Identifies from code state:
- Long-running PRs (>2 days without review)
- Failing CI blocking merges
- Dependency tasks not started
- Missing approvals

For each: Suggests resolution path + who to ping

## Memory Updates

After each session, updates:
- Sprint number + goal
- Velocity data point
- Retrospective action items
- Recurring blockers tracked

## Integration

```
/po-guide --feature=sprint-risk         # PO risk assessment
/dev-assistant --feature=decompose      # Break down large items
/orchestrate --phase=sprint-start       # Full sprint kickoff
```

---

**Token avg:** 150-400 per feature | **Cadence:** Weekly sprints
