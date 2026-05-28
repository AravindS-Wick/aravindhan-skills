# Global PR Security Checks Skill

## Overview

Universal pre-PR security & quality validation that works for **any codebase** (web, mobile, backend, data, design systems, monorepos). Integrates with git hooks and CI/CD to catch vulnerabilities and quality issues before PR opens.

**Purpose:** Gate all PRs with security + quality checks. No broken/vulnerable code ships.

---

## When to Use

```
/pr-check [mode] [--checks=<check1,check2>] [--fix] [pr-url-or-branch]
```

### Execution Modes

#### 1. **Scope Modes (How much to validate)**

| Mode | Scope | Time |
|------|-------|------|
| `--pre-commit` (default) | Fast validation on current branch | 1-3min |
| `--full` | Complete validation, all gates | 5-15min |
| `--fix` | Auto-fix issues then validate | 2-5min |

#### 2. **Granular Checks (Build your own validation)**

```
/pr-check --checks=git            # Only git rules
/pr-check --checks=linting        # Only linting
/pr-check --checks=security       # Only security patterns
/pr-check --checks=npm-audit      # Only npm audit
/pr-check --checks=coverage       # Only coverage check
/pr-check --checks=git,linting,npm-audit  # Custom combo
```

**Available checks:**
```
git, files, linting, security, npm-audit, pip-audit, coverage, build, performance, docs
```

### Examples

#### Single Check (Quick validation)
```bash
/pr-check --checks=git            # Git rules only (30 sec)
/pr-check --checks=linting        # Linting only (1 min)
/pr-check --checks=npm-audit      # npm audit only (1 min)
/pr-check --checks=security       # Security patterns only (2 min)
/pr-check --checks=coverage       # Coverage impact only (3 min)
```

#### Multiple Checks (Custom validation)
```bash
/pr-check --checks=git,files,linting  # Fast combo check
/pr-check --checks=linting,npm-audit,security  # Quality check
/pr-check --checks=npm-audit,pip-audit,build  # Dependencies check
```

#### Modes (Pre-commit vs Full)
```bash
/pr-check --pre-commit            # Fast validation (default)
/pr-check --full                  # Complete validation, all gates
/pr-check --full --report         # Full + detailed markdown report
```

#### Auto-fix + Validate
```bash
/pr-check --fix                   # Auto-fix (eslint, prettier) then check
/pr-check --fix --full            # Auto-fix + full validation
```

#### Specific Branches or PRs
```bash
/pr-check feat/new-feature --full
/pr-check https://github.com/user/repo/pull/42 --full
```

---

## What It Validates

### ✅ 1. Git Rules

```
INPUT: Git history from branch point to HEAD
├─ Branch naming
│  ├─ Pattern: feat/, fix/, chore/, docs/, refactor/, test/, perf/
│  ├─ No spaces, no uppercase (unless feature-flags)
│  └─ No main/master/develop branches allowed
├─ Commits
│  ├─ Format: type(scope): description
│  ├─ No Co-Authored-By (single author policy optional)
│  ├─ Message length: <72 chars title, <100 body lines
│  └─ No force-push to shared branches
├─ No --no-verify bypasses
├─ No direct commits to protected branches
└─ OUTPUT: pass/fail + violations
```

---

### ✅ 2. File Changes

```
INPUT: git diff --name-status
├─ Sensitive files check
│  ├─ .env, .env.local, .env.*.local
│  ├─ .secrets, .credentials, secrets.json
│  ├─ API keys, private keys, certificates
│  ├─ .ssh/, .aws/credentials, .gcp/
│  └─ Database dumps, dumps, backup files
├─ Build/cache files
│  ├─ node_modules/, venv/, .venv/
│  ├─ dist/, build/, .next/
│  ├─ *.egg-info, __pycache__/
│  ├─ .DS_Store, Thumbs.db, *.swp
│  └─ .gradle, .m2
├─ Size checks
│  ├─ No binary files >100MB
│  ├─ No large data files >50MB
│  └─ Reasonable file sizes
├─ File types
│  ├─ Only expected file types modified
│  ├─ No executable files (.exe, .bin)
│  └─ Valid extensions
└─ OUTPUT: flag suspicious files
```

