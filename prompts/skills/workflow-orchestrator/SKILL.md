---
name: workflow-orchestrator
description: 多 Agent 工作流编排器。触发词：编排、orchestrate、工作流、自动化、多线程。
---

# /workflow-orchestrator

**模板分类**: Action
**成熟度**: L5 (Higher Order)

基于"线程理论"和 **CCC 框架（Clarify/Create/Check）** 的多 Agent 工作流编排系统。

## 理论基础

### 线程四维度 × CCC 框架

| 维度 | CCC 映射 | 实现方式 |
|------|----------|----------|
| **更长的线程** | 减少重复 Clarify | 子代理持续执行，不需每步解释 |
| **更厚的线程** | 增强 AI 的 Clarify | 自动读取项目上下文、规则、文档 |
| **更多的线程** | 扩大 Create 规模 | N 个 Agent 并行执行不同任务 |
| **更少的介入** | 自动化 Check | 只在 Check 失败时人工介入 |

### 子代理 CCC 循环

每个子代理执行完整的 CCC 循环：

```
1. Clarify（理解）
   - 读取任务描述
   - 读取项目 Rules（.windsurfrules）
   - 读取相关 Skills
   - 理解上下文

2. Create（构建）
   - 执行 plan Skill
   - 执行 implement Skill
   - 生成代码/文档

3. Check（审查）
   - 执行 review Skill
   - 运行 validate/run-tests
   - 自我检查是否符合规范
   - 只有 Check 失败才需人工介入
```

## 核心概念

### 工作单元（Atomic Unit）
最基本的工作单元是：**提示词 → Agent 执行 → 审查**

### 工作流模板
预定义的工作流，串联多个 Skills：

| 工作流 | 步骤 | 适用场景 |
|--------|------|----------|
| `dev` | plan → implement → review | 功能开发 |
| `fix` | debug → implement → validate | Bug 修复 |
| `doc` | plan → doc-coauthoring → review | 文档编写 |
| `release` | build → validate → deploy | 发布流程 |
| `settle` | problems → regressions → patterns | 经验沉淀 |

## 使用方法

### 1. 派发单个工作流任务

```
pai dev: 实现用户登录功能
```

主代理会：
1. 生成 `plan` 阶段提示词
2. 写入 `task_queue.json`
3. 子代理领取后自动执行 plan → implement → review

### 2. 派发多个并行任务

```
pai 3:
1. 实现用户登录功能
2. 修复首页白屏 Bug
3. 编写 API 文档
```

主代理会：
1. 为每个任务生成独立提示词
2. 写入 3 个任务到队列
3. 3 个子代理并行领取执行

### 3. 自定义工作流

```
pai custom: plan → implement → run-tests → review
任务：重构支付模块
```

## 子代理任务模板

## 子代理任务 {task_id}

**工作流**: {workflow_name}
**当前阶段**: {current_step}/{total_steps}
**任务描述**: {task_description}

### 执行步骤
1. 执行 `{current_skill}` Skill
2. 完成后报告并调用 `cunzhi_coordinator.py complete`
3. 如有下一阶段，自动领取继续

### ⚠️ 重要：端口使用规则
**子代理必须让脚本自动选择端口，不要硬编码端口号！**

- ✅ 正确：`python3 cunzhi.py`（不指定端口）
- ❌ 错误：`python3 cunzhi.py 5311`（硬编码端口）

### 上下文
- 项目路径: {workspace}
- 相关文件: {files}

*你是子代理，请执行以上任务*：

## 主代理执行流程

```python
# 1. 解析用户输入
workflow, tasks = parse_input(user_input)

# 2. 为每个任务生成提示词
for task in tasks:
    prompt = generate_workflow_prompt(workflow, task)
    
    # 3. 写入任务队列
    os.system(f'python3 cunzhi_coordinator.py create "{prompt}"')

# 4. 通知用户
print(f"已派发 {len(tasks)} 个任务")
print("子代理输入 '1' 即可领取")

# 5. 等待完成通知
# cunzhi_coordinator 会自动发送完成通知

# 6. 验收
os.system('git diff --stat')
```

## 子代理执行流程

```python
# 1. 用户输入 "1" 或 "领取"
# 2. cunzhi_hooks.py 自动检查队列
# 3. 领取任务并注入提示词
# 4. AI 执行任务
# 5. 完成后报告

# 自动完成报告
os.system(f'python3 cunzhi_coordinator.py complete {agent_id} {task_id}')
```

## 验收流程

主代理收到完成通知后：

```bash
# 1. 检查变更
git diff --stat

# 2. 验证格式
grep -c "^## " target_file

# 3. 汇总报告
python3 cunzhi_coordinator.py status
```

## 输出格式

主代理派发任务后，通过 `寸止` 通知用户：

```
## 任务已派发

| 任务 ID | 工作流 | 描述 | 状态 |
|---------|--------|------|------|
| BATCH-004 | dev | 实现用户登录 | 🟡 pending |
| BATCH-005 | fix | 修复白屏 Bug | 🟡 pending |
| BATCH-006 | doc | 编写 API 文档 | 🟡 pending |

**子代理领取方式**：在其他窗口输入 `1` 或 `领取`
```

## 与 batch-task 的区别

| 特性 | batch-task | workflow-orchestrator |
|------|------------|----------------------|
| 任务类型 | 单一重复任务 | 多阶段工作流 |
| 执行方式 | 一次性执行 | 串联多个 Skills |
| 适用场景 | 批量处理 | 复杂开发流程 |

## 示例

### 示例 1：开发新功能

用户输入：
```
pai dev: 实现 iterate 的暗黑模式
```

主代理生成任务：
```markdown
## 子代理任务 BATCH-007

**工作流**: dev (plan → implement → review)
**当前阶段**: 1/3 (plan)
**任务描述**: 实现 iterate 的暗黑模式

### 执行步骤
1. 执行 `plan` Skill，生成实施计划
2. 完成后报告，等待下一阶段

*你是子代理，请执行以上任务*：
```

### 示例 2：并行修复多个 Bug

用户输入：
```
pai fix 3:
1. P-2026-030 白屏问题
2. P-2026-031 端口检测失败
3. P-2026-032 任务队列死锁
```

主代理派发 3 个独立任务，3 个子代理并行执行。
