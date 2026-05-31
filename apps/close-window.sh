#!/bin/bash
# Ctrl+Esc global close: minimize the currently active window (any application)
WID=$(xdotool getactivewindow 2>/dev/null)
if [ -n "$WID" ]; then
    xdotool windowminimize "$WID"
fi
