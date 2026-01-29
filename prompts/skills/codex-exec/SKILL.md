---
name: codex-exec
description: Codex CLI 直接执行 Skill。触发词：codex exec、执行、run codex、工厂模式。让 AI 能直接调用 Codex 执行任意任务。
---

# Codex 执行 Skill

**核心理念**：AI 作为工厂调度器，直接调用 Codex CLI 执行任务，无需用户手动输入命令。

## ⚠️ 核心原则

1. **AI 主导执行**：AI 解析用户意图，构建 Codex 命令并执行
2. **上下文注入**：自动注入项目上下文（context.md、patterns.md）
3. **结果收集**：执行完成后收集结果并汇报

---

## 使用方式

### 触发方式

```
codex exec: 复刻 bridge_test.html 到 iOS 应用
执行: 用 Codex 重构这个模块
run codex: 生成单元测试
工厂: 批量处理这些文件
```

### 用户直接粘贴命令

当用户粘贴类似以下命令时，AI **直接执行**：

```bash
codex exec "任务描述" --sandbox workspace-write -a on-failure -C /path/to/project
```

---

## 执行流程

### 第一步：解析用户意图

```
用户请求 → AI 分析任务类型
         → 确定 sandbox 模式
         → 确定工作目录
```

### 第二步：构建 Codex 命令

**命令模板**：

```bash
codex exec "
## 项目上下文
$(cat {项目路径}/.cunzhi-memory/context.md 2>/dev/null || echo '无')

## 设计决策
$(cat {项目路径}/.cunzhi-knowledge/patterns.md 2>/dev/null | head -100 || echo '无')

## 任务
{用户任务描述}
" --sandbox {sandbox模式} -a {approval模式} -C {工作目录}
```

### 第三步：执行并监控

```bash
# 前台执行，AI 可以看到输出
codex exec "任务" --sandbox workspace-write -C /path/to/project
```

### 第四步：收集结果并汇报

执行完成后，通过 `zhi` 汇报结果。

---

## Sandbox 模式选择

| 模式 | 说明 | 适用场景 |
|------|------|----------|
| `workspace-read` | 只读 | 审查、分析、生成报告 |
| `workspace-write` | 读写 | 代码修改、文件创建 |
| `network-read` | 网络只读 | 需要访问网络的分析 |
| `network-write` | 网络读写 | 需要网络写入的任务 |

**默认**：`workspace-write`（大多数开发任务需要写入）

---

## Approval 模式选择

| 模式 | 说明 | 适用场景 |
|------|------|----------|
| `always` | 每步都需确认 | 敏感操作 |
| `on-failure` | 失败时确认 | 常规任务（推荐） |
| `never` | 全自动 | 信任的重复任务 |

**默认**：`on-failure`

---

## 示例

### 示例 1：用户粘贴命令

**用户输入**：
```
codex exec "参考 bridge_test.html 复刻到 iOS" --sandbox workspace-write -C /Users/apple/cunzhi
```

**AI 执行**：
```bash
# 直接执行用户命令
codex exec "参考 bridge_test.html 复刻到 iOS" --sandbox workspace-write -a on-failure -C /Users/apple/cunzhi
```

### 示例 2：自然语言请求

**用户输入**：
```
用 Codex 帮我重构 bin/ 目录下的 Python 脚本
```

**AI 构建并执行**：
```bash
codex exec "
## 项目上下文
$(cat /Users/apple/cunzhi/.cunzhi-memory/context.md 2>/dev/null)

## 任务
重构 bin/ 目录下的 Python 脚本，提高代码质量：
1. 统一代码风格
2. 添加类型注解
3. 优化错误处理
" --sandbox workspace-write -a on-failure -C /Users/apple/cunzhi
```

### 示例 3：批量任务（工厂模式）

**用户输入**：
```
工厂: 为 src/rust/ 下的每个模块生成文档
```

**AI 拆分并并发执行**：
```bash
# 并发执行多个 Codex 任务
codex exec "为 src/rust/app/ 生成文档" -o /tmp/doc1.md &
codex exec "为 src/rust/bin/ 生成文档" -o /tmp/doc2.md &
wait

# 收集结果
cat /tmp/doc1.md /tmp/doc2.md
```

---

## 与其他 Skill 的关系

| Skill | 关系 |
|-------|------|
| `audit-with-codex` | 审查专用，使用本 Skill 的执行能力 |
| `multi-agent-dispatch` | 并发调度，使用本 Skill 的执行能力 |
| `iterate` | 结果通过 iterate 弹窗汇报 |

---

## 错误处理

### Codex 执行失败

```bash
# 如果 Codex 返回错误，AI 应该：
1. 分析错误原因
2. 调整命令参数
3. 重试（最多 3 次）
4. 如果仍失败，汇报给用户
```

### 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| `sandbox violation` | 权限不足 | 升级 sandbox 模式 |
| `timeout` | 任务过大 | 拆分任务 |
| `context too long` | 上下文过长 | 精简上下文 |

---

## 安全注意事项

1. **不自动执行危险命令**：删除、格式化等操作需用户确认
2. **sandbox 保护**：默认使用 workspace-write，不开放网络
3. **审查输出**：执行完成后 AI 审查输出，确保无异常

---

## 输出格式

**执行完成后汇报**：

```markdown
## Codex 执行完成

**任务**：{任务描述}
**状态**：✅ 成功 / ❌ 失败
**耗时**：{执行时间}

### 执行结果

{Codex 输出摘要}

### 修改的文件

- `path/to/file1.swift` - {修改描述}
- `path/to/file2.swift` - {修改描述}

### 下一步

{建议的后续操作}
```
