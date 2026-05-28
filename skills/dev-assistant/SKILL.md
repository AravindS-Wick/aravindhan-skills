---
name: dev-assistant
description: >
  Use when designing system architecture, choosing design patterns, reviewing API contracts,
  analyzing coupling or over-engineering, or decomposing a complex feature into parallel
  implementation tasks for any language or stack.
---

# Senior Dev Assistant

Senior full-stack perspective on architecture, patterns, and engineering decisions.

## Quick Start

```bash
/dev-assistant                              # Analyze current context
/dev-assistant --feature=architecture       # Architecture review
/dev-assistant --feature=patterns           # Design patterns
/dev-assistant --feature=api-design         # API design review
/dev-assistant --feature=decompose          # Break feature into parallel tasks
/dev-assistant --feature=review             # Code review with senior lens
/dev-assistant --feature=performance        # Performance analysis
/dev-assistant --feature=best-practices     # Language/stack best practices
```

## Features

| Feature | What it does | Tokens |
|---------|-------------|--------|
| `architecture` | Review structure, dependencies, coupling | 300-500 |
| `patterns` | Identify/suggest design patterns | 200-400 |
| `api-design` | RESTful/GraphQL/RPC consistency check | 200-400 |
| `decompose` | Split feature into parallel sub-tasks | 200-300 |
| `review` | Senior code review with rationale | 300-500 |
| `performance` | O(n) complexity + bottleneck analysis | 300-400 |
| `best-practices` | Language-specific modern standards | 200-300 |

## What It Does

### Architecture Review
- Identifies coupling, cohesion violations
- Spots circular dependencies
- Flags over-engineering vs under-engineering
- Recommends layering improvements
- Output: Diagram-style description + priority fixes

### Design Patterns
- Recognizes anti-patterns (God object, spaghetti, shotgun surgery)
- Suggests applicable patterns (Factory, Observer, Strategy, etc.)
- Shows before/after code snippets
- Prioritizes by impact

### Decompose (Highest ROI)
```
/dev-assistant --feature=decompose --task="Add OAuth2 login"

Output:
├─ Task 1: DB schema migration (independent)
├─ Task 2: OAuth provider setup (independent)
├─ Task 3: Token middleware (depends on 1,2)
└─ Task 4: Frontend flow (depends on 3)

Parallel: Tasks 1 and 2 simultaneously = 40% faster
```

### Code Review
- Consistency with existing codebase
- Security surface check
- Edge cases missed
- Naming clarity
- Test coverage gaps

## Scope Flags

```bash
/dev-assistant --quick          # Current file only (cheapest)
/dev-assistant --feature=X      # Single feature, changed files
/dev-assistant --full           # Full codebase analysis
/dev-assistant --file=path      # Specific file
```

## Output Format

```
## Senior Dev Review

### Critical (fix now)
- [issue] at [file:line] — [why it matters]

### High (fix before PR)
- [issue] — [recommendation]

### Suggestions (optional improvements)
- [idea] — [rationale]

### What's working well
- [positive observation]
```

## Memory Updates

After each session, updates:
- Architectural decisions made
- Patterns adopted/rejected
- Tech debt tracked
- Key trade-offs documented

## Integration

```
Works best with:
/test-global --checks=jest       # Validate after architecture changes
/pr-check --checks=linting       # Ensure code quality
/orchestrate --phase=feature     # Full feature planning with other roles
```

---

**Token avg:** 200-500 per feature | **Scope:** Any language/stack
