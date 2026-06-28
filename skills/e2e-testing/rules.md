# End-to-End Testing Rules

## 1. Test Isolation
- Ensure each test starts with a clean slate. Wipe or seed database fixtures before run.
- Do not let tests depend on the execution order of other tests.

## 2. Parallelization
- Enable test runner parallelization by default to keep feedback loops fast.
- Log failures, capture trace files, and record video clips on failed runs.
