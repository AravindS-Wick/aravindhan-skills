---
name: qa-automation
description: Manage and execute tasks for qa-automation.
  Use when generating Playwright E2E tests, building test strategy, finding uncovered code paths,
  auditing WCAG 2.1 AA accessibility violations, or creating unit test stubs for web, mobile,
  or API codebases.
---
# QA Automation Skill

AI-powered QA engineering — Playwright generation, test strategy, coverage analysis.

## Quick Start

```bash
/qa-automation                              # Auto-detect what needs testing
/qa-automation --feature=playwright         # Generate Playwright E2E tests
/qa-automation --feature=strategy           # Test strategy for current code
/qa-automation --feature=coverage           # Coverage gap analysis
/qa-automation --feature=accessibility      # WCAG/a11y audit
/qa-automation --feature=e2e                # E2E test plan
/qa-automation --feature=api-tests          # API endpoint tests
/qa-automation --feature=unit-stubs         # Unit test stubs/boilerplate
```

## Features

| Feature | What it does | Tokens |
|---------|-------------|--------|
| `playwright` | Generate Playwright test scripts | 400-700 |
| `strategy` | Full test strategy for changed code | 300-500 |
| `coverage` | Find uncovered paths/branches | 200-400 |
| `accessibility` | WCAG 2.1 AA compliance checks | 300-500 |
| `e2e` | User flow E2E test plan | 300-500 |
| `api-tests` | API contract + integration tests | 300-500 |
| `unit-stubs` | Jest/Pytest boilerplate generation | 200-400 |

## Playwright Generation

```bash
/qa-automation --feature=playwright --file=src/auth/login.js
```

**Output: Ready-to-run Playwright script**
```javascript
// Generated: tests/e2e/auth/login.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Login Flow', () => {
  test('successful login with valid credentials', async ({ page }) => {
    await page.goto('/login');
    await page.getByLabel('Email').fill('user@example.com');
    await page.getByLabel('Password').fill('password');
    await page.getByRole('button', { name: 'Login' }).click();
    await expect(page).toHaveURL('/dashboard');
  });

  test('shows error on invalid credentials', async ({ page }) => {
    // ... generated from code analysis
  });
});
```

**Smart generation:**
- Uses accessible selectors (getByRole, getByLabel, getByText)
- MCP browser tree integration (not brittle CSS selectors)
- Self-healing test patterns
- Covers happy path + error states + edge cases

## Test Strategy

```bash
/qa-automation --feature=strategy --quick    # Strategy for changed files
```

**Output:**
```
## Test Strategy for: feat/auth-oauth

### Unit Tests (Jest)
- authService.validateToken() — 4 test cases
- tokenRefresh() — 3 test cases (incl. expiry edge case)

### Integration Tests
- POST /auth/login — request/response contract
- POST /auth/refresh — token rotation

### E2E Tests (Playwright)
- Login flow → dashboard
- Token expiry → auto-refresh → continue
- Invalid credentials → error message

### Coverage target: 85%+ on new code
### Priority: OAuth token refresh (highest risk path)
```

## Coverage Gap Analysis

```bash
/qa-automation --feature=coverage
```

Identifies:
- Uncovered branches (switch cases, error paths)
- Functions with 0 tests
- Lines never executed
- Edge cases not tested (null, empty, boundary values)

Output: Ranked list of coverage gaps with test stubs to fill them

## Accessibility Testing

WCAG 2.1 AA standards:
- Missing ARIA labels/roles
- Color contrast failures
- Keyboard navigation gaps
- Focus management issues
- Screen reader compatibility

## Scope Flags

```bash
/qa-automation --quick          # Changed files only
/qa-automation --full           # All source files
/qa-automation --file=path      # Specific file
/qa-automation --feature=X      # Single feature
```

## Memory Updates

After each session, updates:
- Test patterns established
- Coverage baseline
- Known flaky test areas
- Playwright config decisions

## Integration

```
/test-global --checks=jest          # Run generated tests
/pr-check --checks=coverage         # Validate coverage gates
/orchestrate --phase=pre-release    # Full QA before release
```

---

**Token avg:** 300-700 per feature | **Scope:** Web, mobile, API, any stack
