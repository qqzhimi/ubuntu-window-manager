#!/bin/bash

# ============================================
# Ubuntu Window Manager - One-Click Uninstaller
# Usage: ./uninstall.sh
#   Silent mode: ./uninstall.sh -y  (skip confirmation)
# ============================================

set -e

DEFAULT_BIN_DIR="$HOME/.local/bin"
DEFAULT_APPS_DIR="$DEFAULT_BIN_DIR/apps"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1" >&2; }
log_step()  { echo -e "\n${BOLD}▶ $1${NC}"; }

# ============================================
# Clear GNOME shortcuts
# ============================================
clear_shortcuts() {
    log_step "Clearing GNOME shortcuts..."
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[]"
    log_info "Shortcuts cleared"
}

# ============================================
# Remove installed files
# ============================================
remove_files() {
    log_step "Removing script files..."

    local removed=0

    if [ -f "$DEFAULT_BIN_DIR/window-manager.sh" ]; then
        rm -f "$DEFAULT_BIN_DIR/window-manager.sh"
        echo "  ✓ window-manager.sh"
        removed=$((removed + 1))
    fi

    if [ -f "$DEFAULT_BIN_DIR/setup-shortcuts.sh" ]; then
        rm -f "$DEFAULT_BIN_DIR/setup-shortcuts.sh"
        echo "  ✓ setup-shortcuts.sh"
        removed=$((removed + 1))
    fi

    if [ -d "$DEFAULT_APPS_DIR" ]; then
        local app_count=$(ls "$DEFAULT_APPS_DIR"/*.sh 2>/dev/null | wc -l)
        rm -rf "$DEFAULT_APPS_DIR"
        echo "  ✓ $DEFAULT_APPS_DIR/ ($app_count scripts)"
        removed=$((removed + app_count))
    fi

    # Clean up temporary lock files
    rm -f /tmp/wm-*.lock 2>/dev/null || true

    if [ "$removed" -eq 0 ]; then
        log_warn "No installed files found—may already be uninstalled"
    else
        log_info "Removed $removed files"
    fi
}

# ============================================
# Done
# ============================================
finish() {
    echo ""
    echo "  ✅ Uninstall complete!"
    echo "  System dependencies (xdotool, wmctrl) have been preserved; remove manually if desired."
    echo "  If shortcuts still work, log out and back in."
    echo ""
}

# ============================================
# Entry point
# ============================================
main() {
    echo ""
    echo "  Ubuntu Window Manager - One-Click Uninstaller"
    echo ""

    if [ "${1:-}" != "-y" ]; then
        read -rp "  Confirm uninstall? [y/N] " answer
        if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
            echo "  Cancelled."
            exit 0
        fi
    fi

    clear_shortcuts
    remove_files
    finish
}

main "$@"
