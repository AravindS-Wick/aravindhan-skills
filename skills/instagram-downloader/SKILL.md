---
name: instagram-downloader
description: Download high-resolution images, carousels, or reels from Instagram URLs using the agent-browser CLI. Stitches carousel slides into a single PDF if requested. Use when the user runs /instagram-downloader or asks to download/extract media from an Instagram URL.
---

# Instagram Downloader (`instagram-downloader`)

Downloads high-resolution images, carousels, or reels from Instagram URLs using `agent-browser`.

## Prerequisites
- Requires `agent-browser` to be installed and configured in the system path.

## Parameters

| Parameter | Required | Description |
|---|---|---|
| `url` | Yes | The Instagram post or reel URL |
| `--pdf` | No | Stitch carousel images into a single PDF |

## Step-by-Step Instructions

### 1. Launch Agent Browser
Run the following command to open the Instagram post:
```bash
agent-browser open "{url}"
```

### 2. Extract Media Source URLs
- Inspect the page elements to find `<img src="...">` and `<video src="...">` tags.
- For carousels, use `agent-browser` to click the next/right arrow button (typically targets with attributes like `aria-label="Next"` or class names containing chevron/arrow) to load all slides into the DOM.
- Identify the high-resolution source URLs hosted on `*.cdninstagram.com`.

### 3. Download the Files
- Download each extracted URL using curl/wget or standard file write tools:
  ```bash
  curl -o "slide_N.jpg" "{cdn_url}"
  ```
- Save them into a folder named after the post's caption or date.

### 4. Optional PDF Stitching
If the `--pdf` flag is provided and the post is a carousel:
- Use python or local image tools to stitch the downloaded `slide_N.jpg` files into a single PDF named `carousel.pdf`.
