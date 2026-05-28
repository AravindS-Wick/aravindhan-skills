---
name: substack-notes-scraper
description: Scrape Substack Notes metrics for a specific author and time period. Uses agent-browser to load the page, scrolls to fetch all posts, extracts metrics (likes, comments, restacks), and formats them as a structured spreadsheet (.xlsx). Use when the user runs /substack-notes-scraper, asks to scrape/analyze Substack notes, or wants a metrics report on Substack posts.
---

# Substack Notes Scraper (`substack-notes-scraper`)

Scrapes author notes from Substack and compiles dates, text, likes, comments, restacks, and links into a structured spreadsheet.

## Prerequisites
- Requires `agent-browser` and a spreadsheet writing utility (like Python's `openpyxl` or `pandas`).

## Parameters

| Parameter | Required | Description |
|---|---|---|
| `url` | Yes | The Substack notes page URL (e.g. `https://substack.com/@username/notes`) |
| `period` | No | Date range to filter (e.g., "last 30 days", "April 2026") |

## Step-by-Step Instructions

### 1. Load Notes Page
Run `agent-browser` to open the Substack notes page:
```bash
agent-browser open "{url}"
```

### 2. Scroll and Fetch Content
- Use `agent-browser` to scroll the page downwards recursively to load older notes.
- Stop scrolling once the posts' dates go beyond the target `period` or no new elements load.
- Extract the following data points for each note:
  - **Date/Timestamp**
  - **Note Text** (first 100 characters for identification)
  - **Likes Count**
  - **Comments Count**
  - **Restacks Count**
  - **Direct URL Link**

### 3. Generate Metrics Spreadsheet
- Filter out restacks from other authors to avoid noise.
- Write the parsed entries into a structured Excel file (`substack_notes_metrics.xlsx`).
- Format the sheet with frozen headers, bold text, and column width auto-fitting.

### 4. Output Summary
Provide a brief overview of the top 3 best-performing notes by engagement (likes + restacks) and the link to download the generated `.xlsx` file.
