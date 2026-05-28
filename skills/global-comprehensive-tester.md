# Global Comprehensive Tester Skill

## Overview

Universal testing & analysis system for **any codebase** (web, mobile, backend, data, design systems) with intelligent caching, security scanning, and full code quality validation. Optimized for minimal token consumption via smart change detection.

**Purpose:** Catch bugs, security issues, and code quality problems BEFORE they hit PR/production.

---

## When to Use

```
/test-global [mode] [--checks=<check1,check2>] [--cache-reset] [--project-type=<type>] [files...]
```

### Execution Modes

#### 1. **Category Modes (Run entire category)**

| Mode | Runs | Time |
|------|------|------|
| `--lint` | All linters (ESLint, Stylelint, Pylint, etc.) | 1-2min |
| `--test` | All test runners (Jest, Pytest, Go test, etc.) | 3-8min |
| `--security` | npm audit, security patterns, secrets scan (all files) | 2-5min |
| `--build` | Build verification (npm build, Maven, etc.) | 5-10min |
| `--simulate` | Component/feature simulation tests | 3-10min |

#### 2. **Scope Modes (How much code)**

| Mode | Scope | Time |
|------|-------|------|
| `--quick` (default) | Changed files only + critical checks | 2-5min |
| `--full` | All files + all checks | 15-30min |

#### 3. **Granular Checks (Use `--checks=`)**

Run individual checks like building blocks:

```
/test-global --checks=eslint          # Only ESLint
/test-global --checks=jest            # Only Jest
/test-global --checks=npm-audit       # Only npm audit
/test-global --checks=security        # Security patterns only
/test-global --checks=eslint,jest     # ESLint + Jest
/test-global --checks=eslint,prettier,jest  # Multiple
```

**Available checks:**
```
Linting:  eslint, prettier, stylelint, pylint, flake8, black, golangci-lint, rubocop, checkstyle
Testing:  jest, pytest, vitest, mocha, go-test, xc-test, junit, xunit
Security: npm-audit, pip-audit, cargo-audit, security-patterns, secrets-detection
Build:    build, artifacts, typescript, mypy
Sim:      simulation, integration, e2e
```

### Project Types

Auto-detected or specify:
- `web` — React/Vue/Angular, npm/pnpm/yarn
- `mobile` — React Native, Flutter, Swift/Kotlin
- `backend` — Node.js, Python, Go, Java
- `data` — Python (pandas, numpy), SQL
- `design` — Figma, design system, CSS-first
- `fullstack` — Multiple stacks
- `monorepo` — Turborepo, Nx, Lerna
- `auto` — Auto-detect from files (default)

### Examples

#### Single Checks
```bash
/test-global --checks=eslint          # Only ESLint
/test-global --checks=jest            # Only Jest
/test-global --checks=npm-audit       # Only npm audit
/test-global --checks=security        # Only security patterns
/test-global --checks=pylint          # Only Pylint (Python)
/test-global --checks=build           # Only build verification
```

#### Multiple Checks
```bash
/test-global --checks=eslint,prettier # ESLint + Prettier
/test-global --checks=jest,coverage   # Jest + coverage
/test-global --checks=npm-audit,pip-audit # Both package audits
/test-global --checks=eslint,jest,npm-audit # Full combo
```

#### Category Modes (All checks in category)
```bash
/test-global --lint                   # All linters (changed files)
/test-global --test                   # All test runners (changed tests)
/test-global --security               # All security (all files)
/test-global --build                  # Build only
/test-global --simulate               # Simulations only
```

#### Scope + Category
```bash
/test-global --lint --full            # All linters on all files
/test-global --test --quick           # Tests only on changed files
/test-global --security --cache-reset # Security, fresh run (no cache)
```

#### Specific Files
```bash
/test-global --checks=eslint src/components.js src/utils.js
/test-global --test tests/unit/auth.test.js
/test-global --security src/auth/
```

#### Quick & Full Modes
```bash
/test-global --quick                  # Changed files + critical checks (default)
/test-global --full                   # All files, all checks
/test-global --full --full-report     # Full test + detailed markdown/JSON report
```

---

## What It Tests (Auto-Detected Per Project)

### ✅ Phase 1: Code Quality & Linting

**JavaScript/TypeScript:**
```
├─ ESLint (all .js/.ts/*.jsx/*.tsx)
├─ Prettier check (formatting)
├─ JSDoc/TSDoc coverage
└─ TypeScript strict mode (if .ts files exist)
```

