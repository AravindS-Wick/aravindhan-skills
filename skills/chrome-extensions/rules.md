# Chrome Extensions Development Rules

## 1. Manifest V3 Standard
- Never use Manifest V2 features. All background logic must run in a service worker.
- Keep background scripts lightweight and ephemeral (do not rely on persistent state in memory).

## 2. Secure Content Scripts
- Restrict content script permissions to the narrowest possible domain patterns.
- Content scripts must NEVER directly access external APIs or execute arbitrary scripts from remote sources. Communicate with the background service worker via `chrome.runtime.sendMessage`.

## 3. Communication and State
- Enforce strict typing for messaging payloads.
- Use `chrome.storage.local` or `chrome.storage.sync` for state persistence across sessions.

## 4. Multi-Agent Delegation
- For testing different parts of an extension (popup, content script, options page), spawn parallel subagents to write targeted tests and inspect DOM components.
