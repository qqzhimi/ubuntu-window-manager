# Ubuntu 窗口管理器

一键安装的 Ubuntu GNOME 窗口管理脚本和快捷键系统。

克隆到任意 Ubuntu 机器，运行 `./install.sh` 即可生效。

## ✨ 功能

| 功能 | 说明 |
|------|------|
| **窗口切换** | 按快捷键快速激活/启动指定程序 |
| **智能最小化** | 按 Esc 自动识别当前窗口并最小化 |
| **GNOME 集成** | 通过 gsettings 注册系统级快捷键 |

## 📦 安装

```bash
# 1. 克隆仓库
git clone https://github.com/YOUR_USERNAME/ubuntu-window-manager.git
cd ubuntu-window-manager

# 2. 运行安装
./install.sh
```

安装脚本会自动：
1. 安装依赖（`xdotool`、`wmctrl`）
2. 复制脚本到 `~/.local/bin/`
3. 设置 GNOME 自定义快捷键
4. 安装完成后**注销重新登录**即可生效

## ⌨️ 默认快捷键

| 快捷键 | 功能 |
|--------|------|
| `Esc` | 智能最小化当前窗口 |
| `Ctrl+Alt+A` | 打开/切换终端 |
| `Ctrl+Alt+E` | 打开/切换 Chrome |
| `Ctrl+Alt+C` | 打开/切换 VS Code |
| `Ctrl+Alt+W` | 打开/切换微信 |
| `Ctrl+Alt+S` | 打开/切换 Obsidian |
| `Ctrl+Alt+Z` | Flameshot 截图 |

### 快捷键说明

- `<Primary>` = `Ctrl`
- `<Alt>` = `Alt`
- `<Shift>` = `Shift`
- `<Super>` = `Win` 徽标键

## 🔧 自定义

### 修改快捷键

编辑 `setup-shortcuts.sh`，修改 `SHORTCUTS` 数组中的按键绑定，然后运行：

```bash
setup-shortcuts.sh apply
```

### 添加新应用

1. 在 `apps/` 目录新建脚本：

```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/../window-manager.sh" toggle "程序名" "窗口标题关键词" "启动命令"
```

2. 在 `setup-shortcuts.sh` 中添加快捷键

3. 重新运行安装或快捷键配置

### 自定义窗口标题

不同系统/语言下窗口标题可能不同，用以下命令查看：

```bash
xdotool getactivewindow getwindowname
```

## 🗑️ 卸载

```bash
# 删除脚本
rm -rf ~/.local/bin/window-manager.sh ~/.local/bin/apps/ ~/.local/bin/setup-shortcuts.sh

# 清除快捷键
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[]"
```

## 📋 依赖

- `xdotool` — 窗口操作
- `wmctrl` — 窗口管理器控制
- GNOME 桌面环境（快捷键功能）

```bash
sudo apt install xdotool wmctrl
```

## 🏗️ 目录结构

```
ubuntu-window-manager/
├── README.md              # 本文件
├── install.sh             # 一键安装脚本
├── setup-shortcuts.sh     # 快捷键配置
├── window-manager.sh      # 核心窗口管理引擎
└── apps/
    ├── chrome.sh          # Chrome 浏览器
    ├── terminal.sh        # 终端
    ├── vscode.sh          # VS Code
    ├── wechat.sh          # 微信
    ├── obsidian.sh        # Obsidian 笔记
    ├── flameshot.sh       # 截图工具
    └── smart-minimize.sh  # 智能最小化 (Esc)
```

## ⚠️ 注意事项

- 快捷键需要**注销后重新登录**才能生效
- 微信、Obsidian 等非系统自带程序需先手动安装
- 仅支持 X11 会话，Wayland 下 xdotool/wmctrl 功能可能受限
- 如果快捷键冲突，编辑 `setup-shortcuts.sh` 后重新运行即可

## 📝 License

MIT
