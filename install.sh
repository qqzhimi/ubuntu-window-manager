#!/bin/bash

# ============================================
# Ubuntu Window Manager - One-Click Installer
# Usage: after git clone, run ./install.sh
# ============================================

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
APPS_DIR="$BIN_DIR/apps"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info()  { echo -e "  ${GREEN}✓${NC} $1"; }
log_warn()  { echo -e "  ${YELLOW}!${NC} $1"; }
log_error() { echo -e "  ${RED}✗${NC} $1" >&2; }

echo ""
echo "  Ubuntu Window Manager - One-Click Installer"
echo ""

# ---- Install dependencies ----
missing=()
for dep in xdotool wmctrl; do
    command -v "$dep" &>/dev/null || missing+=("$dep")
done
if [ ${#missing[@]} -gt 0 ]; then
    echo "  Installing dependencies: ${missing[*]}..."
    sudo apt update -qq && sudo apt install -y "${missing[@]}"
fi
log_info "Dependencies ready (xdotool, wmctrl)"

# ---- Copy scripts ----
mkdir -p "$APPS_DIR"

cp "$REPO_DIR/window-manager.sh" "$BIN_DIR/window-manager.sh"
chmod +x "$BIN_DIR/window-manager.sh"

cp "$REPO_DIR/setup-shortcuts.sh" "$BIN_DIR/setup-shortcuts.sh"
chmod +x "$BIN_DIR/setup-shortcuts.sh"

shopt -s nullglob
count=0
for script in "$REPO_DIR"/apps/*.sh; do
    cp "$script" "$APPS_DIR/$(basename "$script")"
    chmod +x "$APPS_DIR/$(basename "$script")"
    count=$((count + 1))
done
shopt -u nullglob
log_info "Installed $count app scripts → $APPS_DIR/"

# ---- Configure shortcuts ----
if "$BIN_DIR/setup-shortcuts.sh" apply "$APPS_DIR"; then
    log_info "Shortcuts configured"
else
    log_warn "Shortcut configuration failed. Run manually: setup-shortcuts.sh apply $APPS_DIR"
fi

# ---- PATH check ----
if ! echo "$PATH" | grep -q "$BIN_DIR"; then
    echo ""
    echo "  ⚠  $BIN_DIR is not in PATH. Please add:"
    echo "      export PATH=\"$BIN_DIR:\$PATH\""
fi

echo ""
echo "  🎉 Installation complete! Log out and back in for shortcuts to take effect."
echo ""
