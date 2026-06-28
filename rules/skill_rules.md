# Skill Integration Rules

Our repository skills must actively respect and enforce the rules defined in this directory.

## 1. merge-all-features Skill Integration
When executing `/merge-all-features` or the `merge-all-features` skill:
- **Check Validation**: The skill must poll or wait for all GitHub Action check runs to finish before flagging the branch as ready.
- **Self-Review**: It must spawn a reviewer subagent to generate a self-review report and write it to the PR comments.
- **Screenshots**: It must verify that `public/screenshots/before.png` and `public/screenshots/after.png` exist and are linked in the PR description if visual changes are present.

## 2. pr-create-from-commits Integration
When invoking `pr-create-from-commits`:
- The skill must validate the branch name against `feature/*` or `bugfix/*` naming rules.
- It must enforce that the generated PR description conforms to the metadata guidelines.

## 3. address-github-comments Integration
When running `address-github-comments`:
- The skill must align with the **3-day SLA** rule and confirm that issues are assigned to the previously working AI agent.
