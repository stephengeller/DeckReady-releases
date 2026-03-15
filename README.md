# DeckReady — Releases

This repository hosts downloadable releases of **DeckReady**, a macOS app that turns Spotify URLs, TIDAL URLs, or text tracklists into tagged music files organized for DJ use.

## Download

**[Download the latest release →](https://github.com/stephengeller/DeckReady-releases/releases/latest)**

1. Download `DeckReady-darwin-arm64.dmg` from the releases page.
2. Open the DMG and drag **DeckReady** to your Applications folder.
3. Double-click **DeckReady** in Applications to launch.
4. A ♪ icon appears in your menu bar — the UI opens automatically in your browser.

> If macOS blocks the app ("unidentified developer"): open **System Settings → Privacy & Security** and click **Open Anyway**.

## Requirements

- macOS (Apple Silicon)
- Internet connection
- TIDAL account (for downloads)

## What it does

Paste a Spotify or TIDAL URL into the UI and click **Go**. DeckReady:

1. Fetches track metadata from Spotify or TIDAL
2. Finds and downloads matching audio via TIDAL
3. Converts to AIFF and organizes files in `~/Music/DJLibrary`

## Troubleshooting

- If TIDAL login is needed, use the login button in the UI
- Output files go to `~/Music/DJLibrary` by default

---

*Source code is private. For issues or questions, contact the maintainer.*
