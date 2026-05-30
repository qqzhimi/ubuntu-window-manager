#!/bin/bash

# ============================================
# Ubuntu 窗口管理器 - 一键安装脚本
# 用法: git clone 后直接运行 ./install.sh
# ============================================

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
APPS_DIR="$BIN_DIR/apps"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info()  { echo -e "  ${GREEN}✓${NC} $1"; }
log_warn()  { echo -e "  ${YELLOW}!${NC} $1"; }
log_error() { echo -e "  ${RED}✗${NC} $1" >&2; }

echo ""
echo "  Ubuntu 窗口管理器 一键安装"
echo ""

# ---- 安装依赖 ----
missing=()
for dep in xdotool wmctrl; do
    command -v "$dep" &>/dev/null || missing+=("$dep")
done
if [ ${#missing[@]} -gt 0 ]; then
    echo "  安装依赖: ${missing[*]}..."
    sudo apt update -qq && sudo apt install -y "${missing[@]}"
fi
log_info "依赖就绪 (xdotool, wmctrl)"

# ---- 复制脚本 ----
mkdir -p "$APPS_DIR"

cp "$REPO_DIR/window-manager.sh" "$BIN_DIR/window-manager.sh"
chmod +x "$BIN_DIR/window-manager.sh"

cp "$REPO_DIR/setup-shortcuts.sh" "$BIN_DIR/setup-shortcuts.sh"
chmod +x "$BIN_DIR/setup-shortcuts.sh"

shopt -s nullglob
count=0
for script in "$REPO_DIR"/apps/*.sh; do
    cp "$script" "$APPS_DIR/$(basename "$script")"
    chmod +x "$APPS_DIR/$(basename "$script")"
    count=$((count + 1))
done
shopt -u nullglob
log_info "已安装 $count 个应用脚本 → $APPS_DIR/"

# ---- 设置快捷键 ----
if "$BIN_DIR/setup-shortcuts.sh" apply "$APPS_DIR"; then
    log_info "快捷键已配置"
else
    log_warn "快捷键配置失败，稍后手动运行: setup-shortcuts.sh apply $APPS_DIR"
fi

# ---- PATH 检查 ----
if ! echo "$PATH" | grep -q "$BIN_DIR"; then
    echo ""
    echo "  ⚠  $BIN_DIR 不在 PATH 中，请添加:"
    echo "      export PATH=\"$BIN_DIR:\$PATH\""
fi

echo ""
echo "  🎉 安装完成！注销后重新登录快捷键即生效。"
echo ""
