# Ubuntu 窗口管理器

一键安装的 Ubuntu GNOME 窗口管理脚本和快捷键系统。

克隆到任意 Ubuntu 机器，运行 `./install.sh` 即可生效。

## ✨ 功能

| 功能 | 说明 |
|------|------|
| **多窗口轮循环** | 同键在多窗口间轮流激活，最后一个全部最小化 |
| **三态切换** | 同一快捷键：启动 / 逐个激活 / 全部最小化 |
| **全局关闭** | `Ctrl+Esc` 最小化任意当前窗口（不限应用） |
| **单实例保护** | 锁文件 + 进程检测，防止重复启动 |
| **跨语言匹配** | 同时匹配中英文窗口标题（如 "终端" 和 "Terminal"） |
| **GNOME 集成** | 通过 gsettings 注册系统级快捷键 |

## 📦 安装

```bash
# 1. 克隆仓库
git clone https://github.com/qqzhimi/ubuntu-window-manager.git
cd ubuntu-window-manager

# 2. 运行安装
./install.sh
```

安装脚本自动完成：安装依赖 → 复制脚本 → 配置快捷键，无需手动干预。

## ⌨️ 默认快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+Alt+A` | 打开/切换终端（多窗口轮循环） |
| `Ctrl+Alt+E` | 打开/切换 Chrome（多窗口轮循环） |
| `Ctrl+Alt+C` | 打开/切换 VS Code（多窗口轮循环） |
| `Ctrl+Alt+W` | 打开/切换微信（多窗口轮循环） |
| `Ctrl+Alt+S` | 打开/切换 Obsidian（多窗口轮循环） |
| `Ctrl+Alt+Q` | 打开/切换文件管理器（多窗口轮循环） |
| `Ctrl+Alt+Z` | Flameshot 截图 |
| `Ctrl+Esc` | 全局关闭当前窗口（不限应用） |

### 多窗口轮循环

同一应用打开多个窗口时，重复按快捷键会**轮流激活**：

```
按第 1 次 → 窗口 1 激活
按第 2 次 → 窗口 2 激活
按第 3 次 → 窗口 3 激活
按第 4 次 → 全部最小化
按第 5 次 → 窗口 1 激活（循环）
```

### 按键格式说明

- `<Primary>` = `Ctrl`
- `<Alt>` = `Alt`
- `<Shift>` = `Shift`
- `<Super>` = `Win` 徽标键

## 🗑️ 卸载

```bash
./uninstall.sh
```

卸载脚本会自动清除快捷键、删除脚本、清理锁文件（保留 xdotool/wmctrl 系统包）。

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
exec "$SCRIPT_DIR/../window-manager.sh" toggle \
    "程序名" \
    "窗口标题关键词|English Title" \
    "启动命令" \
    "进程名"
```

2. 在 `setup-shortcuts.sh` 中添加快捷键

3. 重新运行安装或快捷键配置

### 自定义窗口标题

不同系统/语言下窗口标题可能不同，用以下命令查看：

```bash
wmctrl -lx | grep -i "关键词"
```

`WINDOW_TITLE` 支持 `|` 分隔多个关键词，会同时匹配窗口标题和 WM_CLASS（大小写不敏感）。

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
├── uninstall.sh           # 一键卸载脚本
├── setup-shortcuts.sh     # 快捷键配置
├── window-manager.sh      # 核心窗口管理引擎（v3）
└── apps/
    ├── chrome.sh          # Chrome 浏览器
    ├── terminal.sh        # 终端
    ├── vscode.sh          # VS Code
    ├── wechat.sh          # 微信
    ├── obsidian.sh        # Obsidian 笔记
    ├── file-manager.sh    # 文件管理器 (Ctrl+Alt+Q)
    ├── flameshot.sh       # 截图工具
    ├── close-window.sh    # 全局关闭 (Ctrl+Esc)
    └── smart-minimize.sh  # 智能最小化
```

## ⚠️ 注意事项

- 快捷键需要**注销后重新登录**才能生效
- 微信、Obsidian 等非系统自带程序需先手动安装
- 仅支持 X11 会话，Wayland 下 xdotool/wmctrl 功能可能受限
- 如果快捷键冲突，编辑 `setup-shortcuts.sh` 后重新运行即可

## 📝 License

MIT
