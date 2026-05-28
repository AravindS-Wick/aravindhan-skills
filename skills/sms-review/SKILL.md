---
name: sms-review
description: Pre-push code review for SMS and SmsBulk changes. Checks feature flag wrapping, exposed/debug code, React bad practices, dangerous linter disabling, DRY violations, and MCDS CSS compliance. Scoped to web/js/src/Main/Sms and web/js/src/Main/SmsBulk. Use before pushing or creating a PR for any SMS-related frontend changes, or whenever the user says "review my SMS changes", "check my SMS code", or asks if their SMS/SmsBulk changes are ready to push.
---
# SMS Code Review — Pre-Push Gate

Scoped to: `web/js/src/Main/Sms/**` and `web/js/src/Main/SmsBulk/**`

Run this before pushing or raising a PR for any SMS frontend changes. Output a **PASS ✅** or **FAIL ❌** verdict per category. If any category fails, the push should be blocked until fixed.

## Scope options

The skill accepts an optional argument to narrow the diff scope:

| Invocation | Scope |
|---|---|
| `/sms-review` | Both `Sms/` and `SmsBulk/` (default) |
| `/sms-review sms` | `web/js/src/Main/Sms/**` only |
| `/sms-review bulk` | `web/js/src/Main/SmsBulk/**` only |

---

## Steps

### 1. Determine scope and get the diff

Check whether the user passed `sms` or `bulk` as an argument:

- **`sms` argument** — diff only `Sms/`:
  ```bash
  git diff origin/main -- "web/js/src/Main/Sms/**"
  git diff --name-only origin/main -- "web/js/src/Main/Sms/**"
  ```

- **`bulk` argument** — diff only `SmsBulk/`:
  ```bash
  git diff origin/main -- "web/js/src/Main/SmsBulk/**"
  git diff --name-only origin/main -- "web/js/src/Main/SmsBulk/**"
  ```

- **No argument (default)** — diff both:
  ```bash
  git diff origin/main -- "web/js/src/Main/Sms/**" "web/js/src/Main/SmsBulk/**"
  git diff --name-only origin/main -- "web/js/src/Main/Sms/**" "web/js/src/Main/SmsBulk/**"
  ```

Read each changed file fully where necessary to verify the checks below.

---

### 2. Run all checks

For each category, output: category name, verdict (PASS ✅ / FAIL ❌), and specific file + line citations for any failures.

---

## Check 1 — Feature Flag Wrapping

**FAIL if any of the following are found:**

- A flag check is commented out and replaced with a hardcoded `true` or `false`:
  ```js
  // ❌ Bypasses experiment entirely
  shouldShowX: true, // MC_Flag::isOn(SOME_FLAG) ? $result : false
  ```
- A flag check lives at the **call site** rather than inside the component or function it gates. The gated component should own its own eligibility:
  ```jsx
  // ❌ Flag leaks to parent — parent shouldn't know about child's internals
  {isOn(FLAGS.SOME_FLAG) && <MyComponent />}

  // ✅ Component self-contains the guard
  function MyComponent() {
    if (!isOn(FLAGS.SOME_FLAG)) return null;
    ...
  }
  ```
- A new UI feature or behaviour has no flag at all, but is not behind an existing entry-point gate. New unbounded features must be flagged.
- Variables instantiated for experiment/flag evaluation (e.g. `$experiment->shouldShow()`) whose result is never actually used in the return value.
- Duplicate flag gating: the same flag checked both in a parent and inside the child component without a clear reason.

---

## Check 2 — Exposed / Debug Code

**FAIL if any of the following are found:**

- `console.log`, `console.warn`, `console.error` left in production code paths (not inside `catch` blocks or test files).
- Commented-out code blocks that contain real logic (not explanatory comments), especially commented-out flag checks or experiment guards:
  ```php
  // ❌ Real conditional left as comment
  "shouldShow" => true, // MC_Flag::isOn(...) ? $result : false
  ```
- Hardcoded external URLs inline in JSX or component logic. URLs must be named constants or come from config:
  ```jsx
  // ❌
  href="https://mailchimp.com/help/about-sms-marketing-credits/#..."

  // ✅
  const CREDITS_HELP_URL = 'https://mailchimp.com/help/about-sms-marketing-credits/...';
  href={CREDITS_HELP_URL}
  ```
