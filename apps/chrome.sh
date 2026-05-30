#!/bin/bash
# 打开/切换 Chrome 浏览器
# 依赖: window-manager.sh (位于父目录)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/../window-manager.sh" toggle \
    "Chrome" \
    "Google Chrome|chrome" \
    "google-chrome" \
    "chrome"
