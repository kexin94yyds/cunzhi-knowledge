---
name: end-session
description: 结束当前对话，记录到 conversations 并退出
---

# End Session Skill

用户希望结束当前对话。请执行以下步骤：

## 执行流程

1. **总结本次对话**
   - 简要回顾完成的工作
   - 列出关键成果或决策

2. **写入结束标记**
   - 在 output.md 末尾添加 `<!-- END_SESSION -->` 标记
   - 这会触发 PostRun Hook 自动记录到 conversations

3. **调用 cunzhi 脚本**
   - 正常调用 `python3 cunzhi.py {PORT}`
   - 脚本会检测标记并自动执行结束流程

## 示例 output.md 格式

```markdown
## 会话总结

### 完成的工作
- ...

### 关键成果
- ...

<!-- END_SESSION -->
```

## 注意事项

- 不要询问用户是否确认结束，用户已明确表达意图
- 确保 `<!-- END_SESSION -->` 标记在文件末尾
- PostRun Hook 会自动记录到 `conversations/YYYY-MM-DD.md`
