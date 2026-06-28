# Minor & Optional Guidelines

This document outlines optional checks and protocols for deferring non-blocking changes to subsequent tasks.

## 1. Blocker vs. Non-Blocker Mappings

When reviewing a PR, issues must be classified:
- **Blockers**: Any changes causing build failures, test crashes, runtime errors, regression risks, or security gaps. These must be fixed before merging.
- **Non-Blockers**: Refactoring proposals, minor formatting tweaks, performance enhancements, or extra test coverage.

## 2. Deferral to Follow-up Stories
- If a review identifies non-blocking issues, the PR may still be merged, provided that:
  1. The issues are documented as a follow-up task.
  2. The task is appended to the repository's **Pending Status Details** log (e.g. `PENDING_TASKS.md` or repository description).
  3. The story is scheduled to be completed within 3 working days of the merge.

## 3. Optional Checks
- Spell check and documentation comments are recommended but not mandatory for blocker status.
- Adding example scripts is encouraged for complex features.
