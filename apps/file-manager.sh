#!/bin/bash
# Open/Switch File Manager (Nautilus)
# Depends on: window-manager.sh (located in parent directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/../window-manager.sh" toggle \
    "File Manager" \
    "Nautilus|nautilus|文件|Files" \
    "nautilus" \
    "nautilus"
