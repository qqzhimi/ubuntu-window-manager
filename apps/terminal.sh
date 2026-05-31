#!/bin/bash
# Open/Switch Terminal (WindTerm)
# Depends on: window-manager.sh (located in parent directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/../window-manager.sh" toggle \
    "Terminal" \
    "WindTerm" \
    "windterm" \
    "gnome-terminal-server"
