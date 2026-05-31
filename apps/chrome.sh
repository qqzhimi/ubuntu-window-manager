#!/bin/bash
# Open/Switch Google Chrome
# Depends on: window-manager.sh (located in parent directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/../window-manager.sh" toggle \
    "Chrome" \
    "Google Chrome|chrome" \
    "google-chrome" \
    "chrome"
