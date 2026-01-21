---
trigger: always_on
---
# [05] Output Style

- **Before ending each response, you MUST call the MCP tool `zhi` (寸止) for confirmation**
- When calling `zhi`:
  - If the task is in progress: Ask "What should we do next?" and provide options
  - If preparing to wrap up: Ask "Continue or end?" and provide "Continue"/"End" options
- **FORBIDDEN**: Do NOT output the literal string "zhi" without calling the tool
- The tool call is mandatory - outputting text alone has no effect

## zhi 调用优化（⚠️ 重要）

**使用 `iterate --bridge` 模式**（Rust 原生，比 Python 更快）。

```bash
# ✅ 推荐：clear 清屏 + 写入 + iterate --bridge
clear && printf '%s\n' '## 标题' '' '内容' > ~/.cunzhi/5312/output.md && /Applications/iterate.app/Contents/MacOS/iterate --bridge --port 5312 --workspace "/Users/apple/cunzhi"
```

**关键点**：
- `clear` 清屏，避免终端累积显示之前的输出
- `--bridge` 模式是 Rust 原生，比 Python 脚本更快
- 写入和调用可以用 `&&` 连接成一行

## output.md 格式规范

写入 `~/.cunzhi/{PORT}/output.md` 时，**必须使用标准 Markdown 格式**以确保正确渲染：

| 元素 | 正确格式 | 错误格式 |
|------|----------|----------|
| 表格 | `\| 列1 \| 列2 \|` + `\|---\|---\|` 分隔行 | ASCII 艺术 `┌─┐│└─┘` |
| 列表 | `- 项目` 或 `1. 项目` | 手动缩进 |
| 标题 | `#` `##` `###` | 手动加粗 |
| 加粗 | `**文字**` | 大写或下划线 |

**禁止**：
- ❌ 使用 ASCII 艺术表格（`┌─┐│└─┘` 等字符）
- ❌ 把需要渲染的 Markdown 放在代码块 ``` 里
- ❌ 使用非标准表格格式（缺少 `|---|---|` 分隔行）

## 用户偏好 (Preferences)
- **❌ 不要生成总结性 Markdown 文档**：除非用户明确要求，否则不主动生成任务总结文档。
- **❌ 不要生成测试脚本**：除非用户明确要求，否则不主动编写测试代码。
- **❌ 不要编译/运行**：用户偏好自己执行编译和运行操作，AI 仅提供命令建议。
- **❌ 禁止连续操作**：严禁连续执行多个改动步骤而不汇报，每一步改动后必须调用 `zhi` 让用户审查功能可用性。
- **❌ 状态确认**：允许使用 "已确认对应的回归检查已创建并通过，允许继续后续变更" 作为继续执行的依据。