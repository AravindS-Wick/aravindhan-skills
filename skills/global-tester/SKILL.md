---
name: global-tester
description: >
  Use when running tests, checking code quality, scanning for security vulnerabilities, verifying
  builds, or measuring coverage on any codebase. Supports jest, eslint, npm-audit, pytest, vitest,
  stylelint, security-patterns, build, typescript and 20+ other check types via --checks= flag.
---

# Global Tester

Universal testing & quality system for any codebase — web, mobile, backend, data, design systems.

## Quick Start

```bash
# Single checks
/test-global --checks=eslint          # ESLint only
/test-global --checks=jest            # Jest tests only
/test-global --checks=npm-audit       # npm audit only
/test-global --checks=security        # Security patterns only

# Multiple checks (comma-separated)
/test-global --checks=eslint,jest
/test-global --checks=jest,npm-audit,security

# Category modes
/test-global --lint                   # All linters
/test-global --test                   # All test runners
/test-global --security               # All security checks
/test-global --build                  # Build only

# Scope
/test-global --quick                  # Changed files only (default)
/test-global --full                   # All files
/test-global --security --cache-reset # Fresh run, no cache
```

## Checks Reference

| Category | Checks |
|----------|--------|
| Linting | `eslint`, `prettier`, `stylelint`, `pylint`, `flake8`, `golangci-lint` |
| Testing | `jest`, `pytest`, `vitest`, `mocha`, `go-test`, `junit` |
| Security | `npm-audit`, `pip-audit`, `security-patterns`, `secrets-detection` |
| Build | `build`, `typescript`, `mypy`, `artifacts` |
| Simulation | `integration`, `e2e`, `simulation` |

## Execution Modes

| Mode | Scope | Est. Time | Tokens |
|------|-------|-----------|--------|
| `--checks=X` | Single check | 30s–2m | 200–400 |
| `--lint` | All linters | 1–2m | 600–1,200 |
| `--quick` (default) | Changed files | 2–5m | 400–800 |
| `--full` | All files | 15–30m | 3,500–6,000 |

## Smart Caching

- File-level hashing — only retest changed code
- 24h TTL for `npm-audit` / `pip-audit` (invalidates on `package.json` change)
- `--cache-reset` to force fresh run
- ~60–80% token savings on repeated runs

## Project Auto-Detection

Detects: web (React/Vue/Angular), mobile (RN/Flutter), backend (Node/Python/Go/Java), data (Python/SQL), design (CSS/SCSS), monorepo (Turborepo/Nx/Lerna)

## Success Criteria

| Status | Condition |
|--------|-----------|
| ✅ PASS | 0 lint errors, all tests pass, coverage ≥80%, 0 CRITICAL security |
| ⚠️ WARN | Coverage below target, HIGH security patterns found |
| 🔴 FAIL | Lint errors, test failures, CRITICAL security, build failure |

## Integration with `/pr-check`

```
Pre-commit:   /pr-check --checks=linting
On push:      /test-global --quick
PR open:      /pr-check --full  +  /test-global --security
Before merge: /test-global --full --cache-reset
```

---

**Token avg:** 400–3,500 per run (with caching) | **Scope:** Any language/stack
