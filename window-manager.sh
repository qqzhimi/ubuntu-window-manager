#!/bin/bash

# ============================================
# 通用窗口管理脚本 v2
# toggle 支持三态: 启动 / 激活 / 最小化（同键开关）
# 用法: window-manager.sh <action> <程序名> <窗口标题关键词> <启动命令> [进程名]
# 标题关键词支持 | 分隔多个匹配项（大小写不敏感），如 "终端|Terminal|gnome-terminal"
# 示例: window-manager.sh toggle "终端" "终端|Terminal|gnome-terminal" "gnome-terminal" "gnome-terminal-server"
#       window-manager.sh toggle "微信" "微信|WeChat|wechat" "wechat"
#       window-manager.sh minimize "微信" "微信|WeChat"
# ============================================

APP_NAME="$1"      # 显示用的名称
WINDOW_TITLE="$2"  # 窗口标题关键词，多个用 | 分隔（如 "终端|Terminal"），用于 grep -iE
LAUNCH_CMD="$3"    # 启动程序的命令
PROCESS_NAME="$4"  # 可选：进程名（用于 pgrep 检测，如 gnome-terminal-server）

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# 检查依赖
check_dependencies() {
    local missing=()
    for cmd in xdotool wmctrl; do
        if ! command -v $cmd &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "缺少依赖: ${missing[*]}"
        log_error "请运行: sudo apt install ${missing[*]}"
        exit 1
    fi
}

# 获取窗口ID
# wmctrl -lx 输出格式: 0xWID PID 桌面 主机 窗口类 窗口标题
# 用 grep -iE 同时匹配标题和类名（大小写不敏感）
# WINDOW_TITLE 支持 | 分隔多个关键词，如 "终端|Terminal|gnome-terminal"
get_window_id() {
    if [ -z "$WINDOW_TITLE" ]; then
        echo ""
        return
    fi
    wmctrl -lx 2>/dev/null | grep -iE "$WINDOW_TITLE" | head -1 | awk '{print $1}'
}

# 检查进程是否已在运行
is_process_running() {
    if [ -n "$PROCESS_NAME" ]; then
        pgrep -x "$PROCESS_NAME" > /dev/null 2>&1
        return $?
    fi
    return 1
}

# 获取当前活跃窗口ID（输出十六进制，与 wmctrl 格式一致）
get_active_window_id() {
    local dec_id
    dec_id=$(xdotool getactivewindow 2>/dev/null)
    if [ -n "$dec_id" ]; then
        printf "0x%08x" "$dec_id"
    fi
}

# 激活窗口
activate_window() {
    local wid="$1"
    if [ -n "$wid" ]; then
        wmctrl -ia "$wid" 2>/dev/null
        xdotool windowactivate "$wid" 2>/dev/null
    fi
}

# ============================================
# toggle: 三态切换窗口
#   窗口不存在  →  启动程序
#   窗口存在，未激活 → 激活窗口
#   窗口存在，已激活 → 最小化窗口
# ============================================
toggle_window() {
    local wid
    wid=$(get_window_id)
    local active_wid
    active_wid=$(get_active_window_id)

    if [ -n "$wid" ]; then
        if [ "$wid" = "$active_wid" ]; then
            # 窗口已激活 → 最小化
            log_info "隐藏 $APP_NAME 窗口..."
            xdotool windowminimize "$wid" 2>/dev/null
        else
            # 窗口存在但未激活 → 激活
            log_info "激活 $APP_NAME 窗口..."
            activate_window "$wid"
        fi
        return
    fi

    # 窗口未找到，但进程可能已在运行（如托盘应用、无窗口进程）
    if is_process_running; then
        log_info "$APP_NAME 进程已在运行，但未找到窗口"
        return
    fi

    # 启动程序（使用锁文件防止竞态重复启动）
    local lock_file="/tmp/wm-${APP_NAME}.lock"
    if [ -f "$lock_file" ]; then
        # 锁文件存在，检查是否真的在启动中
        local lock_age=$(($(date +%s) - $(stat -c %Y "$lock_file" 2>/dev/null || echo 0)))
        if [ "$lock_age" -lt 5 ]; then
            log_info "$APP_NAME 正在启动中，请稍候..."
            return
        fi
    fi

    log_info "未找到 $APP_NAME 窗口，正在启动..."
    touch "$lock_file"
    nohup $LAUNCH_CMD > /dev/null 2>&1 &

    # 等待窗口出现（最多 3 秒）
    local wait_count=0
    while [ "$wait_count" -lt 30 ]; do
        sleep 0.1
        wid=$(get_window_id)
        [ -n "$wid" ] && break
        wait_count=$((wait_count + 1))
    done

    rm -f "$lock_file"

    if [ -n "$wid" ]; then
        log_info "$APP_NAME 已启动"
        sleep 0.3
        activate_window "$wid"
    else
        log_error "启动 $APP_NAME 超时，请检查启动命令: $LAUNCH_CMD"
    fi
}

# ============================================
# minimize: 最小化当前窗口（仅当匹配指定程序时）
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
        log_info "最小化 $APP_NAME 窗口"
        xdotool windowminimize "$active_wid" 2>/dev/null
    fi
}

# ============================================
# 帮助信息
# ============================================
show_help() {
    echo "用法: $0 <command> <app_name> <window_title> <launch_cmd> [process_name]"
    echo ""
    echo "命令:"
    echo "  toggle    三态切换（启动 / 激活 / 最小化）"
    echo "  minimize  最小化当前窗口（如果标题匹配）"
    echo ""
    echo "参数:"
    echo "  app_name       显示用的程序名称"
    echo "  window_title   窗口标题关键词，| 分隔多个（大小写不敏感）"
    echo "                 会同时匹配窗口标题和 WM_CLASS，如 \"终端|Terminal|gnome\""
    echo "  launch_cmd     启动命令"
    echo "  process_name   进程名（可选，pgrep 检测防重复启动）"
    echo ""
    echo "示例:"
    echo "  $0 toggle 终端 '终端|Terminal|gnome-terminal' gnome-terminal gnome-terminal-server"
    echo "  $0 toggle 微信 '微信|WeChat|wechat' wechat"
    echo "  $0 toggle Chrome 'Google Chrome|chrome' google-chrome chrome"
    echo "  $0 minimize 微信 '微信|WeChat'"
}

# ============================================
# 入口
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
                log_error "toggle 命令缺少参数"
                show_help
                exit 1
            fi
            toggle_window
            ;;
        minimize)
            APP_NAME="$1"
            WINDOW_TITLE="$2"
            if [ -z "$APP_NAME" ] || [ -z "$WINDOW_TITLE" ]; then
                log_error "minimize 命令缺少参数"
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
