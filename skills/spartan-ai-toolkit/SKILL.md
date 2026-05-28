---
name: spartan-ai-toolkit
description: Enforces quality gates (typecheck -> lint -> test -> build) and stack profiles (React, TypeScript, Go, Python) to prevent agent code degradation. Use when running build check, lint check, typecheck, or init rules.
---
# Spartan AI Toolkit Workflow

This skill acts as an engineering discipline layer to enforce strict coding standards, stack-specific rules, and multi-stage validation pipelines.

## Target Triggers
- `/spartan`
- `/spartan:build`
- `/spartan:init-rules`
- `/spartan:debug`

## Operational Guidelines

You must route tasks through the appropriate pipeline phase and never bypass the quality gates:

### 1. Stack Profile Discovery
- Identify the project stack: React/TypeScript, Go, Python, Kotlin, or Java.
- Load target profile rules.
- Respect files matching `.spartan/rules/*` or project-specific coding guides.

### 2. The Verification Pipeline
For any feature development or bug fix, run the validation gates in sequence:
1. **Typecheck Gate**: Run compiler checks (e.g. `tsc --noEmit`, `go build`, `mypy .`).
2. **Lint Gate**: Run static lint analysis (e.g. `eslint`, `golangci-lint`, `ruff check`, `spotlessCheck`).
3. **Test Gate**: Run unit/integration tests (e.g. `npm test`, `go test ./...`, `pytest`).
4. **Build Gate**: Ensure production bundle builds successfully without warnings (e.g. `npm run build`, `mvn clean compile`).

> [!WARNING]
> If any step in the verification pipeline fails, do not proceed or modify testing files to cheat the gate. Fix the source bug and re-run all validation steps from the beginning.

### 3. Debugging Loop (`/spartan:debug`)
- When reproducing a bug, write a failing unit/integration test first to isolate the issue.
- Apply the minimal code fix.
- Re-run the verification pipeline (typecheck -> lint -> test).