---

### ✅ 3. Code Quality Gates

```
INPUT: Changed source files
├─ Run linters (detected per language)
│  ├─ JavaScript: ESLint, Prettier
│  ├─ Python: Pylint, Black, Flake8
│  ├─ Go: golangci-lint, gofmt
│  ├─ Java: Checkstyle, SpotBugs
│  ├─ CSS/SCSS: Stylelint
│  └─ Other: Language-specific linters
├─ Fail if ANY linting errors found
├─ Report: errors, warnings, quick fixes
└─ OUTPUT: pass/fail + error details
```

---

### ✅ 4. Dependency Changes

```
INPUT: package.json / requirements.txt / go.mod diff
├─ New dependencies
│  ├─ Not from random/untrusted sources
│  ├─ Has npm/PyPI presence
│  ├─ Popular/maintained (recent activity)
│  └─ Check for known vulnerabilities
├─ Version changes
│  ├─ No downgrades without justification
│  ├─ Major versions documented
│  ├─ Vulnerability patches applied
│  └─ Prerelease versions flagged (dev only)
├─ npm/pip/cargo audit
│  ├─ Zero CRITICAL vulnerabilities
│  ├─ Zero HIGH vulnerabilities (unless documented)
│  ├─ MEDIUM/LOW flagged with fix recommendations
│  └─ Dependency review complete
└─ OUTPUT: audit status + fix recommendations
```

---

### ✅ 5. Security Pattern Detection

**Scope:** All changed files + all source files (regex + AST)

```javascript
const CRITICAL_PATTERNS = {
  'eval/exec': /\b(eval|exec|compile)\s*\(/,
  'innerHTML injection': /\.innerHTML\s*=\s*(?!sanitize|escape|DOMPurify)/,
  'Hardcoded secrets': /(?:api_key|secret|password|token|bearer)\s*[:=]\s*['"]+[a-zA-Z0-9]{8,}['"]/i,
  'Prototype pollution': /\[['"][^'"]+['"]\]\s*=/,
  'Path traversal': /path\.(join|resolve).*req\.(query|params|body|url)/,
  'SQL injection': /\.query.*%s|\.execute.*\$1|WHERE.*\+/,
  'XXE vulnerability': /<\?xml.*DOCTYPE|ENTITY/,
  'Insecure deserialization': /(pickle\.load|readObject|XMLDecoder)/,
  'Hardcoded credentials': /(root:password|admin:admin|default credentials)/i,
};

const HIGH_PATTERNS = {
  'Missing input validation': /\.value\s*=|request\.(query|params|body)/,
  'Missing isBrowser guard': /typeof\s+document.*undefined/,
  'Missing auth check': /router\..*\(/,
  'Weak crypto': /(MD5|SHA-1|DES|ECB)\(/,
  'Hardcoded URLs': /https?:\/\/[a-z0-9.-]+/,
  'Missing rate limiting': /app\.post.*req\./,
  'Missing CORS setup': /Access-Control/,
};

INPUT: All changed .js/.ts/.py/.go/.java files
├─ Scan for CRITICAL patterns
├─ Scan for HIGH patterns
├─ Report: Line + context + severity
└─ OUTPUT: Issues by severity + fix suggestions
```

---

### ✅ 6. Coverage Impact

```
INPUT: Changed test files + coverage config
├─ Identify tests affected by changes
├─ Run only those tests with coverage
├─ Compare coverage delta
│  ├─ Check: Coverage not decreased >5%
│  ├─ Check: New code has tests
│  ├─ Check: All branches covered
│  └─ Flag if coverage ↓↓↓
├─ Generate coverage report
└─ OUTPUT: Coverage delta + uncovered lines
```

---

### ✅ 7. Build Success

```
INPUT: All changes
├─ Detect build system (npm, Maven, Go, etc.)
├─ Run: npm run build (or equivalent)
├─ Check:
│  ├─ Exit code 0
│  ├─ Build artifacts created
│  ├─ No TypeScript errors
│  ├─ No Python errors (mypy/pylint)
│  └─ Asset optimization complete
├─ Report:
│  ├─ Build time
│  ├─ Artifact sizes
│  ├─ Any warnings
│  └─ Size deltas vs main
└─ OUTPUT: Build status + errors (if any)
```

