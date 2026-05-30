#!/bin/bash
# 打开/切换文件管理器 (Nautilus)
# 依赖: window-manager.sh (位于父目录)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/../window-manager.sh" toggle \
    "文件管理器" \
    "Nautilus|nautilus|文件|Files" \
    "nautilus" \
    "nautilus"