**Python:**
```
├─ Pylint / Black (formatting)
├─ Type hints (mypy)
├─ Docstring coverage (pydocstyle)
└─ Security (bandit)
```

**Other Languages:**
```
├─ Built-in linters (Ruby: Rubocop, Go: golangci-lint, etc.)
├─ Format checks (prettier, black, gofmt)
└─ Security linters where available
```

**CSS/SCSS:**
```
├─ Stylelint
├─ CSS variable consistency
└─ Accessibility (contrast, semantics)
```

**Smart Detection:**
```
Run linters that exist in the project.
Only check files that were changed.
Cache results per file hash.
```

---

### ✅ Phase 2: Unit Tests & Coverage

**JavaScript/TypeScript:**
```
├─ Jest / Vitest / Mocha
├─ Coverage thresholds: 80%+ (configurable)
├─ Branch coverage: 80%+
└─ Parallel test execution
```

**Python:**
```
├─ pytest / unittest
├─ Coverage.py
├─ Parallel execution with pytest-xdist
└─ Coverage thresholds
```

**Mobile:**
```
├─ XCTest (iOS)
├─ Espresso / JUnit (Android)
├─ Jest (React Native)
└─ Coverage metrics
```

**Go/Backend:**
```
├─ go test
├─ Coverage.out parsing
├─ Benchmark tests (if applicable)
└─ Race condition detection
```

**Smart Detection:**
```
Find test runner config (jest.config, pytest.ini, etc.)
Run tests only for changed code.
Parse coverage output (JSON/XML).
Cache coverage results.
Compare against thresholds.
```

---

### ✅ Phase 3: Security Scan

```
INPUT: All code files
├─ Dependency audit
│  ├─ npm audit / pip audit / cargo audit
│  ├─ Maven/Gradle (Java)
│  └─ Report: high/critical vulns
├─ Code pattern scanning (regex + AST)
│  ├─ eval() / exec() usage
│  ├─ Hardcoded secrets / API keys
│  ├─ SQL injection patterns
│  ├─ XSS / CSRF vulnerabilities
│  ├─ Path traversal
│  ├─ Insecure deserialization
│  ├─ Weak crypto (MD5, SHA1)
│  ├─ Missing input validation
│  └─ Prototype pollution (JS)
├─ SAST analysis
│  ├─ GitHub CodeQL (if available)
│  ├─ Local CodeQL scanning
│  └─ SonarQube (if configured)
├─ Secrets detection
│  ├─ API keys, tokens, passwords
│  ├─ Private keys (RSA, SSH)
│  ├─ Database credentials
│  └─ Cloud credentials (AWS, GCP, Azure)
└─ OUTPUT: Vulnerabilities by severity
```

**Token Optimization:**
```
Cache npm/pip/cargo audit for 24h.
Regex patterns: <100ms per file.
Only scan changed files unless --full.
```

---

### ✅ Phase 4: Build & Compilation

```
INPUT: Source files
├─ Detect build system
│  ├─ npm/yarn/pnpm (package.json)
│  ├─ Maven/Gradle (pom.xml/build.gradle)
│  ├─ Go (go.mod)
│  ├─ Python (setup.py, pyproject.toml)
│  ├─ Rust (Cargo.toml)
│  └─ Gradle/Android (build.gradle.kts)
├─ Run build command
│  ├─ npm/yarn build
│  ├─ mvn compile
│  ├─ go build
│  ├─ python setup.py sdist
│  └─ gradlew build
├─ Check output
│  ├─ Build artifacts exist
│  ├─ No errors in output
│  ├─ Artifact sizes reasonable
│  └─ Type errors (TypeScript, mypy)
└─ OUTPUT: Build status + errors
```

---

### ✅ Phase 5: Full Analysis Report

```
INPUT: All check results
├─ Summarize by category
│  ├─ Code Quality: Passed/Failed
│  ├─ Tests: Coverage %, Pass rate
│  ├─ Security: Vulns by severity
│  ├─ Build: Success/Failed
│  └─ Performance: Bundle size, test time
├─ Flag issues by severity
│  ├─ 🔴 CRITICAL: Blocks PR/deploy
│  ├─ 🟠 HIGH: Must fix before merge
│  ├─ 🟡 MEDIUM: Should fix soon
│  ├─ 🔵 LOW: FYI, plan fix
│  └─ ⚪ INFO: Metrics tracking
├─ Compare metrics
│  ├─ Coverage delta vs main
│  ├─ Build size delta
│  ├─ Test execution time
│  └─ Security trend
└─ Generate report (markdown + JSON)
```

