#!/bin/bash
# Open/Switch Obsidian (must be installed first)
# Depends on: window-manager.sh (located in parent directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/../window-manager.sh" toggle \
    "Obsidian" \
    "Obsidian|obsidian" \
    "obsidian" \
    "obsidian"
