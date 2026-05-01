<div align="center">
  <img src="docs/icon.png" width="120" alt="DeckReady">
  <h1>DeckReady</h1>
  <p>Turn Spotify URLs, TIDAL URLs, or text tracklists into tagged music files — organised for DJs.</p>
</div>

---

## Install (one command)

Open **Terminal** and paste:

```sh
curl -fsSL https://raw.githubusercontent.com/stephengeller/DeckReady-releases/main/install.sh | sh
```

That's it. The script downloads the latest DMG, copies **DeckReady** into `/Applications`, removes the macOS quarantine flag (so Gatekeeper won't block it), and launches the app.

> Pin a specific version with `DECKREADY_VERSION=v0.3.21 sh -c "$(curl -fsSL https://raw.githubusercontent.com/stephengeller/DeckReady-releases/main/install.sh)"`.
> Read [`install.sh`](./install.sh) before running if you want to know exactly what it does.

---

## Install manually

Prefer to do it yourself? Download `DeckReady-macOS-universal.dmg` from the [latest release](https://github.com/stephengeller/DeckReady-releases/releases/latest), drag **DeckReady** into `/Applications`, then run this once in Terminal so macOS doesn't block it:

```sh
xattr -dr com.apple.quarantine /Applications/DeckReady.app
```

You can now double-click **DeckReady** to launch.

<details>
<summary>If you'd rather click through System Settings instead of running a command</summary>

1. Try to open **DeckReady** — macOS shows a warning dialog. Click **OK** to dismiss it.
2. Open **System Settings → Privacy & Security**.
3. Scroll to the **Security** section and click **Open Anyway**.
4. Enter your Mac password if prompted.
5. Double-click **DeckReady** again — click **Open** in the final confirmation dialog.

Or right-click **DeckReady** in Applications, choose **Open**, then click **Open** in the dialog. macOS remembers your choice from then on.

</details>

> **Why is this needed?** DeckReady is not signed with an Apple Developer certificate, so macOS marks the downloaded DMG as quarantined. Stripping that flag tells macOS you trust the file.

---

## First launch

1. A ♪ icon appears in your menu bar.
2. Click **Log in to TIDAL** and complete authentication in your browser.
3. Paste a Spotify or TIDAL URL and click **Go**.
4. Files are saved to `~/Music/DJLibrary` by default (configurable in the UI).

---

## Requirements

- macOS (Apple Silicon / M-series)
- Internet connection
- TIDAL account

---

_Source code is private. For issues or questions, contact the maintainer._
