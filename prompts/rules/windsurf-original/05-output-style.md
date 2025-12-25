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

## 用户偏好 (Preferences)
- **❌ 不要生成总结性 Markdown 文档**：除非用户明确要求，否则不主动生成任务总结文档。
- **❌ 不要生成测试脚本**：除非用户明确要求，否则不主动编写测试代码。
- **❌ 不要编译/运行**：用户偏好自己执行编译和运行操作，AI 仅提供命令建议。
- **❌ 减少琐碎询问**：在已获得授权的任务流程中，可以连续执行相关步骤，无需每一步都停下来询问，但在关键节点（如删除、重命名、任务切换）仍需调用 `zhi`。
- **❌ 状态确认**：允许使用 "已确认对应的回归检查已创建并通过，允许继续后续变更" 作为继续执行的依据。