#!/bin/bash

# ============================================
# Universal Window Manager Script v3
# toggle supports multi-window cycling:
#   0 windows       →  launch the app
#   all minimized   →  activate window 1
#   window N active →  activate window N+1 (if not the last)
#   last active     →  minimize all
# Usage: window-manager.sh <action> <app_name> <window_title_keywords> <launch_cmd> [process_name]
# Title keywords support | as separator for multiple patterns (case-insensitive),
#   e.g. "Terminal|gnome-terminal|终端"
# Examples:
#   window-manager.sh toggle "Terminal" "Terminal|gnome-terminal|终端" "gnome-terminal" "gnome-terminal-server"
#   window-manager.sh toggle "WeChat" "WeChat|wechat|微信" "wechat"
#   window-manager.sh minimize "WeChat" "WeChat|微信"
# ============================================

APP_NAME="$1"      # Display name for the application
WINDOW_TITLE="$2"  # Window title keywords, | separated (e.g. "Terminal|终端"), used with grep -iE
LAUNCH_CMD="$3"    # Command to launch the application
PROCESS_NAME="$4"  # Optional: process name for pgrep detection (e.g. gnome-terminal-server)

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Logging helpers
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check for required dependencies
check_dependencies() {
    local missing=()
    for cmd in xdotool wmctrl; do
        if ! command -v $cmd &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing dependencies: ${missing[*]}"
        log_error "Please run: sudo apt install ${missing[*]}"
        exit 1
    fi
}

# Get the first matching window ID (single-window scenarios)
get_window_id() {
    if [ -z "$WINDOW_TITLE" ]; then
        echo ""
        return
    fi
    wmctrl -lx 2>/dev/null | grep -iE "$WINDOW_TITLE" | head -1 | awk '{print $1}'
}

# Get all matching window IDs (multi-window cycling)
# Returns one hex window ID per line
get_all_window_ids() {
    if [ -z "$WINDOW_TITLE" ]; then
        return
    fi
    wmctrl -lx 2>/dev/null | grep -iE "$WINDOW_TITLE" | awk '{print $1}'
}

# Check if the process is already running
is_process_running() {
    if [ -n "$PROCESS_NAME" ]; then
        pgrep -x "$PROCESS_NAME" > /dev/null 2>&1
        return $?
    fi
    return 1
}

# Get the current active window ID (hex, matching wmctrl format)
get_active_window_id() {
    local dec_id
    dec_id=$(xdotool getactivewindow 2>/dev/null)
    if [ -n "$dec_id" ]; then
        printf "0x%08x" "$dec_id"
    fi
}

# Activate a window by ID
activate_window() {
    local wid="$1"
    if [ -n "$wid" ]; then
        wmctrl -ia "$wid" 2>/dev/null
        xdotool windowactivate "$wid" 2>/dev/null
    fi
}

# ============================================
# launch_app: Start the application and wait for its window
# ============================================
launch_app() {
    # Window not found, but the process may still be running (e.g. tray apps, headless processes)
    if is_process_running; then
        log_info "$APP_NAME process is already running, but no window found"
        return
    fi

    # Launch the program (use lock file to prevent race-condition duplicate launches)
    local lock_file="/tmp/wm-${APP_NAME}.lock"
    if [ -f "$lock_file" ]; then
        # Lock file exists — check if the app is genuinely launching
        local lock_age=$(($(date +%s) - $(stat -c %Y "$lock_file" 2>/dev/null || echo 0)))
        if [ "$lock_age" -lt 5 ]; then
            log_info "$APP_NAME is already launching, please wait..."
            return
        fi
    fi

    log_info "No $APP_NAME window found, launching..."
    touch "$lock_file"
    nohup $LAUNCH_CMD > /dev/null 2>&1 &

    # Wait for a window to appear (up to 3 seconds)
    local wid
    local wait_count=0
    while [ "$wait_count" -lt 30 ]; do
        sleep 0.1
        wid=$(get_window_id)
        [ -n "$wid" ] && break
        wait_count=$((wait_count + 1))
    done

    rm -f "$lock_file"

    if [ -n "$wid" ]; then
        log_info "$APP_NAME started"
        sleep 0.3
        activate_window "$wid"
    else
        log_error "Launching $APP_NAME timed out. Check the launch command: $LAUNCH_CMD"
    fi
}

