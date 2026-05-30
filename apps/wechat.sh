#!/bin/bash
# 打开/切换微信 (需先通过 snap/apt 安装)
# 依赖: window-manager.sh (位于父目录)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/../window-manager.sh" toggle "微信" "Weixin" "wechat"
