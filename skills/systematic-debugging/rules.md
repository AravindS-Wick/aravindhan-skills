# Systematic Debugging Rules

## 1. Hypothesis Validation Loop
- Do not guess fixes. First, reproduce the error locally.
- Formulate a list of possible root causes.
- Test each hypothesis methodically, documenting outcomes.

## 2. Bisecting Regressions
- For regression bugs, run `git bisect` to locate the exact commit that introduced the failure.
