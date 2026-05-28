# @aravi1008/ui Comprehensive Tester Skill

## Overview

Global-level testing & analysis system for @aravi1008/ui with intelligent caching, security scanning, and full code quality validation. Optimized for minimal token consumption via smart change detection and cache reuse.

**Purpose:** Catch bugs, security issues, and code quality problems BEFORE they hit PR/main.

---

## When to Use

```
/test-comprehensive [--quick] [--full] [--cache-reset] [files...]
```

### Modes

| Mode | When | What it does | Time |
|------|------|-------------|------|
| `--quick` (default) | Nightly/dev | Changed files only + critical regex checks | 2-5min |
| `--full` | Pre-release/pre-PR | All files + all checks | 15-30min |
| `--cache-reset` | After deps change | Ignore cache, fresh run | Full |

### Examples

```bash
# Quick test on changes since last run
/test-comprehensive

# Full test before PR
/test-comprehensive --full

# Test specific files
/test-comprehensive src/components.js tests/unit/modal.test.js

# Reset cache and test everything
/test-comprehensive --cache-reset --full
```

---

## What It Tests

### ✅ Phase 1: Code Quality (eslint, stylelint)

```
INPUT: Changed files list (or all if --full)
├─ Parse git diff to find changed files
├─ Run ESLint on .js/.ts (0 errors = pass)
├─ Run Stylelint on .scss/.css (0 errors = pass)
├─ Report: errors, warnings, lines, fixes
└─ OUTPUT: pass/fail + auto-fix suggestions
```

**Token opt:** Only lint changed files unless `--full`. Cache results per file hash.

---

### ✅ Phase 2: Unit Tests (jest with coverage)

```
INPUT: Test files matching changed code
├─ Identify tests that depend on changed files
├─ Run jest --coverage on those tests
├─ Compare coverage % to thresholds:
│  ├─ Lines: ≥85%
│  ├─ Branches: ≥85%
│  ├─ Functions: ≥80%
│  └─ Statements: ≥85%
├─ Report: pass/fail, coverage delta, uncovered lines
└─ OUTPUT: Test suite status + coverage report
```

**Token opt:** Use jest `--testPathPattern` for specific test files. Cache coverage per test.

---

### ✅ Phase 3: Security Scan

```
INPUT: All dependencies + code patterns
├─ npm audit (json output)
│  └─ Report: high/critical vulnerabilities
├─ Dependency review check
│  └─ Report: outdated or risky packages
├─ Code pattern scanning (regex):
│  ├─ No eval() usage
│  ├─ No innerHTML with unsanitized input
│  ├─ No hardcoded secrets/API keys
│  ├─ isBrowser guard on DOM access
│  ├─ Rate limiter check on theme switching
│  ├─ Event listener cleanup checks
│  └─ OWASP Top 10 patterns
├─ CSS safety (no !important misuse)
└─ OUTPUT: Issues found + severity level
```

**Token opt:** Cache npm audit results (updates only on package.json change). Regex checks on all code.

---

### ✅ Phase 4: Build Verification

```
INPUT: Source files
├─ npm run build (all subtasks)
│  ├─ build:tokens → dist/tokens/ ✓
│  ├─ build:icons → dist/icons/ ✓
│  ├─ build:css → dist/index.css ✓
│  ├─ build:js → dist/index.js + .cjs ✓
│  └─ build:types → dist/*.d.ts ✓
├─ Check dist files exist and are non-empty
└─ OUTPUT: Build status + file sizes
```

**Token opt:** Cache build output. Only rebuild if source changed.

---

### ✅ Phase 5: Full Analysis Report

```
INPUT: All check results
├─ Summarize: Quality → Tests → Security → Build
├─ Flag issues by severity:
│  ├─ 🔴 CRITICAL (blocks PR): npm audit high/critical, test fail
│  ├─ 🟠 HIGH (needs fix): Coverage <85%, security patterns found
│  ├─ 🟡 MEDIUM (review): Linting warnings, TODO comments
│  └─ 🔵 INFO (track): Metrics, coverage delta, component count
├─ Generate: Full report + summary
└─ OUTPUT: JSON + markdown report
```

---

### ✅ Phase 6: Simulation Tests

```
INPUT: All checked features (components, utilities)
├─ For each checked component/feature:
│  ├─ Run integration tests (if exist)
│  ├─ Test SSR compatibility (isBrowser guard check)
│  ├─ Test theme switching (light/dark/forest/ocean/professional/corporate)
│  ├─ Test responsive behavior (mobile/tablet/desktop)
│  ├─ Test keyboard events (modal open/close, tab nav, escape)
│  ├─ Test accessibility (ARIA attributes, focus management)
│  └─ Test cleanup (no memory leaks, event listeners removed)
├─ Report: Feature status (working/broken/needs attention)
└─ OUTPUT: Simulation test results + failure details
```

