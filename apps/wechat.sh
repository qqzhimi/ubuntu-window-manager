#!/bin/bash
# Open/Switch WeChat (must be installed via snap/apt first)
# Depends on: window-manager.sh (located in parent directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/../window-manager.sh" toggle \
    "WeChat" \
    "WeChat|wechat|微信" \
    "wechat" \
    "wechat"
