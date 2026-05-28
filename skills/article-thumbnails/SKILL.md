---
name: article-thumbnails
description: Generate article and newsletter thumbnail candidates using the Gemini API. Analyzes article copy, constructs image prompts matching brand specs, calls the model, and evaluates candidates. Use when the user runs /article-thumbnails, asks to create a newsletter/article thumbnail, or wants image candidates for an article.
---

# Article Thumbnails (`article-thumbnails`)

Generates and evaluates brand-appropriate thumbnail candidates for articles or newsletters using Gemini models.

## Prerequisites
- Requires `GEMINI_API_KEY` to be set in the environment.

## Step-by-Step Instructions

### 1. Analyze Article Copy
- Read the article text or link provided by the user.
- Identify the core theme, key concepts, tone (e.g. technical, casual, minimal), and metaphoric visual ideas.

### 2. Suggest Visual Concepts
Propose 3 distinct visual compositions based on the article's theme and your brand guidelines.
- **Concept 1 (Conceptual):** Abstract representation of the core idea.
- **Concept 2 (Literal/Concrete):** Showing a practical scenario or object.
- **Concept 3 (Minimalist/Graphic):** Strong typography and simple icons/shapes.

### 3. Generate Image Candidates
Ask the user to select their preferred concept. Once selected:
- Construct a detailed image generation prompt following Gemini best practices (specifying subject, style, lighting, composition, and color palette).
- Call your Gemini image generation script or tool with the prompt:
  ```bash
  python3 scripts/call_gemini_image.py --prompt "{detailed_prompt}" --candidates 3
  ```
- Save the resulting images in a local `assets/` folder.

### 4. Evaluate and Select
- Use your Vision capabilities to inspect the generated candidate images.
- Review each candidate against your brand specifications (correct logo colors, text alignment, and aesthetic appeal).
- Present the best candidates to the user with a brief rationale for each.