- Hardcoded API keys, auth tokens, or credentials anywhere in non-test code.
- Debug-only props (`debug={true}`, `verbose`, `trace`) left on components in production paths.
- `TODO`/`FIXME` comments that indicate incomplete or unsafe logic that must be resolved before shipping.

---

## Check 3 — React Bad Practices

**FAIL if any of the following are found:**

- **Functions recreated every render**: plain functions or objects defined inside a component body that have no dependency on props/state should be moved outside the component. Functions that do depend on state/props must be wrapped in `useCallback` or `useMemo`:
  ```tsx
  // ❌ Recreated on every render
  function MyComp() {
    const formatPhone = (n: string) => n.replace(...);
    const parseDate = (d: unknown): number | null => { ... };
    ...
  }

  // ✅ Outside the component — no deps
  const formatPhone = (n: string) => n.replace(...);
  ```

- **Magic number initial state**: `useState` initialised with a raw number instead of a named constant:
  ```tsx
  useState(1)         // ❌ what does 1 mean?
  useState(BannerState.InitialHold) // ✅
  ```

- **IIFEs inside JSX**: immediately-invoked function expressions in the render tree make JSX unreadable. Extract to a variable before `return`:
  ```tsx
  // ❌
  <Text>{(() => { if (x) return 'a'; return 'b'; })()}</Text>

  // ✅
  const label = x ? 'a' : 'b';
  <Text>{label}</Text>
  ```

- **Missing cleanup in async `useEffect`**: any `useEffect` that fires an async operation (fetch, promise) must use a `cancelled` guard to prevent setState on unmounted components:
  ```tsx
  // ❌ — no cleanup
  useEffect(() => {
    fetchData().then((res) => setState(res));
  }, []);

  // ✅
  useEffect(() => {
    let cancelled = false;
    fetchData().then((res) => { if (!cancelled) setState(res); });
    return () => { cancelled = true; };
  }, []);
  ```

- **Stale or unused deps in hooks**: a variable listed in `useEffect`/`useCallback`/`useMemo` dependency arrays that is never read inside the hook body. Also flag deps that are missing but should be present.

- **Same hook called multiple times**: if a hook like `usePricingMessages` or `pricingFlaggedMessage` is called more than once in the same component with overlapping parameters, the calls must be merged into one.

- **Derived state stored in `useState`**: if a value can be computed from existing props or state without side effects, it must not be stored in `useState`. Use a regular variable or `useMemo`.

- **`null` vs `undefined` inequality inconsistency**: use `!= null` (loose) to guard both `null` and `undefined`. Using `!== null` (strict) misses the `undefined` case when a TypeScript type allows it:
  ```ts
  // ❌ undefined passes through as truthy
  const hasHold = phoneTimerSetDate !== null;

  // ✅
  const hasHold = phoneTimerSetDate != null;
  ```

---

## Check 4 — Dangerous Linter / Type Disabling

**FAIL if any of the following are found without an explanatory comment immediately above the line:**

- `// eslint-disable` (line, next-line, or block) — especially for security rules:
  - `no-eval`, `no-script-url`, `react/no-danger`
  - `no-unused-expressions`, `eqeqeq`

- `// @ts-ignore` or `// @ts-nocheck` — type errors must be fixed, not suppressed. If a third-party type is wrong, use `// @ts-expect-error` with a description.

- `/* eslint-disable */` block-level disables with no scope comment explaining why.

Any disable that exists solely to silence a real problem (rather than a false positive) is a FAIL.

---

## Check 5 — DRY (Don't Repeat Yourself)

**FAIL if any of the following are found:**

- The same JSX block (>10 lines) appears more than once. Extract to a component or shared variable:
  ```tsx
  // ❌ — autoRefillContent JSX block duplicated in both branches
  {showSection ? (
    <div>{/* 100 lines */}</div>
  ) : (
    <div>{/* same 100 lines */}</div>
  )}

  // ✅ — use the variable in both branches
  const autoRefillContent = <div>...</div>;
  {showSection ? <>{subscriptionCard}{autoRefillContent}</> : autoRefillContent}
  ```

