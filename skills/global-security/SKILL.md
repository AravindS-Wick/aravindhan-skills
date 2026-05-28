---
name: global-security
description: Manage and execute tasks for global-security.
  Use when validating staged changes before a commit or PR — catches linting errors, secrets,
  vulnerable dependencies, security patterns (eval, SQL injection, XSS, hardcoded keys), bad
  branch names, coverage drops, and build failures. Use --checks= for targeted validation.
---
# Global Security (PR Check)

Pre-PR security & quality gates that work for any codebase with auto-fix and minimal token use.

## Quick Start

```bash
# Single checks
/pr-check --checks=git                # Branch name + commit format only
/pr-check --checks=linting            # Linting only
/pr-check --checks=npm-audit          # Dependency audit only
/pr-check --checks=security           # Security patterns only
/pr-check --checks=coverage           # Coverage impact only

# Combinations
/pr-check --checks=git,files,linting  # Fast pre-commit combo
/pr-check --checks=linting,npm-audit,security

# Scope modes
/pr-check --pre-commit                # Fast (1–3 min, cached) — default
/pr-check --full                      # All checks (5–15 min)
/pr-check --fix                       # Auto-fix + validate
/pr-check --full --report             # Detailed markdown + JSON output

# Target branch/PR
/pr-check feat/my-feature --full
```

## Available Checks

```
git, files, linting, security, npm-audit, pip-audit, coverage, build, performance, docs
```

## What Each Check Validates

| Check | Gates |
|-------|-------|
| `git` | Branch naming (`feat/`, `fix/` etc), commit format (`type(scope): desc`), no force-push |
| `files` | No `.env`, secrets, `node_modules/`, `dist/`, OS files, large binaries |
| `linting` | ESLint/Pylint/Rubocop: 0 errors required |
| `security` | eval, exec, SQL injection, XSS, hardcoded secrets, path traversal, weak crypto |
| `npm-audit` | 0 CRITICAL/HIGH vulnerabilities (or documented exemption) |
| `coverage` | New code has tests, coverage not dropped >5% |
| `build` | Build succeeds, no TypeScript errors, artifacts created |

## Execution Modes

| Mode | Time | Tokens |
|------|------|--------|
| `--checks=git` | 30s | 300–500 |
| `--pre-commit` | 1–3m | 600–1,200 |
| `--full` | 5–15m | 2,000–4,000 |
| `--fix` | 2–5m | 1,200–2,200 |

## Blocking vs Warning Gates

**Blocks PR:** lint errors, test failures, CRITICAL security, npm/pip audit CRITICAL/HIGH, build failure, sensitive files, invalid commit/branch format

**Warns:** HIGH security patterns, coverage decrease, performance regression <20%

## Auto-Fix (`--fix`)

Automatically fixes: ESLint errors, Prettier formatting, Stylelint, import sorting, trailing whitespace

## Exemptions

```javascript
// ⚠️ EXEMPTION: reason
// Issue: #1234, approved by @lead on 2026-04-08, sunset: 2026-07-08
const URL = 'https://api.example.com';
```

---

**Token avg:** 600–4,000 per run | **Scope:** Any language/stack
