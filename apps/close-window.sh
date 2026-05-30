#!/bin/bash
# Ctrl+Esc 全局关闭：最小化当前活跃窗口（不限应用）
WID=$(xdotool getactivewindow 2>/dev/null)
if [ -n "$WID" ]; then
    xdotool windowminimize "$WID"
fi
