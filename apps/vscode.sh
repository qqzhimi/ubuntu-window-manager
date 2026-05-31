#!/bin/bash
# Open/Switch VS Code
# Depends on: window-manager.sh (located in parent directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/../window-manager.sh" toggle \
    "VS Code" \
    "Visual Studio Code|Code|code" \
    "code" \
    "code"
