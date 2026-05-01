#!/usr/bin/env bash
#
# DeckReady installer for macOS.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/stephengeller/DeckReady-releases/main/install.sh | sh
#
# What it does:
#   1. Downloads the latest DeckReady DMG from GitHub Releases.
#   2. Copies DeckReady.app into /Applications (replacing any existing copy).
#   3. Removes the macOS quarantine attribute so Gatekeeper won't block it.
#   4. Launches the app.
#
# DeckReady is not signed with an Apple Developer certificate; this script
# bypasses Gatekeeper by stripping the com.apple.quarantine xattr that macOS
# applies to anything downloaded from the internet. Trust model is identical
# to manually downloading the DMG from the same repo.
#
# Pin a specific version with: DECKREADY_VERSION=v0.3.20 sh install.sh

set -eu

REPO="stephengeller/DeckReady-releases"
APP_NAME="DeckReady"
DMG_NAME="DeckReady-macOS-universal.dmg"
APP_DEST="/Applications/${APP_NAME}.app"

bold()   { printf '\033[1m%s\033[0m\n' "$*"; }
info()   { printf '  %s\n' "$*"; }
warn()   { printf '\033[33m  ! %s\033[0m\n' "$*"; }
err()    { printf '\033[31m  ✗ %s\033[0m\n' "$*" >&2; }

[ "$(uname -s)" = "Darwin" ] || { err "This installer only runs on macOS."; exit 1; }
command -v curl >/dev/null   || { err "curl is required."; exit 1; }
command -v hdiutil >/dev/null || { err "hdiutil is required (macOS built-in)."; exit 1; }

bold "DeckReady installer"

# ─── Resolve the release to install ────────────────────────────────────────────
if [ -n "${DECKREADY_VERSION:-}" ]; then
  TAG="$DECKREADY_VERSION"
  DMG_URL="https://github.com/${REPO}/releases/download/${TAG}/${DMG_NAME}"
  info "Installing pinned version ${TAG}"
else
  info "Looking up the latest release…"
  API_JSON=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest")
  TAG=$(printf '%s' "$API_JSON" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
  [ -n "$TAG" ] || { err "Could not determine latest version. Network or rate-limit issue?"; exit 1; }
  DMG_URL="https://github.com/${REPO}/releases/download/${TAG}/${DMG_NAME}"
  info "Latest is ${TAG}"
fi

# ─── Detect currently-installed version ────────────────────────────────────────
if [ -d "$APP_DEST" ]; then
  if pgrep -fx "${APP_DEST}/Contents/MacOS/${APP_NAME}" >/dev/null 2>&1 \
     || pgrep -fx "${APP_DEST}/Contents/Resources/bin/deckready --ui" >/dev/null 2>&1 \
     || pgrep -f "${APP_DEST}/Contents" >/dev/null 2>&1; then
    warn "${APP_NAME} is currently running. Quitting it so it can be replaced…"
    osascript -e "tell application \"${APP_NAME}\" to quit" 2>/dev/null || true
    # Give it a moment, then force-kill any stragglers spawned from the bundle.
    sleep 2
    pkill -f "${APP_DEST}/Contents" 2>/dev/null || true
    sleep 1
  fi
fi

# ─── Download ─────────────────────────────────────────────────────────────────
TMP=$(mktemp -d -t deckready-install)
cleanup() { [ -n "${MOUNTED:-}" ] && hdiutil detach -quiet "$MOUNTED" 2>/dev/null || true; rm -rf "$TMP"; }
trap cleanup EXIT INT TERM

DMG_PATH="${TMP}/${DMG_NAME}"
info "Downloading ${DMG_NAME} (~120 MB)…"
curl -fL --progress-bar -o "$DMG_PATH" "$DMG_URL" || { err "Download failed from $DMG_URL"; exit 1; }

# ─── Mount + copy ─────────────────────────────────────────────────────────────
info "Mounting DMG…"
# Use -plist for deterministic output: -quiet suppresses the device table too,
# and the non-quiet form interleaves checksum lines with the table on stdout.
# The plist format also handles mount points with spaces (e.g. "/Volumes/DeckReady 1"
# when a stale mount from a previous run is still attached).
MOUNTED=$(hdiutil attach -nobrowse -noautoopen -plist "$DMG_PATH" 2>/dev/null \
          | grep -o '<string>/Volumes/[^<]*</string>' \
          | head -n1 \
          | sed 's|<string>||; s|</string>||')
[ -n "$MOUNTED" ] && [ -d "$MOUNTED/${APP_NAME}.app" ] \
  || { err "Could not find ${APP_NAME}.app inside the DMG."; exit 1; }

if [ -d "$APP_DEST" ]; then
  info "Replacing existing ${APP_DEST}…"
  rm -rf "$APP_DEST" 2>/dev/null || {
    warn "Could not remove ${APP_DEST}. Re-running with sudo…"
    sudo rm -rf "$APP_DEST"
  }
fi

info "Copying to ${APP_DEST}…"
ditto "$MOUNTED/${APP_NAME}.app" "$APP_DEST" 2>/dev/null || {
  warn "Copy failed. Retrying with sudo…"
  sudo ditto "$MOUNTED/${APP_NAME}.app" "$APP_DEST"
}

hdiutil detach -quiet "$MOUNTED" 2>/dev/null || true
unset MOUNTED

# ─── Strip quarantine ─────────────────────────────────────────────────────────
info "Removing macOS quarantine flag…"
xattr -dr com.apple.quarantine "$APP_DEST" 2>/dev/null || true

# ─── Launch ───────────────────────────────────────────────────────────────────
bold "✓ Installed ${APP_NAME} ${TAG}"
info "Launching ${APP_NAME}…"
open "$APP_DEST" || warn "Could not auto-launch. Open it from /Applications."
