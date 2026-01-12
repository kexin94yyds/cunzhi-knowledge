# iterate 安装与使用指南

## 组件架构

```
┌─────────────────────────────────────────────────────────────┐
│                      iterate 生态系统                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │  VSCode 插件    │    │  iterate.app    │                │
│  │  (iterate)      │    │  (Tauri 应用)   │                │
│  └────────┬────────┘    └────────┬────────┘                │
│           │                      │                          │
│           │ 启动                 │ 提供                     │
│           ▼                      ▼                          │
│  ┌─────────────────────────────────────────┐               │
│  │        iterate --serve (HTTP 服务)       │               │
│  │        监听端口: 5310+                   │               │
│  └────────────────────┬────────────────────┘               │
│                       │                                     │
│                       │ HTTP 请求                           │
│                       ▼                                     │
│  ┌─────────────────────────────────────────┐               │
│  │        cunzhi.py (Python 脚本)           │               │
│  │        AI 调用此脚本与用户交互            │               │
│  └─────────────────────────────────────────┘               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 安装位置

| 组件 | 路径 | 说明 |
|------|------|------|
| **iterate.app** | `/Applications/iterate.app` | macOS 应用包，包含 GUI |
| **iterate 二进制** | `/opt/homebrew/bin/iterate` | 符号链接到 iterate.app |
| **VSCode 插件** | `~/.vscode/extensions/` | VSCode/Windsurf 插件 |
| **cunzhi.py** | `/Users/apple/cunzhi/bin/cunzhi.py` | AI 调用的 Python 脚本 |
| **全局规则** | `~/.codeium/windsurf/rules/00-global.md` | Windsurf 全局规则 |

## 安装步骤

### 1. 编译 iterate

```bash
cd /Users/apple/cunzhi
cargo tauri build
```

编译产物：
- `/Users/apple/cunzhi/target/release/iterate` - 二进制文件
- `/Users/apple/cunzhi/target/release/bundle/macos/iterate.app` - macOS 应用

### 2. 安装 iterate.app

```bash
# 复制到 Applications
sudo cp -r /Users/apple/cunzhi/target/release/bundle/macos/iterate.app /Applications/

# 创建符号链接（让命令行可用）
rm -f /opt/homebrew/bin/iterate
ln -s /Applications/iterate.app/Contents/MacOS/iterate /opt/homebrew/bin/iterate
```

### 3. 安装 VSCode 插件

```bash
cd /Users/apple/cunzhi/vscode-extension

# 编译
npm run compile

# 打包
npx @vscode/vsce package --allow-missing-repository

# 安装
code --install-extension iterate-0.1.0.vsix --force
```

**注意**：如果有旧版本插件，先卸载：
```bash
code --list-extensions | grep iterate
code --uninstall-extension <旧插件ID>
```

### 4. 重启 IDE

安装完成后，执行 `Cmd+Shift+P` → `Developer: Reload Window`

## 使用方式

### 方式 1：VSCode 插件自动启动（推荐）

1. 打开 VSCode/Windsurf
2. 插件自动启动 `iterate --serve` 服务
3. 点击状态栏 "复制开头语" 按钮
4. 将开头语粘贴到 AI 对话中

### 方式 2：手动启动服务

```bash
# 启动 HTTP 服务
iterate --serve --port 5310

# AI 调用脚本
python3 /Users/apple/cunzhi/bin/cunzhi.py 5310
```

### 方式 3：直接弹窗模式

```bash
iterate --ui --message "任务完成" --options "继续,结束" --workspace "/path/to/project"
```

## 端口管理

- 默认起始端口：`5310`
- 端口注册目录：`~/.cunzhi_ports/`
- 数据目录：`~/.cunzhi/{port}/`
  - `output.md` - AI 写入的消息
  - `input.md` - 用户响应

## 常见问题

### Q: 服务启动失败，提示端口不可用

```bash
# 检查端口占用
lsof -i :5310

# 杀死占用进程
pkill -f "iterate --serve"

# 重新启动
iterate --serve --port 5310
```

### Q: VSCode 插件没有更新

```bash
# 卸载所有旧版本
code --list-extensions | grep iterate | xargs -I {} code --uninstall-extension {}

# 重新安装
code --install-extension /Users/apple/cunzhi/vscode-extension/iterate-0.1.0.vsix --force

# 重启 IDE
```

### Q: 终端显示大量日志

确保使用最新版本的 iterate，日志已重定向到 null。

## 更新流程

1. **更新代码**
   ```bash
   cd /Users/apple/cunzhi
   git pull
   ```

2. **重新编译**
   ```bash
   cargo tauri build
   ```

3. **更新安装**
   ```bash
   sudo rm -rf /Applications/iterate.app
   sudo cp -r target/release/bundle/macos/iterate.app /Applications/
   ```

4. **更新 VSCode 插件**
   ```bash
   cd vscode-extension
   npm run compile
   npx @vscode/vsce package --allow-missing-repository
   code --install-extension iterate-0.1.0.vsix --force
   ```

5. **重启 IDE**
