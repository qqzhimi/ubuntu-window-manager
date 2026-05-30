#!/bin/bash

# ============================================
# GNOME 自定义快捷键配置脚本
# 用法: ./setup-shortcuts.sh [安装目录]
# 默认安装目录: $HOME/.local/bin/apps
# ============================================

set -e

# 安装目录（脚本所在位置）
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
# 删除所有旧的快捷键（可重复执行）
# ============================================
clear_shortcuts() {
    log_info "清除旧的快捷键..."
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[]"
}

# ============================================
# 定义快捷键
# 格式: index  名称  命令路径  按键绑定
# 用户可修改此数组来自定义快捷键
# ============================================
declare -A SHORTCUTS

i=0
# ---- Chrome 浏览器 ----
SHORTCUTS["${i}_name"]="打开/切换 Chrome"
SHORTCUTS["${i}_cmd"]="$INSTALL_DIR/chrome.sh"
SHORTCUTS["${i}_key"]="<Primary><Alt>e"
((++i))

# ---- 终端 ----
SHORTCUTS["${i}_name"]="打开/切换终端"
SHORTCUTS["${i}_cmd"]="$INSTALL_DIR/terminal.sh"
SHORTCUTS["${i}_key"]="<Primary><Alt>a"
((++i))

# ---- VS Code ----
SHORTCUTS["${i}_name"]="打开/切换 VS Code"
SHORTCUTS["${i}_cmd"]="$INSTALL_DIR/vscode.sh"
SHORTCUTS["${i}_key"]="<Primary><Alt>c"
((++i))

# ---- 微信 ----
SHORTCUTS["${i}_name"]="打开/切换微信"
SHORTCUTS["${i}_cmd"]="$INSTALL_DIR/wechat.sh"
SHORTCUTS["${i}_key"]="<Primary><Alt>w"
((++i))

# ---- Obsidian ----
SHORTCUTS["${i}_name"]="打开/切换 Obsidian"
SHORTCUTS["${i}_cmd"]="$INSTALL_DIR/obsidian.sh"
SHORTCUTS["${i}_key"]="<Primary><Alt>s"
((++i))

# ---- Flameshot ----
SHORTCUTS["${i}_name"]="Flameshot 截图"
SHORTCUTS["${i}_cmd"]="/usr/bin/flameshot gui"
SHORTCUTS["${i}_key"]="<Primary><Alt>z"
((++i))

# ---- 全局关闭 (Ctrl+Esc) ----
SHORTCUTS["${i}_name"]="全局关闭当前窗口"
SHORTCUTS["${i}_cmd"]="$INSTALL_DIR/close-window.sh"
SHORTCUTS["${i}_key"]="<Primary>Escape"
((++i))

TOTAL=$i

# ============================================
# 应用快捷键
# ============================================
apply_shortcuts() {
    log_info "应用 $TOTAL 个快捷键..."

    # 构建 custom-keybindings 路径列表
    local paths="["
    for ((j=0; j<TOTAL; j++)); do
        if [ $j -gt 0 ]; then paths+=", "; fi
        paths+="'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${j}/'"
    done
    paths+="]"

    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$paths"

    # 逐个设置
    for ((j=0; j<TOTAL; j++)); do
        local base="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${j}/"
        local name="${SHORTCUTS[${j}_name]}"
        local cmd="${SHORTCUTS[${j}_cmd]}"
        local key="${SHORTCUTS[${j}_key]}"

        # 检查命令文件是否存在
        if [[ "$cmd" == "$INSTALL_DIR/"* ]] && [ ! -f "$cmd" ]; then
            log_warn "跳过 $name: 命令文件不存在 ($cmd)"
            continue
        fi

        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$base" name "$name"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$base" command "$cmd"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$base" binding "$key"

        echo "  ✓ $name → $key"
    done

    echo ""
    log_info "快捷键设置完成！请注销后重新登录以生效。"
    echo ""
    echo "  按键格式说明:"
    echo "    <Primary> = Ctrl"
    echo "    <Alt>     = Alt"
    echo "    <Shift>   = Shift"
    echo "    <Super>   = Win / 徽标键"
    echo ""
    echo "  如需修改快捷键，编辑此脚本后重新运行。"
}

# ============================================
# 显示当前快捷键
# ============================================
show_shortcuts() {
    echo "当前快捷键:"
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
# 入口
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
            echo "用法: $0 [apply|show|help] [安装目录]"
            echo ""
            echo "  apply   设置快捷键（默认）"
            echo "  show    显示当前配置的快捷键"
            echo "  help    显示帮助"
            echo ""
            echo "示例:"
            echo "  $0                          # 使用默认安装目录设置"
            echo "  $0 apply ~/my-scripts/apps  # 自定义安装目录"
            echo "  $0 show                     # 查看快捷键"
            ;;
        *)
            log_error "未知命令: $1"
            echo "用法: $0 [apply|show|help] [安装目录]"
            exit 1
            ;;
    esac
}

main "$@"