---

### ✅ Phase 6: Simulation & Integration Tests

```
INPUT: All checked components/features
├─ For each module/component:
│  ├─ Run integration tests
│  ├─ Test API endpoints (if backend)
│  ├─ Test data pipelines (if data)
│  ├─ Test UI interactions (if frontend)
│  ├─ Test SSR/hydration (if applicable)
│  ├─ Test theme switching (if UI)
│  ├─ Test responsive behavior
│  ├─ Test error handling (edge cases)
│  ├─ Test memory cleanup
│  └─ Test performance (p95 latency)
├─ Report failures with details
└─ OUTPUT: Simulation test results
```

---

## Output Format

### Standard Report

```markdown
# Global Test Report

**Project:** my-app (React + Node.js)  
**Type:** fullstack (detected)  
**Status:** ✅ ALL PASSED / ⚠️ WARNINGS / 🔴 FAILED  
**Run time:** 7m 42s  
**Report time:** 2026-04-07T10:45:32Z  

---

## Summary

| Category | Result | Details |
|----------|--------|---------|
| Code Quality | ✅ | 0 lint errors |
| Unit Tests | ✅ | 234 pass, 82% coverage |
| Security | 🟠 | 1 high priority issue |
| Build | ✅ | 2.3 MB bundle |
| Simulations | ✅ | All features tested |
| **Overall** | **⚠️** | **1 issue to fix** |

---

## Phase 1: Code Quality

### JavaScript/TypeScript
- ✅ ESLint: 0 errors, 0 warnings (8 files)
- ✅ Prettier: All formatted (8 files)
- ✅ TypeScript strict: 0 errors
- ✅ JSDoc coverage: 92%

### Python
- ✅ Pylint: Score 9.8/10
- ✅ Black: All formatted
- ✅ Type hints: 95% coverage
- ✅ Bandit security: 0 issues

### CSS/SCSS
- ✅ Stylelint: 0 errors (12 files)
- ✅ CSS vars: Consistent naming

---

## Phase 2: Unit Tests & Coverage

```
Test Suite: 234 tests, all passing ✅
├─ Frontend tests: 156 pass
├─ Backend tests: 78 pass
└─ No flaky tests detected

Coverage: 82% (target ≥80%) ✅
├─ Lines: 82.3%
├─ Branches: 79.4% (⚠️ below target, plan fix)
├─ Functions: 84.1%
└─ Statements: 82.1%

Coverage Delta: ↑0.7% from main
├─ frontend/components: +1.2%
├─ backend/api: +0.3%
└─ utils: -0.1% (acceptable)

Test Performance:
├─ Avg: 234ms per test
├─ p95: 1.2s (modal interaction)
└─ Total time: 2m 14s
```

---

## Phase 3: Security

### Dependencies
```
npm audit:
├─ Critical: 0
├─ High: 1
├─ Medium: 3
└─ Low: 5

🟠 HIGH PRIORITY:
├─ lodash <4.17.21
│  ├─ Issue: Prototype pollution vulnerability
│  ├─ Fix: npm install lodash@^4.17.21
│  └─ Status: Available, apply immediately
```

### Code Patterns
```
CRITICAL patterns: ✅ None detected
├─ eval(): ✅
├─ Hardcoded secrets: ✅
├─ SQL injection: ✅
└─ XSS vectors: ✅

HIGH patterns:
├─ ⚠️ Weak crypto (MD5): src/auth/hash.js:12
│  └─ Issue: MD5 used for password hashing (cryptographically broken)
│  └─ Fix: Use bcrypt or argon2

MEDIUM patterns: ✅ None

Info: Found 3 TODO comments flagging potential security reviews.
```

### Secrets Detection
```
✅ No API keys detected
✅ No private keys detected
✅ No DB credentials detected
✅ No tokens detected
```

---

## Phase 4: Build

```
Build System: npm (package.json)

npm run build:
├─ frontend build: ✅ 2.1 MB (gzipped: 450 KB)
├─ backend build: ✅ 1.2 MB
├─ assets: ✅ 250 KB (64 images)
└─ Total: 3.55 MB

