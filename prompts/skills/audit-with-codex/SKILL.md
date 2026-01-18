---
name: audit-with-codex
description: Codex 后台审查流程。触发词：audit、codex、审计、审查。支持后台批量审查模式，审查完成后汇总所有问题。
---

# Codex 审计 Skill

**核心理念**：Codex 在后台运行审查，不打扰用户，完成后汇总所有问题。

## ⚠️ 核心原则

1. **开始时问清楚**：确认审查范围和重点
2. **后台自主运行**：审查过程中不打扰用户
3. **完成后汇总反馈**：所有问题一次性呈现

---

## 使用方式

### 触发方式

```
codex: 审查最近的提交
codex: 审查这个 Skill 的流程
audit: 审查 src/ 目录的代码
```

### 审查范围选项

| 范围 | 命令 | 说明 |
|------|------|------|
| 最近提交 | `git diff HEAD~1` | 审查最后一次提交 |
| 未提交更改 | `git diff` | 审查工作区更改 |
| 指定文件 | `codex: 审查 path/to/file` | 审查特定文件 |
| 指定目录 | `codex: 审查 src/` | 审查整个目录 |
| Skill 流程 | `codex: 审查 debug Skill` | 审查 Skill 定义 |

---

## 审查流程

### 第一步：确认审查范围（唯一需要用户确认的步骤）

```
请确认审查范围：
1. 审查范围：[最近提交 / 未提交更改 / 指定文件]
2. 重点关注：[逻辑漏洞 / 规范符合度 / 性能 / 安全]
3. 是否包含三件套审查：[是 / 否]
```

### 第二步：后台自主审查（不打扰用户）

Codex 自主执行以下检查：

1. **逻辑漏洞**：边界 case、并发风险、空值处理
2. **规范符合度**：代码风格、命名规范、项目约定
3. **三件套审查**（如适用）：
   - `problems.md` 记录是否准确
   - `patterns.md` 是否有可复用价值
   - `regressions.md` 是否覆盖失败场景

### 第三步：汇总反馈（审查完成后）

```json
{
  "success": boolean,
  "review_summary": "审查摘要",
  "issues": [
    {
      "id": 1,
      "severity": "blocker | tech_debt | skippable",
      "file": "文件路径",
      "line": "行号",
      "description": "问题描述",
      "suggestion": "修复建议"
    }
  ],
  "lgtm_files": ["无问题的文件列表"]
}
```

---

## 审查标准

| 级别 | 说明 | 处理方式 |
|------|------|----------|
| **Blocker** | 破坏功能、安全问题、验证失败 | 必须修复 |
| **Tech Debt** | 可工作但需改进、缺少测试 | 应该修复 |
| **Skippable** | 次要风格问题、可选优化 | 可忽略 |

---

## 与 iterate 窗口的集成

### 推荐工作流

```
1. iterate 窗口完成代码修改
      ↓
2. 用户输入 "codex: 审查"
      ↓
3. Codex 后台运行审查（用户可以做其他事）
      ↓
4. 审查完成，汇总所有问题
      ↓
5. 用户逐个处理问题
```

### 自动触发（可选）

在 iterate 完成后自动触发 Codex 审查：

```bash
# 在 cunzhi_hooks.py 的 PostRun 中添加
if task_completed:
    trigger_codex_audit()
```

---

## 角色定义

你是一个资深的架构审计专家，拥有极强的代码洞察力和 Bug 探测能力。

### 审计要点

- **直接指出问题**：无需客套
- **行为校验**：检查是否遵循寸止工作流
- **逻辑深度**：不仅看代码行，要看解决思路是否触及根因

### 闭环行为

- 如果改动完美：输出 **LGTM** + 状态更新 diff
- 如果发现隐患：给出具体修复建议

---

## 示例

### 示例 1：审查最近提交

用户输入：
```
codex: 审查最近的提交
```

Codex 输出：
```json
{
  "success": true,
  "review_summary": "3 个文件已审查，发现 1 个 tech_debt 问题",
  "issues": [
    {
      "id": 1,
      "severity": "tech_debt",
      "file": "src/utils.ts",
      "line": "42",
      "description": "缺少错误处理",
      "suggestion": "添加 try-catch 包裹异步操作"
    }
  ],
  "lgtm_files": ["src/main.ts", "src/config.ts"]
}
```

### 示例 2：审查 Skill 流程

用户输入：
```
codex: 审查 debug Skill 的流程是否合理
```

Codex 输出：
```json
{
  "success": true,
  "review_summary": "Debug Skill 流程设计合理，三阶段划分清晰",
  "issues": [],
  "suggestions": [
    "建议在第二阶段添加超时机制",
    "建议明确日志格式规范"
  ]
}
