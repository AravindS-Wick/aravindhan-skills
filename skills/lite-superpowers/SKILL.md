---
name: lite-superpowers
description: Manage and execute tasks for lite-superpowers.
  Use when analyzing code quality, suggesting refactors, optimizing performance, generating
  boilerplate, reviewing implementation details, or explaining complex code sections —
  without loading the full superpowers plugin or forcing Opus 4.6.
---
# Lite Superpowers

Token-optimized code intelligence. Replaces `superpowers@claude-plugins-official` for code tasks — 75–85% fewer tokens, no forced Opus 4.6.

## Quick Start

```bash
/lite-superpowers --analyze           # Analyze current file/selection
/lite-superpowers --refactor          # Suggest refactoring improvements
/lite-superpowers --optimize          # Performance & efficiency improvements
/lite-superpowers --generate          # Boilerplate / scaffold code
/lite-superpowers --explain           # Explain complex code sections
/lite-superpowers --review            # Implementation review with rationale
```

## Features

| Flag | What it does | Tokens |
|------|-------------|--------|
| `--analyze` | Code quality: complexity, coupling, smells | 200–400 |
| `--refactor` | Before/after with clear rationale | 300–500 |
| `--optimize` | O(n) complexity, memory, bundle size | 200–400 |
| `--generate` | Scaffold from spec or pattern | 300–600 |
| `--explain` | Plain-language breakdown of logic | 150–300 |
| `--review` | Senior-level implementation critique | 300–500 |

## Scope Flags

```bash
/lite-superpowers --analyze --quick   # Current file only
/lite-superpowers --analyze --full    # Whole codebase
/lite-superpowers --analyze --file=src/auth.js
```

## What It Catches

**Code quality:** God objects, spaghetti coupling, duplicated logic, dead code, inconsistent naming

**Performance:** O(n²) loops, unnecessary re-renders, memory leaks, large bundle imports, N+1 queries

**Security surface:** Missing input validation, unescaped output, hardcoded values, missing error boundaries

**Patterns:** Suggests Factory, Observer, Strategy, Repository where applicable — shows before/after

## Token Comparison

| Task | Full superpowers | Lite superpowers | Savings |
|------|-----------------|------------------|---------|
| Single file analyze | ~2,000 | ~350 | 83% |
| Refactor suggestion | ~3,000 | ~450 | 85% |
| Code review | ~4,000 | ~500 | 88% |
| Boilerplate generate | ~2,500 | ~500 | 80% |

## Integration

```
/lite-superpowers --analyze → /dev-assistant --feature=architecture  (structural issues)
/lite-superpowers --review  → /pr-check --checks=linting             (before PR)
/lite-superpowers --generate → /test-global --checks=jest            (test generated code)
```

---

**Token avg:** 200–600 per command | **Model:** Sonnet (never forces Opus)