Build time: 1m 23s
Type checking: ✅ No TypeScript errors
Asset optimization:
├─ Images: 64 optimized
├─ CSS: Minified + autoprefixed
├─ JS: Tree-shaken, minified
└─ All good ✅
```

---

## Phase 5: Full Analysis

### Metrics
```
Code:
├─ Files: 234 total
├─ Changed: 8 (this run)
├─ Lines: 45,231
├─ Cyclomatic complexity: 8.2 (target <10) ✅

Tests:
├─ Unit tests: 234
├─ Integration tests: 12
├─ E2E tests: 8
├─ Coverage: 82%

Performance:
├─ Build time: 1m 23s
├─ Test time: 2m 14s
├─ Bundle size: 2.1 MB (gzipped: 450 KB)
└─ Total: 3m 37s
```

### Issues by Severity

**🔴 CRITICAL (Blocks PR):**
- None

**🟠 HIGH (Must fix):**
1. lodash vulnerability - npm install lodash@^4.17.21
2. MD5 password hashing - Replace with bcrypt

**🟡 MEDIUM (Should fix soon):**
1. Branch coverage 79.4% < target 80% - Add 2-3 edge case tests
2. Cyclomatic complexity in authService.js - Consider refactoring into smaller functions

**🔵 LOW (Plan for next sprint):**
1. 3 TODO comments about security reviews
2. Update TypeScript to 5.x (currently 4.9)

---

## Phase 6: Simulation Tests

```
Components tested: 24
├─ All passing: 24 ✅
├─ All rendering: ✅
├─ All interactive: ✅

Features tested:
├─ User auth: ✅ Login/logout/token refresh
├─ API integration: ✅ CRUD operations
├─ Data pipelines: ✅ ETL transforms
├─ UI responsiveness: ✅ Mobile/tablet/desktop
├─ Dark mode: ✅ 2 themes tested
└─ Error handling: ✅ Edge cases covered

Performance:
├─ p95 latency: 240ms (API calls)
├─ p99 latency: 480ms
└─ No memory leaks ✅
```

---

## Recommendations

### 🎯 Before Merging
1. **UPDATE:** lodash to ^4.17.21 (security fix)
2. **REPLACE:** MD5 hashing with bcrypt (src/auth/hash.js:12)
3. **ADD:** 2-3 branch coverage tests for edge cases

### 📋 Before Release
1. Update TypeScript (5.x available)
2. Review 3 TODO security comments
3. Consider refactoring authService.js (high complexity)

### 📊 Metrics to Track
- Coverage trend: ↑ (82%, +0.7% from main) — Good! Keep it up
- Bundle size trend: ↓ (2.1 MB from 2.3 MB) — Excellent!
- Test execution: → (2m 14s stable)

---

## Next Steps

```bash
# 1. Fix security issues
npm install lodash@^4.17.21
# Edit src/auth/hash.js to use bcrypt

# 2. Add branch coverage tests
npm test -- --coverage

# 3. Rerun full test
/test-global --full

# 4. Ready to PR!
```

---

**Generated by:** Global Comprehensive Tester  
**Run time:** 7m 42s  
**Cache used:** 68% of checks (fast run)
```

---

## Cache Strategy

### Smart Detection

```javascript
// Git diff to find changed files
const changedFiles = exec('git diff --name-only').split('\n');

// Map changes to tests
const testsForChangedCode = findAffectedTests(changedFiles);

// Map changes to linters
const filesToLint = changedFiles.filter(f => /\.(js|ts|scss|py)$/.test(f));

// Always run security checks (all files)
const allFiles = getAllSourceFiles();
```

### Cache Files

```
.test-cache/
├─ manifest.json          (file hashes, timestamps)
├─ lint-results.json      (per file)
├─ test-coverage.json     (per test file)
├─ audit-results.json     (overall, 24h TTL)
├─ security-scan.json     (per file)
└─ build-artifact-hashes  (compare sizes)
```

### When Cache Invalidates

```
✗ File changed         → Clear that file's lint/test cache
✗ package.json changed → Clear npm audit + build cache
✗ requirements.txt     → Clear pip audit + build cache
✗ *.test.js changed    → Clear coverage for that test
✗ --cache-reset flag   → Clear all
```

---

## Security Patterns (Language-Specific)

### JavaScript/TypeScript

