---
name: chrome-extension-media-sniffer
description: Implementation specifications for browser extension-based media sniffing, stream parsing (HLS/DASH), DOM scraping, and local/remote helper backends for video downloading.
---
# chrome-extension-media-sniffer

This skill defines the technical implementation guidelines for browser extension media sniffing, intercepting network requests, parsing playlist files (HLS/M3U8/DASH), resolving hidden high-resolution media source tags, and orchestrating downloads using a remote/local python helper backend.

---

## 📡 1. Network Interception (Request & Response Header Sniffing)

To sniff streaming and resource chunks reliably in MV3 extensions:
- Set up dynamic interceptors via the background `service-worker.js`:
  ```javascript
  chrome.webRequest.onBeforeRequest.addListener(
    (details) => {
      // Filter details.url for target media formats: .m3u8, .mpd, .mp4, .mp3, etc.
    },
    { urls: ["<all_urls>"] }
  );
  ```
- Sniff headers to capture resource sizes (e.g. `content-length`):
  ```javascript
  chrome.webRequest.onHeadersReceived.addListener(
    (details) => {
      const contentLengthHeader = details.responseHeaders.find(
        (h) => h.name.toLowerCase() === "content-length"
      );
      if (contentLengthHeader) {
        const sizeBytes = parseInt(contentLengthHeader.value);
        // Save resource size mapping to cache/storage
      }
    },
    { urls: ["<all_urls>"] },
    ["responseHeaders"]
  );
  ```

---

## 🔍 2. DOM Scraper & Dynamic Cleaners

Inject or run content scripts (`content-script.js`) to capture immediate elements:
- **Videos/Audios**: Gather all standard source files:
  ```javascript
  document.querySelectorAll('video, audio, source').forEach(el => {
    const url = el.src || el.currentSrc;
    // Save element sources
  });
  ```
- **Images**: Extract clean, high-resolution original URLs by stripping device or responsive-resizer parameters:
  - **Unsplash**: Match `images.unsplash.com` and replace query parameters with `?q=85&fm=jpg`.
  - **Pexels**: Replace resizer subpaths or queries with `?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=1600` or equivalent originals.
  - **Wikimedia**: Replace thumbnail paths (`/thumb/.../page.jpg/...px-page.jpg`) with the direct file namespace.
- **E-Commerce Elements**: Scan page arrays, scripts, and product layout divs to find lazy-loaded variant details.

---

## 🎼 3. Stream & Playlist Playlist Parsing

For HLS (`.m3u8`) playlists:
- Fetch the playlist structure using clean HTTP request headers:
  ```javascript
  async function parseHlsPlaylists(url) {
    const res = await fetch(url);
    const content = await res.text();
    // Parse bandwidth lines (e.g., #EXT-X-STREAM-INF:BANDWIDTH=...) to extract resolutions.
  }
  ```

---

## 💻 4. Python-Based Backend Helper (`yt-dlp` integration)

When client-side extraction is blocked, delegate downloading to a containerized Python backend running `yt-dlp`:
- **Docker Setup**: Ensure the container has `python3`, `ffmpeg`, and `yt-dlp` installed.
- **Dynamic Config**: Bind to `0.0.0.0` and utilize the `PORT` environment variable:
  ```python
  import os
  from flask import Flask
  app = Flask(__name__)
  port = int(os.environ.get("PORT", 8080))
  ```
- **Fallback Directory**: Ensure downloads are saved to a temporary directory writable inside server environments (e.g. `/tmp` or `tempfile.gettempdir()`).