**Token opt:** Cache simulation results per component. Rerun only if component code changed.

---

## Output Format

### Standard Report

```markdown
# @aravi1008/ui Comprehensive Test Report

## Summary
- Status: ✅ ALL PASSED / ⚠️ WARNINGS / 🔴 FAILED
- Run time: 5m 23s
- Files tested: 24
- Coverage: 87.2% (target ≥85%)

## Phase 1: Code Quality
✅ ESLint: 0 errors, 0 warnings
✅ Stylelint: 0 errors
- 8 files checked

## Phase 2: Unit Tests
✅ Test suite: 156 tests passed
✅ Coverage: 87.2% (↑0.3% from last run)
- branches: 85.1% (target ≥85%)
- functions: 82.4% (target ≥80%)
- lines: 87.2% (target ≥85%)
- statements: 87.1% (target ≥85%)

## Phase 3: Security
🟠 npm audit: 1 medium vulnerability found
- Package: lodash < 4.17.21
- Recommendation: Update to ^4.17.21
⚠️ Code patterns:
- ❌ Found 1 innerHTML usage without sanitization (src/components.js:142)
- ✅ All isBrowser guards present
- ✅ Theme rate limiter configured

## Phase 4: Build
✅ Build successful
- tokens: 1.2 KB
- icons: 45 KB (32 icons)
- CSS: 156 KB (gzipped: 23 KB)
- JS: 28 KB (gzipped: 8 KB)

## Phase 5: Full Analysis
### Metrics
- Total components: 18
- Total utilities: 45
- Total icons: 32
- Test coverage: 87.2%

### Components checked:
✅ modal, button, dropdown, card
✅ badge, chip, tooltip, drawer
⚠️ datepicker (coverage 78% < target 85%)

### Utilities checked:
✅ spacing, colors, typography
✅ responsive, dark-mode, themes

## Phase 6: Simulation Tests
✅ Components: 18/18 working
✅ Theme switching: all 6 themes working
✅ Responsive: mobile/tablet/desktop all responsive
⚠️ Accessibility: 2 components missing ARIA labels
✅ Keyboard events: all working
✅ Memory cleanup: all clean

## Recommendations
1. **HIGH:** Fix innerHTML sanitization in src/components.js:142
2. **MEDIUM:** Update lodash to ^4.17.21
3. **MEDIUM:** Add ARIA labels to datepicker component
4. **LOW:** Increase coverage for datepicker to 85%+

---

**Next steps:** 
- [ ] Fix critical issues above
- [ ] Rerun full test
- [ ] Open PR when all pass
```

### JSON Report (for CI/automation)

```json
{
  "timestamp": "2026-04-07T10:23:45Z",
  "status": "warning",
  "summary": {
    "passed": true,
    "testsPassed": 156,
    "coverage": 87.2,
    "securityIssues": 1,
    "lintErrors": 0,
    "buildStatus": "success"
  },
  "phases": {
    "quality": { "eslint": 0, "stylelint": 0 },
    "tests": { "passed": 156, "coverage": 87.2 },
    "security": {
      "audit": { "critical": 0, "high": 0, "medium": 1 },
      "codePatterns": { "htmlinjection": 1, "secretsFound": 0 }
    },
    "build": { "status": "success", "artifacts": 5 },
    "simulation": { "passed": 18, "failed": 0, "warnings": 2 }
  },
  "recommendations": [...]
}
```

---

## Cache Strategy

### Cache Files

```
./.av-test-cache/
├─ manifest.json          (file hashes, timestamps)
├─ eslint-results.json    (per file)
├─ coverage-results.json  (per test file)
├─ audit-results.json     (overall)
└─ simulation-cache.json  (per component)
```

### Cache Invalidation

```
File changed? → Clear that file's cache
package.json changed? → Clear npm audit + build cache
*.scss changed? → Clear stylelint cache + build cache
*.test.js changed? → Clear coverage cache for that test
--cache-reset flag? → Clear all
```

### Smart Detection

```javascript
// Pseudo-code for git diff parsing
const changedFiles = exec('git diff --name-only').split('\n');
const changedTests = findTestFilesFor(changedFiles);
const changedStyles = changedFiles.filter(f => f.endsWith('.scss'));

// Only test what changed
runEslint(changedFiles);
runStylelint(changedStyles);
runJest(changedTests);

// But always run regex on critical patterns (security)
runSecurityRegex(ALL_FILES);
```

---

## Security Regex Patterns