# ============================================
# toggle: Multi-window cycling
#   0 windows      →  launch the app
#   all minimized  →  activate window 1
#   window N active → activate window N+1 (if not the last)
#   last active    →  minimize all
# ============================================
toggle_window() {
    local all_wids=()
    while IFS= read -r wid; do
        [ -n "$wid" ] && all_wids+=("$wid")
    done < <(get_all_window_ids)

    local count=${#all_wids[@]}

    # No windows → launch
    if [ "$count" -eq 0 ]; then
        launch_app
        return
    fi

    local active_wid
    active_wid=$(get_active_window_id)

    # Find the position of the currently active window in the list
    local active_idx=-1
    local i
    for ((i=0; i<count; i++)); do
        if [ "${all_wids[$i]}" = "$active_wid" ]; then
            active_idx=$i
            break
        fi
    done

    if [ "$active_idx" -lt 0 ]; then
        # No window is active (all minimized) → activate the first
        log_info "Activate $APP_NAME window (1/$count)..."
        activate_window "${all_wids[0]}"
    elif [ "$active_idx" -eq $((count - 1)) ]; then
        # Last window active → minimize all
        log_info "Hide all $APP_NAME windows ($count)..."
        for wid in "${all_wids[@]}"; do
            xdotool windowminimize "$wid" 2>/dev/null
        done
    else
        # Activate the next window
        local next_idx=$((active_idx + 1))
        log_info "Switch to $APP_NAME window ($((next_idx + 1))/$count)..."
        activate_window "${all_wids[$next_idx]}"
    fi
}

# ============================================
# minimize: Minimize the current window (only if it matches the app)
# ============================================
minimize_current() {
    local active_wid
    local active_title

    active_wid=$(xdotool getactivewindow 2>/dev/null)
    if [ -z "$active_wid" ]; then
        return
    fi

    active_title=$(xdotool getwindowname "$active_wid" 2>/dev/null)

    if echo "$active_title" | grep -qi "$WINDOW_TITLE"; then
        log_info "Minimize $APP_NAME window"
        xdotool windowminimize "$active_wid" 2>/dev/null
    fi
}

# ============================================
# Help
# ============================================
show_help() {
    echo "Usage: $0 <command> <app_name> <window_title> <launch_cmd> [process_name]"
    echo ""
    echo "Commands:"
    echo "  toggle    Multi-window cycling (launch / activate next / minimize all)"
    echo "  minimize  Minimize current window (if title matches)"
    echo ""
    echo "Arguments:"
    echo "  app_name       Display name for the application"
    echo "  window_title   Window title keywords, | separated (case-insensitive)"
    echo "                 Matches both window title and WM_CLASS, e.g. \"Terminal|terminal|终端\""
    echo "  launch_cmd     Launch command"
    echo "  process_name   Process name (optional, pgrep detection to prevent duplicate launches)"
    echo ""
    echo "Examples:"
    echo "  $0 toggle Terminal 'Terminal|terminal|gnome-terminal|终端' gnome-terminal gnome-terminal-server"
    echo "  $0 toggle WeChat 'WeChat|wechat|微信' wechat"
    echo "  $0 toggle Chrome 'Google Chrome|chrome' google-chrome chrome"
    echo "  $0 minimize WeChat 'WeChat|微信'"
}

# ============================================
# Entry point
# ============================================
main() {
    check_dependencies

    local action="$1"
    shift

    case "$action" in
        toggle)
            APP_NAME="$1"
            WINDOW_TITLE="$2"
            LAUNCH_CMD="$3"
            PROCESS_NAME="$4"
            if [ -z "$APP_NAME" ] || [ -z "$WINDOW_TITLE" ] || [ -z "$LAUNCH_CMD" ]; then
                log_error "toggle command needs more arguments"
                show_help
                exit 1
            fi
            toggle_window
            ;;
        minimize)
            APP_NAME="$1"
            WINDOW_TITLE="$2"
            if [ -z "$APP_NAME" ] || [ -z "$WINDOW_TITLE" ]; then
                log_error "minimize command needs more arguments"
                show_help
                exit 1
            fi
            minimize_current
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
}

main "$@"
