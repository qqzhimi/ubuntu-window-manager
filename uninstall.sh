#!/bin/bash

# ============================================
# Ubuntu 窗口管理器 - 一键卸载脚本
# 用法: ./uninstall.sh
#   静默模式: ./uninstall.sh -y  (跳过确认)
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
# 清除 GNOME 快捷键
# ============================================
clear_shortcuts() {
    log_step "清除 GNOME 快捷键..."
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[]"
    log_info "快捷键已清除"
}

# ============================================
# 删除已安装的文件
# ============================================
remove_files() {
    log_step "删除脚本文件..."

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
        echo "  ✓ $DEFAULT_APPS_DIR/ ($app_count 个脚本)"
        removed=$((removed + app_count))
    fi

    # 清理临时锁文件
    rm -f /tmp/wm-*.lock 2>/dev/null || true

    if [ "$removed" -eq 0 ]; then
        log_warn "未找到已安装的文件，可能已经卸载过"
    else
        log_info "已删除 $removed 个文件"
    fi
}

# ============================================
# 完成
# ============================================
finish() {
    echo ""
    echo "  ✅ 卸载完成！"
    echo "  系统依赖 (xdotool、wmctrl) 已保留，可按需手动卸载。"
    echo "  如快捷键仍在生效，请注销后重新登录。"
    echo ""
}

# ============================================
# 入口
# ============================================
main() {
    echo ""
    echo "  Ubuntu 窗口管理器 一键卸载"
    echo ""

    if [ "${1:-}" != "-y" ]; then
        read -rp "  确认卸载? [y/N] " answer
        if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
            echo "  已取消。"
            exit 0
        fi
    fi

    clear_shortcuts
    remove_files
    finish
}

main "$@"
