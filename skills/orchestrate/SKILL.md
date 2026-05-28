---
name: orchestrate
description: Manage and execute tasks for orchestrate.
  Use when starting a sprint, planning a full feature end-to-end, running pre-release
  checks, doing weekly or monthly reviews, or building a new component — automatically
  routes to and coordinates the correct skills for each development phase.
---
# Orchestrate — Command Center

Routes to the right skills automatically. One command, correct team assembled.

## Quick Start

```bash
/orchestrate --phase=feature            # Plan a new feature
/orchestrate --phase=sprint-start       # Kick off a sprint
/orchestrate --phase=sprint-end         # Sprint wrap-up + retrospective
/orchestrate --phase=pre-release        # Pre-launch full check
/orchestrate --phase=weekly-review      # Weekly health check
/orchestrate --phase=monthly-strategy   # Monthly strategic review
/orchestrate --phase=component-build    # Build a new component
```

## Phases → Skills Mapping

### `--phase=feature` (Plan a new feature)
```
Runs in parallel:
├─ /po-guide --feature=user-stories       (What + acceptance criteria)
├─ /dev-assistant --feature=decompose     (How to break it down)
└─ /product-designer --feature=component  (How it looks/behaves)

Token estimate: ~900-1,400 total
Time: 3-5 min (parallel)
Output: User story + task breakdown + design spec
```

### `--phase=sprint-start` (Monday morning)
```
Runs in parallel:
├─ /po-guide --feature=sprint-risk        (Risk prediction)
├─ /sprint-commander --feature=planning   (Capacity + scope)
└─ /dev-assistant --feature=architecture  (Tech decisions for sprint)

Token estimate: ~800-1,200 total
Time: 3-5 min (parallel)
Output: Sprint plan + risks + architecture notes
```

### `--phase=sprint-end` (Friday)
```
Runs in parallel:
├─ /sprint-commander --feature=retrospective  (What happened)
├─ /biz-analyst --feature=metrics             (Did numbers move?)
└─ /qa-automation --feature=coverage          (Is quality maintained?)

Token estimate: ~700-1,000 total
Time: 3-5 min (parallel)
Output: Retro summary + metrics update + coverage report
```

### `--phase=pre-release` (Before shipping)
```
Runs sequentially (order matters):
├─ /test-global --full                         (All tests pass)
├─ /pr-check --full                            (Security + quality gates)
├─ /qa-automation --feature=e2e                (E2E test plan)
├─ /marketing-strategist --feature=launch      (Launch checklist)
└─ /biz-analyst --feature=metrics              (KPIs to track)

Token estimate: ~3,000-5,000 total
Time: 15-30 min (mix parallel + sequential)
Output: Ship/no-ship decision + launch plan + metrics setup
```

### `--phase=weekly-review` (Every Monday)
```
Runs in parallel:
├─ /sprint-commander --feature=velocity    (Are we on track?)
├─ /biz-analyst --feature=metrics          (KPI snapshot)
└─ /po-guide --feature=prioritize          (What's next priority?)

Token estimate: ~500-800 total
Time: 2-3 min (parallel)
Output: Weekly health dashboard
```

### `--phase=monthly-strategy` (First Monday of month)
```
Runs in parallel:
├─ /market-researcher --feature=competitors  (Market moves)
├─ /biz-analyst --feature=forecast           (Revenue forecast update)
├─ /marketing-strategist --feature=content   (Content calendar)
└─ /po-guide --feature=roadmap               (Roadmap adjustment)

Token estimate: ~1,500-2,500 total
Time: 5-10 min (parallel)
Output: Monthly strategy brief
```

### `--phase=component-build` (New component)
```
Runs in parallel:
├─ /product-designer --feature=component    (Design spec)
├─ /dev-assistant --feature=patterns        (Implementation patterns)
└─ /qa-automation --feature=unit-stubs      (Test boilerplate)

Then sequentially:
├─ /lite-superpowers --generate --feature=code (Scaffold code)
└─ /product-designer --feature=accessibility   (A11y check)

Token estimate: ~1,200-2,000 total
Time: 5-8 min
Output: Full component spec + scaffold + tests
```

## Custom Phases

```bash
# Combine any skills manually
/orchestrate --skills="dev-assistant,qa-automation" --context="Review auth module"

# Run specific skill with orchestrator routing
/orchestrate --ask="Is this feature technically feasible?"
# → Routes to /dev-assistant automatically

/orchestrate --ask="What should we build next sprint?"
# → Routes to /po-guide + /sprint-commander
```

## Memory System

After each `/orchestrate` run:
- Updates session memory file (async)
- Records: phase run, decisions made, blockers, next actions
- Next session picks up where this left off

```
Memory path: ~/.claude/projects/.../memory/
├─ project.md        (current project state)
├─ sprint.md         (current sprint + velocity)
├─ decisions.md      (architectural + product decisions)
├─ blockers.md       (known blockers + resolutions)
└─ metrics.md        (KPI snapshots, dated)
```

## Token Budget by Phase

| Phase | Skills Run | Est. Tokens | When |
|-------|-----------|-------------|------|
| `feature` | 3 parallel | 900-1,400 | Per feature |
| `sprint-start` | 3 parallel | 800-1,200 | Weekly |
| `sprint-end` | 3 parallel | 700-1,000 | Weekly |
| `pre-release` | 5 sequential | 3,000-5,000 | Per release |
| `weekly-review` | 3 parallel | 500-800 | Weekly |
| `monthly-strategy` | 4 parallel | 1,500-2,500 | Monthly |
| `component-build` | 5 mixed | 1,200-2,000 | Per component |

**Monthly total (typical usage):** ~8,000-15,000 tokens  
**vs. superpowers (same usage):** ~50,000-80,000 tokens  
**Savings: ~80% ↓**

---

**Token avg:** 500-5,000 per phase | **Smart routing:** Only runs what's needed
