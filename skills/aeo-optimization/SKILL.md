---
name: aeo-optimization
description: Rewrite drafts or articles to optimize them for Answer Engine Optimization (AEO) and Generative Engine Optimization (GEO). Rewrites H2 headings into explicit questions, inserts a 50-80 word answer capsule immediately under each, and ensures the content is optimized for AI extraction. Use when the user asks to AEO-optimize content, run /aeo-optimize, or prepare an article for AI citation.
---

# AEO Optimization (`aeo-optimization`)

Optimize articles, Substack posts, or blog drafts so that AI search engines (like ChatGPT, Claude, and Perplexity) can cleanly extract and cite your answers.

## Step-by-Step Instructions

### 1. Identify H2 Headers & Key Questions
- Scan the input text for H2 headings or key sub-topics.
- Rephrase these H2 headings as explicit, natural-language questions that users ask AI engines (e.g. change "Benefits of Next.js" to "What are the key benefits of using Next.js?").

### 2. Craft Answer Capsules
Immediately under each question heading, insert an **Answer Capsule** following these rules:
- **Length:** Strictly 50 to 80 words.
- **Structure:** Direct and authoritative. Start immediately with the answer (no "Let's dive in" or conversational fluff).
- **Link-Free:** Do not put any hyperlinks inside this answer capsule (AI engines prefer link-free chunks for quoting).
- **Style:** Clear, declarative sentences.

### 3. Audit Body Prose
For the rest of the section's prose:
- Shorten paragraphs (keep them under 3-4 sentences to improve readability and machine scanning).
- Highlight named frameworks, original data points, or unique methodologies.
- Keep the writer's authentic voice, but remove statistical AI writing patterns.

### 4. Format Output
Return the rewritten article in markdown, highlighting the added Answer Capsules in blockquotes or labeled sections.
