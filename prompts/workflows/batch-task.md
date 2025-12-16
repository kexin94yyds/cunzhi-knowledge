# /batch-task

**模板分类**: Action
**成熟度**: L5 (Higher Order)

批量任务分配模板，用于人类-主代理-子代理协作模式。

## 输入

- `$1` (task_type): 任务类型（如：补录回归检查、批量重命名、代码审查）
- `$2` (source_file): 源文件路径
- `$3` (target_file): 目标文件路径
- `$4` (batch_count): 分配批次数（默认 10）

## 协作流程

```
人类（最终决策）
    ↓ 分配任务
主代理（我）
    ↓ 生成 N 个子代理提示词
    ↓ 通过 git diff 验收
子代理 1~N（其他聊天窗口）
    ↓ 执行任务
    ↓ 报告完成情况
```

## 子代理提示词模板

```markdown
## 子代理任务 {batch_number}/{batch_count}

**任务类型**: {task_type}
**范围**: {start_id} 到 {end_id}
**源文件**: {source_file}
**目标文件**: {target_file}

### 步骤
1. 读取源文件中对应范围的条目
2. 按格式要求生成目标内容
3. 追加到目标文件末尾
4. 完成后报告：已处理 X 条

### 输出格式
{format_template}

### 验收标准
- 条目数量正确
- 格式符合规范
- 无重复条目
```

## 主代理验收流程

```bash
# 1. 检查新增条目数量
git diff --stat {target_file}

# 2. 验证格式正确性
grep -c "^## R-" {target_file}

# 3. 检查与源文件匹配
diff <(grep "^## P-" problems.md | wc -l) <(grep "^## R-" regressions.md | wc -l)
```

## 示例：补录回归检查

**任务分配**:
```
子代理 1: P-2024-007 到 P-2024-030
子代理 2: P-2024-031 到 P-2024-050
...
子代理 10: P-2024-196 到 P-2024-232
```

**子代理提示词**:
```
请补录回归检查到 .cunzhi-knowledge/regressions.md

范围：P-2024-007 到 P-2024-030

步骤：
1. 读取 .cunzhi-knowledge/problems.md 中对应的问题
2. 为每个 P-ID 生成对应的 R-ID 条目
3. 格式：
## R-YYYY-NNN [问题标题]
- 关联问题：P-YYYY-NNN
- 类型：手工检查
- 关键断言：[根据问题描述提取]
- 运行方式：手工验证

4. 追加到 regressions.md 末尾
5. 完成后报告：已处理 X 条
```

**主代理验收**:
```bash
# 检查新增条目数
git diff .cunzhi-knowledge/regressions.md | grep "^+## R-" | wc -l

# 应等于分配的条目数
```

## 输出格式要求

主代理分配任务后，**仅**返回任务分配摘要。

**不要包含**: 多余解释、元评论前缀

**正确输出**:
```
批次 1: P-2024-007 到 P-2024-030
批次 2: P-2024-031 到 P-2024-050
...
批次 10: P-2024-196 到 P-2024-232

待子代理完成后，我将通过 git diff 验收。
```

**验收完成输出**:
```
- 子代理完成情况：10/10
- 验收结果：通过（新增 212 条 R-ID）
- git diff --stat: 1 file changed, 1800 insertions(+)
```
