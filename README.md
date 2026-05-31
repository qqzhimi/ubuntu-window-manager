<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://img.shields.io/badge/English-007EC6?style=for-the-badge&logoColor=white">
    <img src="https://img.shields.io/badge/English-007EC6?style=for-the-badge&logoColor=white" alt="English (current)">
  </picture>
  &nbsp;
  <a href="README.zh-CN.md">
    <img src="https://img.shields.io/badge/简体中文-e0e0e0?style=for-the-badge" alt="Switch to 中文">
  </a>
</p>

---

# Ubuntu Window Manager

A one-click-install Ubuntu GNOME window management script and keyboard shortcut system.

Clone to any Ubuntu machine, run `./install.sh`, and you're set.

## ✨ Features

| Feature | Description |
|---------|-------------|
| **Multi-Window Cycling** | Same hotkey cycles through multiple windows; minimizing all on the last |
| **Three-State Toggle** | Single shortcut: launch / activate next / minimize all |
| **Global Close** | `Ctrl+Esc` minimizes the current window (any application) |
| **Single-Instance Protection** | Lock file + process detection prevents duplicate launches |
| **Cross-Language Matching** | Matches both Chinese and English window titles (e.g., "终端" and "Terminal") |
| **GNOME Integration** | System-level shortcuts via gsettings |

## 📦 Installation

```bash
# 1. Clone the repository
git clone https://github.com/qqzhimi/ubuntu-window-manager.git
cd ubuntu-window-manager

# 2. Run the installer
./install.sh
```

The installer automatically: installs dependencies → copies scripts → configures shortcuts. No manual intervention needed.

## ⌨️ Default Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Alt+A` | Open/Switch Terminal (multi-window cycling) |
| `Ctrl+Alt+E` | Open/Switch Chrome (multi-window cycling) |
| `Ctrl+Alt+C` | Open/Switch VS Code (multi-window cycling) |
| `Ctrl+Alt+W` | Open/Switch WeChat (multi-window cycling) |
| `Ctrl+Alt+S` | Open/Switch Obsidian (multi-window cycling) |
| `Ctrl+Alt+Q` | Open/Switch File Manager (multi-window cycling) |
| `Ctrl+Alt+Z` | Flameshot Screenshot |
| `Ctrl+Esc` | Global close current window (any application) |

### Multi-Window Cycling

When multiple windows of the same app are open, repeatedly pressing the shortcut **cycles through them**:

```
Press 1 → Window 1 activated
Press 2 → Window 2 activated
Press 3 → Window 3 activated
Press 4 → All minimized
Press 5 → Window 1 activated (cycle repeats)
```

### Key Notation

- `<Primary>` = `Ctrl`
- `<Alt>` = `Alt`
- `<Shift>` = `Shift`
- `<Super>` = `Win` / Super key

## 🗑️ Uninstall

```bash
./uninstall.sh
```

The uninstaller automatically clears shortcuts, removes scripts, and cleans up lock files (system packages xdotool/wmctrl are preserved).

## 🔧 Customization

### Modifying Shortcuts

Edit `setup-shortcuts.sh`, modify the key bindings in the `SHORTCUTS` array, then run:

```bash
setup-shortcuts.sh apply
```

### Adding a New App

1. Create a new script in the `apps/` directory:

```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/../window-manager.sh" toggle \
    "App Name" \
    "Window Title Keywords|Alternate Title" \
    "launch-command" \
    "process-name"
```

2. Add a shortcut in `setup-shortcuts.sh`

3. Re-run the installer or shortcut configuration

### Custom Window Titles

Window titles may differ across systems/languages. Use the following to inspect them:

```bash
wmctrl -lx | grep -i "keyword"
```

`WINDOW_TITLE` supports `|`-separated keywords, matching against both window title and WM_CLASS (case-insensitive).

## 📋 Dependencies

- `xdotool` — Window manipulation
- `wmctrl` — Window manager control
- GNOME desktop environment (for shortcut functionality)

```bash
sudo apt install xdotool wmctrl
```

## 🏗️ Directory Structure

```
ubuntu-window-manager/
├── README.md              # This file (English)
├── README.zh-CN.md        # Chinese documentation
├── install.sh             # One-click installer
├── uninstall.sh           # One-click uninstaller
├── setup-shortcuts.sh     # Shortcut configuration
├── window-manager.sh      # Core window management engine (v3)
└── apps/
    ├── chrome.sh          # Google Chrome
    ├── terminal.sh        # Terminal
    ├── vscode.sh          # VS Code
    ├── wechat.sh          # WeChat
    ├── obsidian.sh        # Obsidian
    ├── file-manager.sh    # File Manager (Ctrl+Alt+Q)
    ├── flameshot.sh       # Screenshot tool
    ├── close-window.sh    # Global close (Ctrl+Esc)
    └── smart-minimize.sh  # Smart minimize
```

## ⚠️ Notes

- Shortcuts require **logout and re-login** to take effect
- Non-system apps like WeChat and Obsidian must be installed separately
- Only supports X11 sessions; xdotool/wmctrl may be limited under Wayland
- If shortcuts conflict, edit `setup-shortcuts.sh` and re-run

## 📝 License

MIT
