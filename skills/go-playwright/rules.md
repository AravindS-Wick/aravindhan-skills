# Go Playwright Rules

## 1. Resource Lifecycle
- Always close browser, context, and page instances via deferred calls (`defer browser.Close()`).
- Verify error returns for all setup commands.

## 2. Synchronization
- Use Context-driven waiting to prevent tests from blocking indefinitely.
- Rely on Playwright's built-in wait features.
