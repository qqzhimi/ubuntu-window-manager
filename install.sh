#!/bin/bash

# ============================================
# Ubuntu 窗口管理器 - 一键安装脚本
# 用法: git clone 后直接运行 ./install.sh
# ============================================

set -e

# 脚本所在目录（仓库根目录）
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 默认安装路径
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
# 检查系统
# ============================================
check_system() {
    echo ""
    echo "  ╔══════════════════════════════════════════╗"
    echo "  ║   Ubuntu 窗口管理器 一键安装脚本       ║"
    echo "  ╚══════════════════════════════════════════╝"
    echo ""

    # 检查是否在 GNOME 下
    if [ "$XDG_CURRENT_DESKTOP" != "GNOME" ] && [ "$XDG_CURRENT_DESKTOP" != "ubuntu:GNOME" ]; then
        log_warn "未检测到 GNOME 桌面环境 (当前: $XDG_CURRENT_DESKTOP)"
        log_warn "快捷键设置可能无效，其他功能不受影响。"
        echo ""
    fi

    # 检查必要依赖
    log_step "检查系统依赖..."
    local missing=()
    for dep in xdotool wmctrl; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        log_warn "缺少依赖: ${missing[*]}"
        read -rp "  是否安装? [Y/n] " answer
        if [ "$answer" != "n" ] && [ "$answer" != "N" ]; then
            sudo apt update
            sudo apt install -y "${missing[@]}"
            log_info "依赖安装完成"
        else
            log_error "依赖未安装，窗口管理功能将无法使用"
            exit 1
        fi
    else
        log_info "xdotool、wmctrl 已就绪"
    fi
}

# ============================================
# 安装脚本
# ============================================
install_scripts() {
    log_step "安装脚本..."

    # 确认安装目录
    echo "  脚本将安装到: $DEFAULT_APPS_DIR"
    echo "  核心脚本安装到: $DEFAULT_BIN_DIR"
    read -rp "  确认? [Y/n] " answer
    if [ "$answer" = "n" ] || [ "$answer" = "N" ]; then
        read -rp "  自定义安装目录: " custom_dir
        DEFAULT_BIN_DIR="${custom_dir%/bin}"
        DEFAULT_APPS_DIR="$custom_dir"
    fi

    # 创建目录
    mkdir -p "$DEFAULT_APPS_DIR"

    # 安装核心脚本
    cp "$REPO_DIR/window-manager.sh" "$DEFAULT_BIN_DIR/window-manager.sh"
    chmod +x "$DEFAULT_BIN_DIR/window-manager.sh"
    log_info "window-manager.sh → $DEFAULT_BIN_DIR/"

    # 安装应用脚本
    local count=0
    for script in "$REPO_DIR"/apps/*.sh; do
        local name="$(basename "$script")"
        cp "$script" "$DEFAULT_APPS_DIR/$name"
        chmod +x "$DEFAULT_APPS_DIR/$name"
        ((count++))
    done
    log_info "已安装 $count 个应用脚本 → $DEFAULT_APPS_DIR/"

    # 检查 PATH
    if ! echo "$PATH" | grep -q "$DEFAULT_BIN_DIR"; then
        log_warn "$DEFAULT_BIN_DIR 不在 PATH 中"
        echo ""
        echo "  请将以下行添加到 ~/.bashrc 或 ~/.profile:"
        echo "    export PATH=\"$DEFAULT_BIN_DIR:\$PATH\""
        echo ""
    else
        log_info "$DEFAULT_BIN_DIR 已在 PATH 中"
    fi
}

# ============================================
# 设置快捷键
# ============================================
setup_shortcuts() {
    log_step "GNOME 快捷键..."

    read -rp "  是否设置 GNOME 快捷键? [Y/n] " answer
    if [ "$answer" = "n" ] || [ "$answer" = "N" ]; then
        log_info "跳过快捷键设置"
        echo "  稍后可手动运行: $DEFAULT_APPS_DIR/../setup-shortcuts.sh"
        return
    fi

    # 复制 setup-shortcuts.sh
    cp "$REPO_DIR/setup-shortcuts.sh" "$DEFAULT_BIN_DIR/setup-shortcuts.sh"
    chmod +x "$DEFAULT_BIN_DIR/setup-shortcuts.sh"

    # 运行
    "$DEFAULT_BIN_DIR/setup-shortcuts.sh" apply "$DEFAULT_APPS_DIR"
}

# ============================================
# 完成
# ============================================
finish() {
    echo ""
    echo "  ╔════════════════════════════════════════════════╗"
    echo "  ║                                                ║"
    echo "  ║      🎉 安装完成！                             ║"
    echo "  ║                                                ║"
    echo "  ║  已安装内容:                                    ║"
    echo "  ║    • window-manager.sh  (窗口管理核心)         ║"
    echo "  ║    • apps/*.sh          (应用启动器)           ║"
    echo "  ║    • setup-shortcuts.sh (快捷键配置)           ║"
    echo "  ║                                                ║"
    echo "  ║  下一步:                                        ║"
    echo "  ║    1. 注销后重新登录，快捷键即可生效           ║"
    echo "  ║    2. 按 Ctrl+Alt+A 试试打开终端               ║"
    echo "  ║    3. 按 Esc 试试最小化当前窗口                ║"
    echo "  ║                                                ║"
    echo "  ║  管理命令:                                      ║"
    echo "  ║    setup-shortcuts.sh show  查看快捷键         ║"
    echo "  ║    setup-shortcuts.sh apply 重新配置快捷键     ║"
    echo "  ║                                                ║"
    echo "  ╚════════════════════════════════════════════════╝"
    echo ""
}

# ============================================
# 运行
# ============================================
main() {
    case "${1:-install}" in
        install)
            check_system
            install_scripts
            setup_shortcuts
            finish
            ;;
        shortcuts-only)
            setup_shortcuts
            ;;
        *)
            echo "用法: $0 [install|shortcuts-only]"
            exit 1
            ;;
    esac
}

main "$@"