```javascript
const PATTERNS = {
  'No eval()': /\beval\s*\(/g,
  'No innerHTML without sanitize': /\.innerHTML\s*=\s*(?!sanitize|DOMPurify)/g,
  'No hardcoded secrets': /(['"](?:api_key|secret|password|token)\s*['"]:\s*['"][^'"]*['"])/gi,
  'isBrowser guard required': /typeof\s+document\s+!==\s+['"]undefined['"]/g,
  'No console in production': /console\.(log|debug|warn|info)\(/g,
  'Theme rate limiter': /(?!.*throttle|.*debounce).*changeTheme/g,
  'Event cleanup pattern': /addEventListener.*(_avCleanup|removeEventListener)/g,
  'No prototype pollution': /\[['"][^'"]+['"]\]\s*=/g,
  'XSS patterns': /<script|onclick|onerror|onload/gi,
  'SQL injection': /\.query\(\s*['"`].*\$|\.query\(\s*`.*\$/g,
};

// Run on: src/**/*.js, tokens/**/*.js, scripts/**/*.js
// Report: filename:line with surrounding context
```

---

## Integration with PR Checks

When used with `aravindhan-ui-pr-security` skill:

```
COMMIT → git hook runs /test-comprehensive --quick
         ↓ (fails? block commit)
         ↓ (passes? continue)
PR OPENED → runs /test-comprehensive --full
         ↓ (fails? request changes)
         ↓ (passes? approve)
BEFORE MERGE → runs /test-comprehensive --full --cache-reset
         ↓ (all green? merge approved)
```

---

## Implementation Details

### Tech Stack
- **Linting:** eslint, stylelint
- **Testing:** jest (node + jsdom), playwright (if E2E added)
- **Security:** npm audit, custom regex engine, CodeQL (GitHub Actions)
- **Build:** npm run build (all tasks)
- **Cache:** File system (.av-test-cache/), hashing via crypto.createHash('sha256')
- **Reporting:** markdown + JSON output

### Files Created

1. `.av-test-cache/` — cache directory
2. `TESTER_REPORT.md` — latest report (markdown)
3. `TESTER_REPORT.json` — latest report (JSON)
4. `.claudeignore` entries for cache

### Commands

```bash
# In aravindhan-ui/

# Quick test (changed files only)
npm run lint && npm run test -- --coverage

# Full test (all files)
npm run lint && npm run test -- --coverage

# Security audit
npm audit --json > .av-test-cache/audit.json

# Build verification
npm run build
```

---

## Error Handling

| Error | Action |
|-------|--------|
| npm audit fails | Report high/critical, block unless deps approved |
| Jest coverage <85% | Report coverage gap, suggest tests to add |
| Linting errors | Report errors + auto-fix suggestions |
| Build fails | Report exact error + log, block |
| Security pattern found | Report severity + fix details |
| Regex timeout (5s) | Timeout gracefully, report partial results |

---

## Success Criteria

All of the following must pass for **ALL GREEN** status:

- ✅ ESLint: 0 errors
- ✅ Stylelint: 0 errors
- ✅ Jest: All tests pass
- ✅ Coverage: ≥85% lines, ≥85% branches, ≥80% functions
- ✅ npm audit: 0 high/critical
- ✅ Build: Success, all artifacts present
- ✅ Security patterns: 0 critical findings
- ✅ Simulation tests: All components working

---

## Token Optimization Tips

1. **Cache aggressively** — 90% of runs use cache for unchanged files
2. **Parallel checks** — Run linting, tests, security scan in parallel
3. **Skip unchanged** — Don't lint/test/scan files with no changes
4. **Batch reporting** — One report per run (not individual tool reports)
5. **Smart timeouts** — Regex patterns complete in <100ms per file
6. **Reuse results** — Cache lint/test/audit results for 24 hours or until change

**Expected token usage:**
- Quick run: 500-1,000 tokens (cached)
- Full run: 3,000-5,000 tokens (all checks)
- Detailed report: +2,000 tokens

---

## Skill Interface

This skill runs via command `/test-comprehensive` with the args above. It:

1. Parses args (`--quick`, `--full`, `--cache-reset`, file list)
2. Runs all 6 phases in parallel where possible
3. Generates markdown + JSON reports
4. Returns summary + recommendations
5. Exits with status 0 (all pass) or 1 (failures found)

**Next chat:** User runs `/test-comprehensive` and gets full analysis.

---

## Future Enhancements

- [ ] Playwright E2E tests integration
- [ ] Visual regression testing (Percy/Chromatic)
- [ ] Performance profiling (Lighthouse, bundle analysis)
- [ ] WCAG accessibility audit (axe-core)
- [ ] Type checking (TypeScript strict mode)
- [ ] Dependency graph analysis (circular import detection)