---

### ✅ 8. Performance Checks

```
INPUT: Changed code
├─ Bundle size impact (if frontend)
│  ├─ Size increase >10%? WARN
│  ├─ Gzip ratio check
│  └─ Tree-shaking working?
├─ Test performance
│  ├─ Any test slower than 5s? Flag
│  ├─ Parallel execution working?
│  └─ Test flakiness detection
├─ API latency impact (if backend)
│  ├─ New endpoints slow (>1s)? Flag
│  ├─ Database queries unoptimized? Flag
│  └─ N+1 queries detected? Flag
└─ OUTPUT: Performance deltas
```

---

### ✅ 9. Documentation

```
INPUT: PR metadata (if opened)
├─ Title matches format: type(scope): description
├─ Description exists and meaningful
├─ References issue (#N) if applicable
├─ BREAKING CHANGE marked (if applicable)
├─ Testing plan documented
└─ OUTPUT: Metadata quality + suggestions
```

---

## Gate Rules

### 🔴 Blocking Rules (Cannot PR)

| Rule | Check | Fix |
|------|-------|-----|
| **Linting** | ESLint/Pylint/etc fail | Run `/pr-check --fix` |
| **Tests fail** | Any test failing | Fix tests locally |
| **CRITICAL security** | eval(), injection, secrets | Remove immediately |
| **npm/pip audit CRITICAL** | High vuln found | Update dependency |
| **Build fails** | Build exit code != 0 | Fix build errors |
| **Commit format** | Not type(scope): | Rebase + reword |
| **Sensitive files** | .env, keys committed | Remove + history rewrite |
| **Branch name** | No proper prefix | Rename branch |

### 🟠 Warning Rules (PR opens with review request)

| Rule | Check | Action |
|------|-------|--------|
| **Coverage ↓** | Coverage <80% or ↓5% | Add tests |
| **HIGH security** | Missing guard, weak crypto | Document, plan fix |
| **npm/pip audit HIGH** | Vulnerability found | Plan upgrade next sprint |
| **Performance ↑** | Bundle +10%, test +50% | Investigate cause |
| **Type errors** | TypeScript/mypy warnings | Add types |

### 🔵 Info Rules (FYI)

| Rule | Check | Action |
|------|-------|--------|
| **Large PR** | >500 lines changed | Consider smaller PRs |
| **Many files** | >20 files changed | Suggest splitting |
| **Coverage ↑** | Coverage increases | Great! |
| **Performance ↓** | Bundle -5%, tests faster | Excellent |

---

## Output Format

### Terminal Output (Quick)

```
🔍 Checking feat/auth-flow branch...

✅ Git Rules
 ├─ Branch: feat/auth-flow (valid)
 ├─ Commits: 5, all correct format
 ├─ No force-push detected
 └─ Ready

✅ File Changes
 ├─ 12 files modified
 ├─ No sensitive data
 ├─ No node_modules changes
 └─ All sizes OK

✅ Code Quality
 ├─ ESLint: 0 errors
 ├─ TypeScript: 0 errors
 ├─ Python: 0 errors
 └─ All passing

✅ Dependencies
 ├─ No package.json changes
 ├─ npm audit: 0 vulnerabilities
 └─ Safe

🟠 Security Patterns
 ├─ CRITICAL: ✅ None
 ├─ HIGH: ⚠️  1 issue
 │  └─ Missing auth check on line 142 (src/api.js)
 ├─ MEDIUM: ✅ None
 └─ Address before merge

✅ Tests
 ├─ Coverage: 82% (no change)
 ├─ All tests: 234 passing
 └─ Good

✅ Build
 ├─ npm run build: SUCCESS
 ├─ Bundle: 2.1 MB (no change)
 └─ Ready

─────────────────────────────────────

⚠️  WARNINGS: 1 issue

Ready to PR with fix for security issue!

Commands:
  git push origin feat/auth-flow
  
See issues above and full report:
  /pr-check --report
```

