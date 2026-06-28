# Exclusive Repository Rules

These rules are strictly enforced for all development workflows. Bypassing these rules is prohibited.

## 1. Branch Naming Conventions
- All branches must be created using the following patterns:
  - Feature branches: `feature/<short-name>`
  - Bugfix branches: `bugfix/<short-name>`
- Do not commit directly to `main` or `master`.

## 2. Pull Request Metadata & Creation
- Every PR must have a clean header matching the conventional commit guidelines (e.g. `feat: <description>` or `fix: <description>`).
- The description must include:
  - **Purpose**: Why is this change being made?
  - **Work Done**: Specific modifications list.
  - **Regression Risk / Blast Radius**: The files and modules impacted.

## 3. Pull Request Check Verification
- Before merging, all automated build, test, and lint check suites must complete successfully.
- No PR can be merged with failing checks unless explicitly approved by the repository owner for hotfixes.

## 4. Visual Validation & Screenshots
For any change that introduces UI/visual modifications, the developer MUST:
1. **Capture a "before" screenshot**:
   - Checkout the base/main branch.
   - Start the local dev server.
   - Take a screenshot of the impacted UI.
   - Save it to `public/screenshots/before.png` in the repository.
2. **Capture an "after" screenshot**:
   - Checkout the task/feature branch.
   - Start the local dev server.
   - Take a screenshot of the modified UI.
   - Save it to `public/screenshots/after.png` in the repository.
3. **Commit both screenshots** to the task branch before raising the PR.
4. **Embed both screenshots in the PR body** using raw GitHub URLs:
   - Before: `![Before](https://raw.githubusercontent.com/<owner>/<repo>/<base-branch>/public/screenshots/before.png)`
   - After: `![After](https://raw.githubusercontent.com/<owner>/<repo>/<task-branch>/public/screenshots/after.png)`

## 5. SLA & Issue Addressing Timelines
- **Importance Policy**: This PR and verification ruleset is designated as the **2nd most important policy** of the repository.
- **Timeline**: Any issues, comments, or lint failures raised during review must be picked up and resolved within **3 working days**.
- **Assignment**: PR feedback fixes must be worked by the previously working AI agent, or delegated to another active AI agent.
