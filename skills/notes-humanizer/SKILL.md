---
name: notes-humanizer
description: Humanize AI-generated text or drafts. Strips out machine-writing patterns (e.g. em-dashes, "let's dive in" hooks, rules of three, buzzwords) and adds human writing patterns (varying sentence lengths, personal opinions, specific concrete details, and conversational asides). Use when the user runs /humanize, asks to make text sound like a human wrote it, or wants to rewrite generic AI copy.
---
# Notes Humanizer (`notes-humanizer`)

Transforms dry, generic, or formulaic AI-generated drafts into natural, engaging prose that reads like it was written by an experienced human writer.

## Step-by-Step Instructions

### 1. Strip Out "AI-isms" (The Cleanse)
Scan the input text and remove the following machine-generated tells:
- **Hook clichés:** Avoid starting with "In today's fast-paced world...", "Let's dive in", "Crucial first step", or "It's important to remember".
- **Hollow buzzwords:** Remove or replace terms like *leverage*, *utilize*, *robust*, *streamline*, *testament*, *seamless*, *catalyst*, *revolutionize*, or *delve*.
- **Structure fatigue:** Strip out rigid "rule-of-three" list formats, excessive bullet points, and title-cased inline subheadings.
- **Punctuation tells:** Moderate the use of em-dashes (`—`), colons, and exclamation marks.

### 2. Inject Human Writing Characteristics
Rewrite the text by actively introducing these elements:
- **Varied Sentence Rhythm:** Alternating very short sentences (3-5 words) with longer, flowing ones. Break up monotonous sentence structures.
- **Specific Details:** Replace vague generalizations with concrete, real-world examples (e.g. change "streamlining your work" to "saving you an hour on Monday mornings").
- **Opinions & Asides:** Add subtle personal opinions, mild skepticism, or brief parentheses/asides (e.g., "(not exactly beginner-friendly, but it works)").
- **Active Voice:** Force active verbs and conversational sentence starters (e.g., use "I found that..." or "Here's what happens..." instead of passive explanations).

### 3. Generate Output
Provide:
1. **Humanized Draft:** The fully rewritten, natural text.
2. **Key adjustments made:** A brief list explaining what AI patterns were stripped and what human touches were added.
