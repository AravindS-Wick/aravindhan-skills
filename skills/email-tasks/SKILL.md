---
name: email-tasks
description: Read and triage the user's Gmail inbox using Gmail automation tools. Pulls emails from a recent window (e.g. past 8 hours), filters out notifications/receipts/newsletters, and presents a list of emails requiring action or reply. Use when the user runs /email-tasks, asks to check their emails, or wants a summary of pending email tasks.
---

# Email Tasks (`email-tasks`)

Triage your Gmail inbox to identify high-priority messages that require immediate replies, decisions, or action.

## Prerequisites
- Requires Gmail API credentials or OAuth configured (`gmail-automation` skill dependencies).

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `hours` | `8` | The lookup window in hours |

## Step-by-Step Instructions

### 1. Fetch Inbox Messages
- Call your Gmail list/search tool (e.g., `gmail_list_messages` or search command) with a query for the past `hours` hours (e.g. `after:{timestamp}`).
- Extract basic metadata (Sender, Subject, Date, Body Snippet).

### 2. Filter Clutter
Inspect each email's sender and snippet:
- **Exclude:** Marketing newsletters, automatic notifications (build status, JIRA updates), receipts, and confirmation codes.
- **Include:** Direct messages from colleagues, clients, or partners containing questions, requests, or action items.

### 3. Summarize Actionable Emails
For each actionable email, summarize:
- **Who:** The sender's name and organization.
- **What:** The core request or question.
- **Urgency:** Low/Medium/High.
- **Draft Reply:** A suggested one-sentence opener or complete reply based on context.

### 4. Format Output
Return the summarized list of tasks clearly formatted in markdown.
