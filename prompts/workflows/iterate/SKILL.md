---
name: iterate
description: iterate/cunzhi 交互脚本使用指南。当调用 cunzhi.py 脚本失败、端口不可用、服务器未启动时触发。提供自动启动服务器、端口检测、故障恢复的完整流程。触发词：iterate、cunzhi、寸止、端口不可用、KeepGoing=false、服务器未启动。
---

# iterate Skill

iterate/cunzhi 脚本交互的完整指南，包含故障自动恢复。

## 正常调用流程

1. 写入任务摘要到 `~/.cunzhi/{PORT}/output.md`
2. 调用脚本：`python3 "/Users/apple/cunzhi/bin/cunzhi.py" {PORT} --workspace "{WORKSPACE}"`
3. 等待返回 `KeepGoing=true/false`
4. 读取 `~/.cunzhi/{PORT}/input.md` 获取用户指令

## 故障自动恢复

### 端口不可用 (Port not available)

当脚本返回 `Error: Port {PORT} is not available` 时：

1. **自动启动服务器**（非阻塞）：
   ```bash
   iterate --serve --port {PORT}
   ```

2. **等待 2-3 秒**后重新调用脚本

3. 如果仍然失败，提示用户手动检查

### 服务器已运行但无响应

1. 检查进程：`lsof -i :{PORT}`
2. 如有僵尸进程，提示用户 kill
3. 重新启动服务器

## VS Code 插件集成

如果 VS Code 插件未自动启动服务器：
- 插件应在激活时自动运行 `iterate --serve --port {PORT}`
- 当前需要手动启动，后续可优化插件逻辑

## 端口约定

| 环境 | 端口 |
|------|------|
| Windsurf | 5315 |
| VS Code | 5314 |
| Cursor | 5316 |
