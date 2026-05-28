---
name: tdd
description: Enforces writing failing tests (red-green-refactor loop) in Jest, PyTest, JUnit, Vitest, Go test, or RSpec before implementing or modifying backend logic.
---
# Test-First / Agentic TDD Playbook

This skill enforces strict Test-Driven Development (TDD) methodologies to prevent "vibe coding" and ensure correctness, regression protection, and clear specifications.

## Target Triggers
- `/tdd`
- `"implement feature with test-first"`
- `"write test first"`

## TDD Workflow Protocol

You must execute the standard Red-Green-Refactor loop systematically:

### 1. Requirements Discovery & Test Setup
- Identify the target framework, language, testing library (e.g., Jest, PyTest, Vitest, Go `testing`, RSpec, Mocha, JUnit, pytest-django).
- Locate the existing tests or find the correct directory structure for test files.
- Identify the expected API contract, function signature, or database constraints.

### 2. Write Failing Tests (Red Phase)
- Write unit or integration tests representing the target feature, endpoint, or bug fix.
- Ensure the tests cover:
  - **Happy paths** (successful requests, valid parameters, authenticated flows).
  - **Edge cases** (null/undefined inputs, empty strings, negative bounds, extremely large payloads).
  - **Error states** (missing headers, unauthorized access, database constraint violations, invalid parameter types).
- Run the test suite and confirm that the new test **fails** (RED). Note the error message to verify it fails for the expected reason (e.g., "function undefined" or "status code 404").

> [!IMPORTANT]
> Do NOT write any implementation code before demonstrating a failing test. If you skip this, you violate the TDD protocol.

### 3. Implement Minimum Code (Green Phase)
- Implement only the minimal logic required to make the failing test pass.
- Do not add extra unrequested features or over-engineer the code.
- Run the test suite. If it still fails, adjust the minimal implementation until it is green (PASS).

### 4. Clean & Refactor (Refactor Phase)
- Review the newly added code for readability, performance, naming conventions, and compliance with the design system.
- Remove duplication, ensure proper typing/schema definitions, and ensure separation of concerns.
- Re-run all tests to verify that the refactoring did not break any functionality.
