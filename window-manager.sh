#!/bin/bash

# ============================================
# 通用窗口管理脚本
# 用法: window-manager.sh <action> <程序名> <窗口标题关键词> <启动命令>
# 示例: window-manager.sh toggle "微信" "Weixin" "wechat"
#       window-manager.sh minimize "微信" "Weixin"
# ============================================

APP_NAME="$1"      # 显示用的名称
WINDOW_TITLE="$2"  # 窗口标题关键词（用于查找窗口）
LAUNCH_CMD="$3"    # 启动程序的命令

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

# 获取窗口ID（支持部分标题匹配）
get_window_id() {
    xdotool search --name "$WINDOW_TITLE" 2>/dev/null | head -1
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
# toggle: 切换窗口（没有则启动，有则激活）
# ============================================
toggle_window() {
    local wid
    wid=$(get_window_id)

    if [ -z "$wid" ]; then
        # 窗口不存在 → 启动程序
        log_info "未找到 $APP_NAME 窗口，正在启动..."
        nohup $LAUNCH_CMD > /dev/null 2>&1 &

        # 等待窗口出现（最多 3 秒）
        local wait_count=0
        while [ -z "$wid" ] && [ $wait_count -lt 30 ]; do
            sleep 0.1
            wid=$(get_window_id)
            wait_count=$((wait_count + 1))
        done

        if [ -n "$wid" ]; then
            log_info "$APP_NAME 已启动"
            sleep 0.3
            activate_window "$wid"
        else
            log_error "启动 $APP_NAME 超时，请检查启动命令: $LAUNCH_CMD"
        fi
    else
        # 窗口已存在 → 激活
        log_info "激活 $APP_NAME 窗口..."
        activate_window "$wid"
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
    echo "用法: $0 <command> <app_name> <window_title> [launch_cmd]"
    echo ""
    echo "命令:"
    echo "  toggle    切换窗口（没有则启动，有则激活）"
    echo "  minimize  最小化当前窗口（如果标题匹配）"
    echo ""
    echo "示例:"
    echo "  $0 toggle  微信 Weixin wechat"
    echo "  $0 toggle  终端 Terminal gnome-terminal"
    echo "  $0 minimize 微信 Weixin"
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
