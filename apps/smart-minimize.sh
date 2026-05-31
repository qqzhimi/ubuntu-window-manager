#!/bin/bash

# ============================================
# Smart Minimize: press Esc to minimize current window
# Auto-detects which app the active window belongs to and minimizes it
# ============================================

WINDOW=$(xdotool getactivewindow 2>/dev/null)
active_title=$(xdotool getwindowname "$WINDOW" 2>/dev/null)

if [ -z "$WINDOW" ] || [ -z "$active_title" ]; then
    exit 0
fi

# Window title keywords → app name (for logging)
declare -A APP_MAP=(
    ["WeChat"]="WeChat"
    ["微信"]="WeChat"
    ["Weixin"]="WeChat"
    ["Google Chrome"]="Chrome"
    ["Chrome"]="Chrome"
    ["Visual Studio Code"]="VS Code"
    ["Code"]="VS Code"
    ["Terminal"]="Terminal"
    ["终端"]="Terminal"
    ["gnome-terminal"]="Terminal"
    ["Obsidian"]="Obsidian"
    ["Thunderbird"]="Mail"
    ["收件箱"]="Mail"
    ["Files"]="File Manager"
    ["Settings"]="System Settings"
    ["设置"]="System Settings"
)

for keyword in "${!APP_MAP[@]}"; do
    if echo "$active_title" | grep -qi "$keyword"; then
        app_name="${APP_MAP[$keyword]}"
        echo "[INFO] Minimizing $app_name"
        xdotool windowminimize "$WINDOW"
        exit 0
    fi
done

# If no known app matched, do nothing
# Uncomment the line below to minimize any window regardless:
# xdotool windowminimize "$WINDOW"
