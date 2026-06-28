# AI Self PR Review Guidelines

To maintain code quality and prevent regressions, all pull requests must undergo a self-review performed by an AI agent before merging.

## 1. Review Agent Delegation
- The main developer agent must spawn a secondary "review" agent (subagent) using a different model or context (e.g. calling `spawn_subagent` with a review prompt).
- The review agent must be given:
  - The goal/task description.
  - The git diff of the PR.
  - Links to the modified files.

## 2. Review Scope and Rubric
The review agent must analyze the diff against the following:
- **Correctness & Logic**: Are there any off-by-one errors, edge case slips, or resource leaks?
- **Security**: Are there hardcoded secrets, injection risks, or permission bypasses?
- **Styling & Standards**: Does the code match the repository styling rules?
- **Lints**: Ensure no linter warnings were bypassed with inline disable overrides unless documented.

## 3. Formatting and Posting Reviews
- The review agent must compile a structured markdown review.
- The developer agent must attach the self-review report directly to the PR comments:
  ```markdown
  ### 🤖 AI Self-Review Report
  **Status**: [Approved / Request Changes]
  
  #### Summary of Changes
  ...
  
  #### Findings & Recommendations
  - [ ] Issue 1: ...
  ```

## 4. Addressing Feedback
- In case the review agent identifies any issues, they must be addressed on the PR.
- The fixes must be processed by the previously working AI agent or another active agent.
- A follow-up validation check must run after fixes are pushed.
