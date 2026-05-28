---
name: notebooklm-connector
description: Automate NotebookLM actions using the agent-browser CLI. Supports creating notebooks, uploading sources (links, documents), and generating mindmaps or audio summaries. Use when the user runs /notebooklm, asks to automate NotebookLM, or wants to create audio summaries/study guides.
---

# NotebookLM Connector (`notebooklm-connector`)

Automates NotebookLM workflows such as creating notebooks, uploading research materials, and trigger output generation (e.g. Audio Summaries, Mindmaps).

## Prerequisites
- Requires `agent-browser` to be installed and authenticated to your Google Account.

## Step-by-Step Instructions

### 1. Launch NotebookLM
Open NotebookLM in `agent-browser`:
```bash
agent-browser open "https://notebooklm.google/"
```

### 2. Create Notebook
- Find the "New Notebook" button (typically a card with a `+` symbol or text "New Notebook").
- Click the button to create a new notebook workspace.

### 3. Add Sources
- Locate the "Add Source" modal.
- Support uploading:
  - **Links:** Input URLs to scrape.
  - **Documents:** Upload text files or PDFs from a specified path.
- Input the source details and confirm upload. Wait for processing indicators to clear.

### 4. Generate Outputs
Once sources are fully loaded, navigate the NotebookLM studio UI:
- **Audio Summary:** Locate the "Audio Overview" card, click "Generate" or "Play", and download the resulting file if complete.
- **Study Guide / Mindmap:** Click the respective guide templates and copy the text output.
