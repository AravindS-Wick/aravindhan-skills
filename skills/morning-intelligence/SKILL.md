---
name: morning-intelligence
description: Generate a personalized daily morning briefing based on your professional role, focus areas, and preferred news sources. Use when the user runs /morning-intelligence, asks for their daily brief, or sets up a scheduled briefing routine.
---

# Morning Intelligence (`morning-intelligence`)

Generates a customized, high-signal morning briefing tailored to your role and focus areas by reading news, trends, and release updates.

## Step-by-Step Instructions

### 1. Conduct Interview (First-time setup only)
If the user's role profile does not exist in `.morning-profile.json`:
- Ask the following questions sequentially:
  1. What is your current professional role?
  2. What are the key technology pillars or topics you want to track?
  3. Are there specific websites, newsletters, or RSS feeds you want to check?
  4. What type of information should be excluded (e.g. general gossip, specific companies)?
- Save the answers in `.morning-profile.json`.

### 2. Fetch News and Updates
Based on the saved profile:
- Run searches for recent news, blog posts, and repository release tags from the past 24 hours.
- Scrape RSS feeds or configured URLs using the search/scraping tools.

### 3. Synthesize the Briefing
Group the gathered stories into the user's defined pillars and format the briefing:

```markdown
# ☀️ Morning Intelligence Briefing

*Generated on YYYY-MM-DD for {Role}*

## 🚀 Key Highlights (Top 3)
1. **[Highlight 1]:** [Brief description and impact]
2. **[Highlight 2]:** [Brief description]
3. **[Highlight 3]:** [Brief description]

---

## 💻 Tech & Engineering Updates
- **[Source/Repo Name]:** [Summary of new releases or critical issues]

## 📈 Industry Trends & News
- **[Topic]:** [Summary of discussion/news]
```
