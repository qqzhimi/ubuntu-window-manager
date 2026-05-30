#!/bin/bash

# ============================================
# 智能最小化：按 Esc 最小化当前窗口
# 根据激活窗口自动判断属于哪个程序并最小化
# ============================================

WINDOW=$(xdotool getactivewindow 2>/dev/null)
active_title=$(xdotool getwindowname "$WINDOW" 2>/dev/null)

if [ -z "$WINDOW" ] || [ -z "$active_title" ]; then
    exit 0
fi

# 窗口标题关键词 -> 程序名（仅用于日志）
declare -A APP_MAP=(
    ["微信"]="微信"
    ["Weixin"]="微信"
    ["WeChat"]="微信"
    ["Google Chrome"]="Chrome"
    ["Chrome"]="Chrome"
    ["Visual Studio Code"]="VS Code"
    ["Code"]="VS Code"
    ["终端"]="终端"
    ["Terminal"]="终端"
    ["gnome-terminal"]="终端"
    ["Obsidian"]="Obsidian"
    ["Thunderbird"]="邮件"
    ["收件箱"]="邮件"
    ["Files"]="文件管理器"
    ["Settings"]="系统设置"
    ["设置"]="系统设置"
)

for keyword in "${!APP_MAP[@]}"; do
    if echo "$active_title" | grep -qi "$keyword"; then
        app_name="${APP_MAP[$keyword]}"
        echo "[INFO] 最小化 $app_name"
        xdotool windowminimize "$WINDOW"
        exit 0
    fi
done

# 如果没匹配到任何已知程序，不做任何操作
# 取消下面注释可以最小化任意窗口:
# xdotool windowminimize "$WINDOW"
