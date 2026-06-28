# Git Worktree Rules

## 1. Scoped Workspaces
- Use `git worktree add` to spin up isolated folders for checking out different branches.
- Do not share `node_modules` between worktrees if dependencies differ.

## 2. Cleanup Protocol
- Always run `git worktree prune` after deleting a branch to clean up references.
