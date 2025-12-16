# /batch-task

**模板分类**: Action
**成熟度**: L5 (Higher Order)

将大任务拆分成 N 个批次，分配给 N 个子代理并行执行，主代理通过 git diff 验收结果。

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
## 子代理 {batch_number}/{batch_count} 任务

**任务类型**: {task_type}
**范围**:
1. {item_1}
2. {item_2}
...
{count}. {item_n}
**源文件**: {source_file}
**目标文件**: {target_file}

### 步骤
1. 读取源文件中以上列表对应的条目
2. 按格式要求生成目标内容，格式：

{output_format_template}

3. 追加到目标文件末尾
4. 完成后报告：已处理 X 条

### 验收标准
- 条目数量正确
- 格式符合规范
- 无重复条目
```

### 模板要点

1. **范围用显式列表**，不用 `A 到 B` 这种模糊表述
2. **步骤包含具体格式模板**，子代理可直接复制修改

### 示例：补录回归检查

```markdown
请补录回归检查到 .cunzhi-knowledge/regressions.md

范围（共 24 个）：
1. P-2024-007
2. P-2024-008
3. P-2024-009
...
24. P-2024-030

步骤：
1. 读取 .cunzhi-knowledge/problems.md 中以上 ID 对应的问题
2. 为每个 P-ID 生成对应的 R-ID 条目，格式：

## R-YYYY-NNN [问题标题]
- 关联问题：P-YYYY-NNN
- 类型：手工检查
- 关键断言：[根据问题描述提取]
- 运行方式：手工验证

3. 追加到 regressions.md 末尾
4. 完成后报告：已处理 X 条
```

### 示例：检索 GitHub 仓库 commit

```markdown
任务：检索 GitHub 仓库的 fix commit

账号：kexin94yyds
范围（共 10 个仓库）：
1. cunzhi-knowledge
2. Mac-switch
3. crawl-Twitter
4. convert-EPUB
5. craw
6. airdrop
7. High-speed-rail-ticket-grabbing
8. My-Website
9. note-get
10. Note-taking-tool

步骤：
1. 使用 `gh api repos/kexin94yyds/{repo}/commits` 获取 commit 历史
2. 筛选 message 包含 "fix" 的 commit
3. 输出格式：

| 仓库 | commit | message | 日期 |
|------|--------|---------|------|
| cunzhi-knowledge | abc1234 | fix: 修复xxx | 2024-12-15 |

4. 完成后报告：已检索 X 个仓库，找到 Y 个 fix commit
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

## 输出格式

主代理分配任务后，**必须通过 `寸止` 工具**展示分配结果，等待用户确认。

**格式规范**：
1. 调用 `寸止` 展示批次分配表和完整提示词
2. **末尾加上**: `你是子代理现在帮我做：`
3. 用户复制后直接在末尾加上批次号（1、2、3...）即可
4. **末尾提示**: `待子代理完成后，我将通过 git diff 验收。`
5. **等待用户确认后**才结束本轮对话

**不要包含:**
- 解释性前言
- 元评论前缀（如 "Based on...", "Let me..."）
- 多段描述

**正确输出**:
```
## 批量任务分配

| 子代理 | 范围（共 N 个） |
|--------|----------------|
| 1 | P-2024-007 ~ P-2024-030 (24个) |
| 2 | P-2024-031 ~ P-2024-050 (20个) |
| ... | ... |

---

请补录回归检查到 .cunzhi-knowledge/regressions.md

范围：
1. P-2024-007
2. P-2024-008
3. P-2024-009
...
24. P-2024-030

步骤：
1. 读取 .cunzhi-knowledge/problems.md 中以上 ID 对应的问题
2. 为每个 P-ID 生成对应的 R-ID 条目，格式：

## R-YYYY-NNN [问题标题]
- 关联问题：P-YYYY-NNN
- 类型：手工检查
- 关键断言：[根据问题描述提取]
- 运行方式：手工验证

3. 追加到 regressions.md 末尾
4. 完成后报告：已处理 X 条

待所有子代理完成后，用户说"验收"，主代理执行 `git diff` 检查，验收通过后统一 commit。

你是子代理现在帮我做：
```

**验收完成输出**:
```
## 验收结果

| 子代理 | 范围 | 状态 | 完成条数 |
|--------|------|------|----------|
| 1 | P-2024-007 ~ P-2024-030 | ✅ | 24 条 |
| 2 | P-2024-031 ~ P-2024-050 | ✅ | 20 条 |
| 3 | P-2024-051 ~ P-2024-070 | ✅ | 20 条 |
| ... | ... | ... | ... |

**汇总**：
- 总完成：10/10 子代理
- 新增条目：212 条 R-ID
- git diff --stat: 1 file changed, 1800 insertions(+)
```

> **注意**：验收表中的 `~` 仅用于汇总展示，子代理提示词中必须使用显式列表。