### Full Report (Markdown)

```markdown
# PR Security Check Report

**Branch:** feat/auth-flow  
**Status:** ⚠️ WARNINGS (1 issue, can PR)  
**Report Date:** 2026-04-07T10:45:32Z  

---

## Executive Summary

✅ **CAN OPEN PR** — Fix 1 security warning before merge.

| Check | Result | Issue |
|-------|--------|-------|
| Git rules | ✅ | None |
| File changes | ✅ | None |
| Code quality | ✅ | None |
| Dependencies | ✅ | None |
| Security | 🟠 | 1 HIGH |
| Tests | ✅ | None |
| Build | ✅ | None |
| **Overall** | ⚠️ | **Merge with plan to fix** |

---

## Detailed Results

### Git Rules (✅ Pass)

```
Branch: feat/auth-flow
├─ Naming: ✅ Follows feat/* pattern
├─ Base: main
├─ Commits: 5
│  ├─ feat(auth): implement oauth flow
│  ├─ feat(auth): add token refresh
│  ├─ test(auth): add flow tests
│  ├─ refactor(auth): simplify token logic
│  └─ docs(auth): update README
├─ Format: ✅ All correct type(scope): format
├─ Authors: ✅ Single author (you)
└─ Flags: ✅ None
```

### File Changes (✅ Pass)

```
Modified: 12 files (+450 lines, -30 lines)
├─ src/auth/oauth.js (+180)
├─ src/auth/token.js (+120)
├─ tests/auth.test.js (+150)
├─ README.md (+20)
├─ package.json (+0, dependencies added)
└─ 7 other files...

Security checks:
├─ .env files: ✅ None added
├─ API keys: ✅ None hardcoded
├─ Private keys: ✅ None
├─ node_modules: ✅ Not modified
├─ dist/: ✅ Not modified
└─ OS files: ✅ None (.DS_Store, etc.)

Sizes: ✅ All reasonable
File types: ✅ All valid (.js, .test.js, .md, .json)
```

### Code Quality (✅ Pass)

```
ESLint:
├─ Files: 3 changed .js files
├─ Errors: 0
├─ Warnings: 0
└─ ✅ PASS

TypeScript:
├─ Files: 0 (.ts files)
├─ Status: N/A
└─ ✅ OK

Format (Prettier):
├─ Files: 3 changed
├─ Status: ✅ All formatted
└─ ✅ OK
```

### Dependencies (✅ Pass)

```
package.json changes:
├─ jsonwebtoken: ^8.5.1 → ^9.0.2 ✅ (upgrade, secure)
├─ passport: ^0.6.0 → ^0.7.0 ✅ (upgrade)
└─ oauth-provider: Removed (no longer needed) ✅

npm audit:
├─ Before: 2 medium vulnerabilities
├─ After: 0 vulnerabilities ✅
└─ Status: ✅ IMPROVED

Dependency review:
├─ jsonwebtoken: Popular, 3.2M weekly downloads ✅
├─ passport: Popular, 1.8M weekly downloads ✅
└─ No risky sources ✅
```

### Security Patterns (🟠 Warning)

```
CRITICAL patterns: ✅ None
├─ eval(): ✅
├─ innerHTML injection: ✅
├─ Hardcoded secrets: ✅
├─ Prototype pollution: ✅
└─ SQL injection: ✅

HIGH patterns: ⚠️ 1 ISSUE
└─ Missing auth check
   ├─ Location: src/api.js:142
   ├─ Issue: API endpoint missing authentication guard
   ├─ Code: router.post('/api/user/settings', (req, res) => {
   ├─ Fix: Add authMiddleware check
   ├─ Example:
      router.post('/api/user/settings', authMiddleware, (req, res) => {
   └─ Priority: HIGH (fix before merge)

MEDIUM patterns: ✅ None
├─ Missing input validation: ✅
├─ Missing isBrowser guard: ✅
└─ Weak crypto: ✅

Secrets detection:
├─ API keys: ✅ None
├─ Tokens: ✅ None
├─ DB credentials: ✅ None
└─ Private keys: ✅ None
```

### Test Coverage (✅ Pass)

```
Coverage: 82% (target ≥80%) ✅
├─ Lines: 82%
├─ Branches: 80.5%
├─ Functions: 84%
└─ Statements: 82%

Delta: No change from main ✅
├─ New code: 100% covered ✅
├─ All branches tested: ✅
└─ Edge cases tested: ✅

Test suite:
├─ Tests: 234 passing
├─ Auth tests: +8 (new)
├─ No flaky tests: ✅
└─ All passing: ✅

Execution:
├─ Total time: 2m 14s
├─ Avg per test: 240ms
└─ Performance: ✅ Stable
```

### Build Success (✅ Pass)

```
Build system: npm (package.json)

Build commands:
├─ npm run build: ✅ SUCCESS
├─ Time: 1m 23s
└─ Exit code: 0 ✅

Artifacts:
├─ dist/index.js: ✅ 2.1 MB (no change)
├─ dist/index.css: ✅ 156 KB
├─ dist/types/: ✅ TypeScript definitions
└─ All present & non-empty ✅

Size check:
├─ Bundle: 2.1 MB (no change) ✅
├─ Gzipped: 450 KB ✅
├─ Assets: Optimized ✅
└─ Delta: 0% (excellent) ✅

Type checking:
├─ TypeScript: 0 errors ✅
├─ JSDoc: All documented ✅
└─ Type safety: ✅ PASS
```

### Performance (✅ Pass)

```
Bundle size impact: 0% (no change) ✅

Test performance:
├─ Total test time: 2m 14s (stable)
├─ Slowest test: 240ms (acceptable)
├─ Avg per test: 240ms ✅
└─ No flaky tests ✅

Slow endpoint check:
├─ POST /auth/login: 150ms ✅ (good)
├─ POST /auth/refresh: 80ms ✅ (good)
└─ N+1 queries: ✅ None detected
```

---

## Blocking Issues

✅ **NONE** — PR can be opened.

---

## Warnings (Fix Before Merge)

🟠 **HIGH PRIORITY (1 issue)**

1. **Missing auth guard on API endpoint**
   - Location: src/api.js:142
   - Issue: POST /api/user/settings lacks authentication
   - Impact: Could allow unauthorized settings changes
   - Fix:
     ```javascript
     // Before:
     router.post('/api/user/settings', (req, res) => {
     
     // After:
     router.post('/api/user/settings', authMiddleware, (req, res) => {
     ```
   - Severity: HIGH (required before merge)
   - Time to fix: 2 minutes
   - Test: auth tests already cover this scenario

---

## Recommendations

### ✅ Ready to PR
1. Fix auth guard issue above (2 min)
2. Push branch
3. Create PR

### 📋 PR Title & Description

```markdown
# feat(auth): OAuth 2.0 flow implementation

## What
Adds OAuth 2.0 authentication support with token refresh mechanism.

## Why
- Secures API endpoints with standard auth flow
- Adds token expiration and refresh logic
- Improves compliance with security best practices

## How
- Integrates jsonwebtoken v9.0.2
- Adds authMiddleware for protecting endpoints
- Implements token refresh logic
- Includes comprehensive test suite (8 new tests)

## Checklist
- [x] All tests passing (234/234)
- [x] Coverage maintained (82%)
- [x] Security audit clean
- [x] Build successful
- [ ] Fix auth guard on /api/user/settings (before merge)
- [ ] Security review (optional)

## Testing
- Unit tests: 8 new auth tests
- Integration tests: OAuth flow tested end-to-end
- Coverage: 100% on new code

Closes #156
```

### 🔍 Before Merge Checklist
- [ ] Fix HIGH security issue (auth guard)
- [ ] Re-run `/pr-check --full`
- [ ] Get code review approval
- [ ] Ensure CI checks all pass

---

## CI/CD Integration

Add to `.github/workflows/pr-security.yml`:

```yaml
name: PR Security Check

on: [pull_request]

jobs:
  security-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run PR Security Check
        run: /pr-check --full --report
      - name: Upload Report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: pr-security-report
          path: PR_SECURITY_REPORT.md
      - name: Comment on PR
        if: failure()
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: 'Security checks failed. See artifacts.'
            })
```

---

## Success Criteria

✅ **PASS** when:
- ✅ Git rules valid
- ✅ No sensitive files
- ✅ Zero lint errors
- ✅ Zero CRITICAL security
- ✅ Zero HIGH security (unless documented)
- ✅ Tests passing
- ✅ Coverage maintained
- ✅ Build succeeds

⚠️ **WARNINGS** when:
- HIGH security patterns (but documented/plan to fix)
- Coverage decreased
- Performance regression <20%

🔴 **BLOCKED** when:
- Linting errors
- Test failures
- CRITICAL security issues
- npm/pip audit CRITICAL
- Build failure
- Sensitive files committed

---

## Common Fixes

| Issue | Fix |
|-------|-----|
| `ESLint errors` | `npm run lint --fix` |
| `Prettier format` | `npm run format` |
| `Tests failing` | `npm test` + debug |
| `Coverage low` | Add tests for uncovered lines |
| `Security pattern` | Remove pattern or document exemption |
| `npm audit fails` | `npm audit fix` or `npm install package@version` |
| `Build error` | Fix TypeScript/build config |

---

## Exemptions

For rare cases where rule must be broken:

```javascript
// ⚠️ EXEMPTION: Missing auth guard (intentional)
// Issue: #1234, approved by @security-lead on 2026-04-07
// Sunset: 2026-07-07 (3 months)
// Reason: Public endpoint, rate limited at proxy layer
router.post('/api/public/subscribe', (req, res) => {
  // Rate limiter active at Cloudflare level
  // Verified in #1234
});
```

Requirements:
- Issue reference + approval signature
- Explicit `// exemption:` comment
- Sunset date (max 3 months)
- Documented in SECURITY.md
- Planned follow-up PR

---

**Generated by:** Global PR Security Check  
**Run date:** 2026-04-07T10:45:32Z  
**Next run:** On next push  
**Cache:** 72% hit (fast execution)
```

---

## Token Optimization

- **Parallel execution:** Linting, tests, audit run simultaneously
- **Cache reuse:** 24-hour cache for npm/pip audit
- **Smart detection:** Only test affected code
- **Batch output:** Single report per run

**Expected token usage:**
- Pre-commit check: 600-1,000 tokens
- Full check: 2,000-4,000 tokens
- With full report: +1,500 tokens

---

## Integration with `/test-global`

Works together:

```
PRE-COMMIT HOOK:
  /pr-check (quick validation)
       ↓ (fails? fix locally)
       ↓ (passes? continue)

GIT PUSH:
  /test-global --quick (changed files only)
       ↓ (issues? push fix)

PR OPENED:
  /pr-check --full (comprehensive validation)
  /test-global --full (full suite tests)
       ↓ (all pass? ready to review)

BEFORE MERGE:
  /pr-check --full (final validation)
  /test-global --full --cache-reset (fresh run)
       ↓ (all green? merge approved)
```

---

## Skill Interface

```bash
/pr-check [mode] [--checks=checks] [--fix] [--report] [pr-url-or-branch]

Mode:
  --pre-commit        Fast validation (default, 1-3 min)
  --full              Complete validation (5-15 min)
  --fix               Auto-fix + validate (2-5 min)

Checks (granular):
  --checks=git        Single check (or comma-separated list)
  --checks=linting,npm-audit,security

Options:
  --report            Generate markdown + JSON report
  [pr-url-branch]     Specific PR/branch (default: current)
```

**Returns:**
- Pass/fail status
- Detailed markdown report (if --report)
- JSON report (for CI automation)
- Actionable fixes + recommendations
- Exit code: 0 (can PR) / 1 (cannot PR)

**Token usage:**
- Single check: 300-600 tokens
- Multiple checks: 800-1,500 tokens
- Pre-commit: 600-1,200 tokens
- Full: 2,000-4,000 tokens
- With report: +1,500 tokens

**Execution time:**
- Single check: 30 sec - 2 min
- Multiple checks: 1-3 min
- Pre-commit: 1-3 min
- Full: 5-15 min
