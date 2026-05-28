---
name: code-simplifier
description: Takes recently modified or complex code blocks and refactors them for readability and simplicity without changing behavioral logic. Use when refactoring complex logic, cleaning up nested conditions, or simplifying code structure.
---
# Code Simplification Playbook

This skill instructs the agent to analyze recently changed or complex code blocks and simplify them, preserving exact behavioral logic while removing unnecessary complexity.

## Target Triggers
- `/simplify`
- `"simplify code"`
- `"clean up logic complexity"`

## Design Standards & Constraints

### 1. Behavior Preservation
- Under no circumstances should the logic's external behavior, return values, or side effects change.
- Do not introduce new libraries or framework dependencies unless explicitly requested.

### 2. Complexity Mitigation
- **Nested Conditionals**: Convert nested `if` statements into early returns/guard clauses.
- **Ternary Abuse**: Replace multi-nested ternary operations (`a ? b : c ? d : e`) with readable variable declarations or standard `if/else` statements.
- **Boolean Simplifications**: Reduce redundant boolean checks (e.g. `if (x === true)` to `if (x)`).
- **Function Responsibility**: Extract sub-functions if a single block is doing multiple unrelated things.

### 3. Readability & Conventions
- Ensure code conforms to styles defined in `CLAUDE.md` or local linting configurations.
- Prefer explicit naming over overly clever, short variable names.