- The same computation appears twice under different variable names with the same inputs:
  ```tsx
  // ❌ — identical computation, different names
  const selectedTierPriceNum = getTotalPrice(formattedPricing[selectedMonthlyTier]?.[currency?.id]);
  const recurringTierPriceNum = getTotalPrice(formattedPricing[selectedMonthlyTier]?.[currency?.id]);
  ```

- Magic strings used in multiple places instead of a shared constant (e.g. step names, event names, CSS class names used conditionally in multiple spots).

- The same conditional expression copy-pasted in more than two locations — extract to a named boolean.

---

## Check 6 — XSS, Semantics, Accessibility

**FAIL if any of the following are found:**

**XSS:**
- `dangerouslySetInnerHTML` used without `DOMPurify.sanitize()` wrapping the value
- `innerHTML` assigned directly without sanitisation
- User-controlled string concatenated into a URL `href` without sanitisation — use `DOMPurify.sanitize()` or restrict to a safe allow-list of origins
- `eval()` or `new Function()` called with any dynamic input

**Semantic HTML:**
- `<div>` or `<span>` used where a semantic element is correct: `<button>`, `<a>`, `<nav>`, `<main>`, `<header>`, `<section>`, `<article>`, `<aside>`, `<ul>`/`<ol>`/`<li>`
- Click handlers attached to non-interactive elements (`div`, `span`) without both `role` and a keyboard event handler (`onKeyDown` / `onKeyUp` covering Enter/Space)
- `<table>` used for layout rather than tabular data

**Accessibility (WCAG 2.2 Level AA):**
- Interactive elements (buttons, links, inputs, toggles) missing an accessible label: `aria-label`, `aria-labelledby`, or visible inner text
- Images missing `alt` attributes (decorative images must have `alt=""`)
- `tabIndex={-1}` on a visually clickable element without an explanatory comment confirming intent
- Form inputs missing an associated `<label>` (either wrapping or via `htmlFor` / `id` pairing)
- `hideLabel` prop used on a Wink component without an accessible label alternative supplied via a separate prop (e.g. `label` on `Select`, `ToggleButton`)
- Colour or icon used as the sole indicator of state — must be paired with text or an `aria-*` attribute

---

## Check 7 — Custom CSS Bypassing MCDS

**FAIL if any of the following are found:**

- Inline `style={{ }}` props that use raw colour hex values or pixel values that map to design tokens. Use `@mc/wink` components or CSS variables:
  ```tsx
  // ❌ Bypasses MCDS token
  style={{ color: '#21262A' }}
  style={{ color: '#C84F00', display: 'flex' }}

  // ✅ Use MCDS component or token variable
  style={{ color: 'var(--color-content-primary)' }}
  ```

- Custom `.css` / `.less` rules that override MCDS component internals using deep selectors (e.g. `.wink-button .inner { ... }`).

- New CSS class names for spacing, typography, or colour that duplicate values already available via MCDS tokens or utility classes.

- `!important` declarations used to override MCDS styles.

---

## 3. Output format

```
## SMS Pre-Push Review

**Branch:** <branch-name>
**Scope:** Sms + SmsBulk / Sms only / SmsBulk only  ← use whichever applies
**Files changed in scope:** <count>

| # | Check | Verdict |
|---|-------|---------|
| 1 | Feature Flag Wrapping | ✅ PASS / ❌ FAIL |
| 2 | Exposed / Debug Code  | ✅ PASS / ❌ FAIL |
| 3 | React Bad Practices   | ✅ PASS / ❌ FAIL |
| 4 | Linter Disabling      | ✅ PASS / ❌ FAIL |
| 5 | DRY                   | ✅ PASS / ❌ FAIL |
| 6 | XSS / Semantics / A11y | ✅ PASS / ❌ FAIL |
| 7 | Custom CSS / MCDS     | ✅ PASS / ❌ FAIL |

### Failures

For each ❌: list the file, line number, a one-line description, and a concise code fix.

### Verdict

**PUSH BLOCKED** — fix all ❌ failures before pushing.
— or —
**CLEAR TO PUSH** — no blocking failures found.
```

---

## Notes

- Files in `**/__tests__/`, `**.test.ts`, `**.test.tsx`, `**.test.js` are excluded from checks 2, 3, and 7.
- NLS translation files (`data/nls/**`) are always skipped.
- If no SMS/SmsBulk files are changed in the diff, output: "No SMS/SmsBulk files changed — review not required."
