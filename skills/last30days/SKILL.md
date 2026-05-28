---
name: last30days
description: Search Reddit, X (Twitter), and the web for any topic, tool, or trend over the past 30 days and aggregate a report on user consensus, disagreements, and common pain points. Use when the user runs /last30days, asks for recent opinions on a tool or trend, or wants to check what people are saying about a topic lately.
---

# Last 30 Days (`last30days`)

Search Reddit, X, and the web for any topic, tool, or trend over the past 30 days, compiling user consensus, key debates, and common pain points.

## Parameters

| Parameter | Required | Description |
|---|---|---|
| `topic` | Yes | The topic, tool name, library, or trend to search for |

## Step-by-Step Instructions

### 1. Execute Platform Searches
Perform the following web searches using search tools:
- **Reddit search:** `<topic> site:reddit.com` (restrict/look for results in the last month)
- **X / Twitter search:** `<topic> site:x.com` or `<topic> site:twitter.com` (restrict/look for results in the last month)
- **Web search:** `<topic> reviews` or `<topic> issues` or `<topic> vs` (general web searches)

### 2. Extract and Filter Information
Focus on discussions from the past 30 days. Extract:
- Common praise and what users agree is working well
- Critical complaints, bug reports, and UX friction points
- Debate topics where opinions are polarized
- Real-world use cases mentioned by users

### 3. Generate Synthesis Report
Present a clean, scannable markdown report structured as follows:

```markdown
# Last 30 Days: {Topic}

*Report generated on YYYY-MM-DD from recent Reddit, X, and web discussions.*

## 📊 Summary of Sentiment
- **Consensus:** [Overall community stance - highly positive / mixed / highly critical]
- **Key Pain Point:** [The single most mentioned issue]

---

## 🟢 What Users Agree On (Consensus)
- **[Feature/Aspect 1]:** [Details of why users like it]
- **[Feature/Aspect 2]:** [Details]

## 🔴 Common Pain Points & Complaints
- **[Issue 1]:** [Details of what is broken, slow, or frustrating]
- **[Issue 2]:** [Details]

## 🟡 Key Debates (Where Users Disagree)
- **[Debate Topic]:** [Stance A vs. Stance B]

---

## 💬 Verbatim Highlights
> "[User quote from Reddit/X representing consensus/complaint]"
> "[User quote]"
```