```javascript
const CRITICAL = {
  'eval()': /\beval\s*\(/g,
  'innerHTML unsanitized': /\.innerHTML\s*=\s*(?!sanitize|DOMPurify|escape)/g,
  'Hardcoded secrets': /(['"](?:api_key|secret|password|token|bearer)\s*['"]:\s*['"][^'"]{8,}['"])/gi,
  'Prototype pollution': /\[['"][^'"]{1,50}['"]\]\s*=|Object\.assign.*from\s+user/g,
  'Path traversal': /path\.join\s*\(\s*.*req\.(query|params|body)/g,
  'XXE attack': /<\?xml|DOCTYPE|ENTITY/i,
};
```

### Python

```python
CRITICAL = {
  'eval/exec': r'\b(eval|exec|compile)\s*\(',
  'SQL injection': r'\.query\s*\(["\'].*%s|f["\'].*{.*}',
  'Hardcoded secrets': r'(api_key|secret|password|token)\s*=\s*["\'][^\'"]{8,}["\']',
  'Pickle deserialization': r'pickle\.(loads|load)\s*\(',
  'Insecure crypto': r'(MD5|SHA1|DES)\(',
  'Weak random': r'random\.(randint|choice)',
}
```

### Java/Android

```java
CRITICAL = {
  'Hardcoded secrets': "String secret = \".*\"",
  'SQL injection': "execSQL\\(.*string",
  'Insecure crypto': "MD5|SHA-1|DES",
  'Debug logging': "Log\\.d\\(|System\\.out\\.println",
  'Intent exposure': "@android:exported",
};
```

---

## Configuration

Auto-detected from:
- `package.json` (npm, yarn, pnpm)
- `pyproject.toml` / `setup.py` / `requirements.txt` (Python)
- `go.mod` (Go)
- `Cargo.toml` (Rust)
- `pom.xml` / `build.gradle` (Java)
- `tsconfig.json` (TypeScript)
- `jest.config.js` / `vitest.config.js` (Test runners)

Or specify `.test-config.json`:

```json
{
  "projectType": "fullstack",
  "languages": ["js", "ts", "python"],
  "linters": ["eslint", "pylint"],
  "testRunners": ["jest", "pytest"],
  "securityTools": ["npm-audit", "bandit", "trivy"],
  "buildSystem": "npm",
  "coverageThreshold": 80,
  "cacheEnabled": true,
  "cacheTTL": 3600
}
```

---

## Token Optimization

**Expected token usage per run:**
- Quick (cached): 400-800 tokens
- Quick (fresh): 1,500-2,500 tokens
- Full: 3,500-6,000 tokens
- With detailed report: +1,500 tokens

**Optimization tactics:**
- Parallel execution (lint + test + audit)
- Reuse cache for unchanged files
- Batch reporting (one report, not individual dumps)
- Smart file detection (only test affected code)

---

## Success Criteria

✅ **ALL PASSED** when:
- Zero lint errors
- All tests passing
- Coverage ≥ target (80-90%)
- Zero CRITICAL security issues
- Zero HIGH security issues (unless documented exemption)
- Build succeeds
- All simulation tests passing

⚠️ **WARNINGS** when:
- Coverage below target
- HIGH security patterns found (but documented)
- Build warnings (not errors)
- Performance regressions <20%

🔴 **FAILED** when:
- Lint errors found
- Tests failing
- CRITICAL security issues
- Build failing
- npm/pip audit CRITICAL/HIGH vulns

---

## Skill Interface

```bash
/test-global [mode] [--checks=checks] [--project-type=type] [--cache-reset] [--report] [files...]

Mode:
  --quick             Changed files only (default)
  --full              All files + all checks
  --lint              All linters only
  --test              All tests only
  --security          All security checks only
  --build             Build only
  --simulate          Simulations only

Checks (granular):
  --checks=eslint     Single check (or comma-separated list)
  --checks=jest,npm-audit,security-patterns

Options:
  --project-type      web|mobile|backend|data|design|fullstack|monorepo|auto
  --cache-reset       Ignore cache, fresh run
  --report            Generate markdown + JSON report
  [files...]          Specific files/folders to check
```

**Returns:**
- Pass/fail status
- Detailed markdown report
- JSON report (for CI)
- Actionable recommendations
- Exit code: 0 (pass) / 1 (fail)

**Token usage:**
- Single check (`--checks=eslint`): 200-400 tokens
- Category (`--lint`): 600-1,200 tokens
- Quick run: 400-800 tokens
- Full run: 3,500-6,000 tokens
- With report: +1,500 tokens

**Execution time:**
- Single check: 30 sec - 2 min
- Category: 1-5 min
- Quick: 2-5 min
- Full: 15-30 min
