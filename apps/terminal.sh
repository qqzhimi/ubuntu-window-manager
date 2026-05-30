#!/bin/bash
# 打开/切换终端 (gnome-terminal)
# 依赖: window-manager.sh (位于父目录)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/../window-manager.sh" toggle \
    "终端" \
    "终端|Terminal|gnome-terminal" \
    "gnome-terminal" \
    "gnome-terminal-server"
