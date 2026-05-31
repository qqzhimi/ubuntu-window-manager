#!/bin/bash

# ============================================
# GNOME Custom Keyboard Shortcut Configuration
# Usage: ./setup-shortcuts.sh [install_dir]
# Default install dir: $HOME/.local/bin/apps
# ============================================

set -e

# Install directory (where scripts live)
INSTALL_DIR="${2:-$HOME/.local/bin/apps}"
SCRIPT_NAME="$(basename "$0")"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# ============================================
# Remove all existing custom shortcuts (idempotent)
# ============================================
clear_shortcuts() {
    log_info "Clearing old shortcuts..."
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[]"
}

# ============================================
# Define shortcuts
# Format: index   name   command_path   key_binding
# Modify this array to customize shortcuts
# ============================================
declare -A SHORTCUTS

i=0
# ---- Google Chrome ----
SHORTCUTS["${i}_name"]="Open/Switch Chrome"
SHORTCUTS["${i}_cmd"]="$INSTALL_DIR/chrome.sh"
SHORTCUTS["${i}_key"]="<Primary><Alt>e"
((++i))

# ---- Terminal ----
SHORTCUTS["${i}_name"]="Open/Switch Terminal"
SHORTCUTS["${i}_cmd"]="$INSTALL_DIR/terminal.sh"
SHORTCUTS["${i}_key"]="<Primary><Alt>a"
((++i))

# ---- VS Code ----
SHORTCUTS["${i}_name"]="Open/Switch VS Code"
SHORTCUTS["${i}_cmd"]="$INSTALL_DIR/vscode.sh"
SHORTCUTS["${i}_key"]="<Primary><Alt>c"
((++i))

# ---- WeChat ----
SHORTCUTS["${i}_name"]="Open/Switch WeChat"
SHORTCUTS["${i}_cmd"]="$INSTALL_DIR/wechat.sh"
SHORTCUTS["${i}_key"]="<Primary><Alt>w"
((++i))

# ---- Obsidian ----
SHORTCUTS["${i}_name"]="Open/Switch Obsidian"
SHORTCUTS["${i}_cmd"]="$INSTALL_DIR/obsidian.sh"
SHORTCUTS["${i}_key"]="<Primary><Alt>s"
((++i))

# ---- File Manager ----
SHORTCUTS["${i}_name"]="Open/Switch File Manager"
SHORTCUTS["${i}_cmd"]="$INSTALL_DIR/file-manager.sh"
SHORTCUTS["${i}_key"]="<Primary><Alt>q"
((++i))

# ---- Flameshot ----
SHORTCUTS["${i}_name"]="Flameshot Screenshot"
SHORTCUTS["${i}_cmd"]="/usr/bin/flameshot gui"
SHORTCUTS["${i}_key"]="<Primary><Alt>z"
((++i))

# ---- Global Close (Ctrl+Esc) ----
SHORTCUTS["${i}_name"]="Global Close Current Window"
SHORTCUTS["${i}_cmd"]="$INSTALL_DIR/close-window.sh"
SHORTCUTS["${i}_key"]="<Primary>Escape"
((++i))

TOTAL=$i

# ============================================
# Apply shortcuts
# ============================================
apply_shortcuts() {
    log_info "Applying $TOTAL shortcuts..."

    # Build custom-keybindings path list
    local paths="["
    for ((j=0; j<TOTAL; j++)); do
        if [ $j -gt 0 ]; then paths+=", "; fi
        paths+="'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${j}/'"
    done
    paths+="]"

    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$paths"

    # Configure each shortcut
    for ((j=0; j<TOTAL; j++)); do
        local base="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${j}/"
        local name="${SHORTCUTS[${j}_name]}"
        local cmd="${SHORTCUTS[${j}_cmd]}"
        local key="${SHORTCUTS[${j}_key]}"

        # Check if the command file exists
        if [[ "$cmd" == "$INSTALL_DIR/"* ]] && [ ! -f "$cmd" ]; then
            log_warn "Skipping $name: command file not found ($cmd)"
            continue
        fi

        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$base" name "$name"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$base" command "$cmd"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$base" binding "$key"

        echo "  ✓ $name → $key"
    done

    echo ""
    log_info "Shortcut setup complete! Log out and back in for changes to take effect."
    echo ""
    echo "  Key notation:"
    echo "    <Primary> = Ctrl"
    echo "    <Alt>     = Alt"
    echo "    <Shift>   = Shift"
    echo "    <Super>   = Win / Super key"
    echo ""
    echo "  To change shortcuts, edit this script and re-run."
}

# ============================================
# Show current shortcuts
# ============================================
show_shortcuts() {
    echo "Current Shortcuts:"
    echo "──────────────────────────────────────────────"
    for ((j=0; j<TOTAL; j++)); do
        printf "  %-20s  %-20s  %s\n" \
            "${SHORTCUTS[${j}_key]}" \
            "${SHORTCUTS[${j}_name]}" \
            "${SHORTCUTS[${j}_cmd]}"
    done
    echo "──────────────────────────────────────────────"
}

# ============================================
# Entry point
# ============================================
main() {
    case "${1:-apply}" in
        apply|setup)
            clear_shortcuts
            apply_shortcuts
            ;;
        show|list)
            show_shortcuts
            ;;
        help|--help|-h)
            echo "Usage: $0 [apply|show|help] [install_dir]"
            echo ""
            echo "  apply   Apply shortcuts (default)"
            echo "  show    Show currently configured shortcuts"
            echo "  help    Show this help"
            echo ""
            echo "Examples:"
            echo "  $0                          # Apply with default install dir"
            echo "  $0 apply ~/my-scripts/apps  # Custom install directory"
            echo "  $0 show                     # View shortcuts"
            ;;
        *)
            log_error "Unknown command: $1"
            echo "Usage: $0 [apply|show|help] [install_dir]"
            exit 1
            ;;
    esac
}

main "$@"
