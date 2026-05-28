---
name: context-mode
description: Optimize session memory and filter out shell command output clutter. Keeps a running log of the current session state (active files, current tasks, and progress) in the workspace to allow quick recovery and prevent token bloat. Use when the user runs /context-mode or asks to clean up active memory, log the current session state, or reduce session sluggishness.
---

# Context Mode (`context-mode`)

Optimizes the agent's context window by filtering out verbose shell output clutter and maintaining a lightweight session state log.

## Step-by-Step Instructions

### 1. Clutter Filtering
When executing command line operations:
- Filter out verbose diagnostic output, dependency build details, or standard compilation logs.
- Only keep critical stdout/stderr outputs, exit codes, and compile-time errors in the context.
- For commands with long output, pipe/truncate or inspect specific line ranges (e.g. `head -n 20` or `grep`).

### 2. Session Logging
Keep a running, lightweight log of your session state. If it does not exist, create a file named `.session-context.json` (or `.session-context.md`) in the repository root containing:
- **Active Files:** The absolute paths of files currently being modified.
- **Current Task:** The specific task you are executing.
- **Next Steps:** What remains to be done.
- **Session History:** A brief bullet-point list of what was already done in this session.

### 3. State Restoration
If the context window gets reset or if the session starts feeling sluggish:
- Read `.session-context.json` to immediately restore your state, active files, and objectives without requiring the user to re-explain the task.
