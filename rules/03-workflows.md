# Bug 修复与知识库流程

## Bug 修复流程（IMPORTANT）

### 修复完成的必要条件
Bug 标记为 `verified` 前，**必须同时满足**：
1. 创建回归检查，覆盖原始失败场景
2. 回归检查在当前版本实际通过
3. 问题原因、修复方式沉淀到 `.cunzhi-knowledge/problems.md`
4. 回归检查写入 `.cunzhi-knowledge/regressions.md`
5. 解决模式沉淀到 `.cunzhi-knowledge/patterns.md`
6. 每个步骤完成后调用 `寸止` 汇报进度
7. 通过最终 `寸止` 
8. **三件套完成后询问 Codex 审查**：在完成"三件套"沉淀并标记为 `verified` 后，AI 应主动询问用户是否需要调用 Codex Skill 进行审查。用户选择"是"后才启动审查。
9. **闭环审计自动化**：在 Codex 审计返回 `LGTM` 且包含针对 `.cunzhi-knowledge/problems.md` 的 Diff 时，AI 助手应当先通过 `zhi` 请求用户确认；确认后再自动应用该改动并执行 Git 同步（add/commit/push），将状态推进至 `audited (Codex已审计)`。
10. **审查结果回传**：若执行 Codex 审查，完成后必须调用 `zhi` 以结构化格式回传结论与问题清单。

### 回归检查强制要求
- **P-ID 与 R-ID 一一对应**
- 格式：R-YYYY-NNN
- 类型：unit / e2e / integration / 手工检查
- 禁止只写 problems.md 而跳过 regressions.md

### 状态枚举
- **open** → **fixed** → **verified** → **audited**（可选）
- **open**：问题已记录，待修复
- **fixed**：代码已修复，待验证
- **verified**：回归检查已通过，三件套完成
- **audited**：Codex 审查通过（可选的最终状态）
- 禁止跳过 `fixed` 直接到 `verified`
- **Codex 审查是可选步骤**：三件套完成后询问用户是否需要审查

## 全局知识库规则

### 唯一来源
- 所有问题与经验记录必须写入项目根目录下的 `.cunzhi-knowledge/` 文件夹
- Bug 记录：`.cunzhi-knowledge/problems.md`
- 回归经验：`.cunzhi-knowledge/regressions.md`
- 最佳实践：`.cunzhi-knowledge/patterns.md`
- **禁止在根目录创建临时/副本文件进行中转。**

### 写入方式（CRITICAL）
- 默认写入方式：**必须**通过 `ji(沉淀)` 工具写入，它会自动执行 git add → commit → push
- **patterns 写入前置确认（强制）**：`patterns` 必须先返回预览，并通过 `zhi` 获得用户明确确认后，才允许执行写入（`ji(action=确认沉淀)`）
- **例外（闭环审计）**：当 Codex 返回针对 `.cunzhi-knowledge/problems.md` 的 unified diff 时，AI 助手也必须先通过 `zhi` 请求用户确认；确认后再使用编辑工具应用该 diff，并确保完成 git add → commit → push
- **追加逻辑**：使用 `>>` 或编辑器追加模式，禁止使用 `>` 或 `cp` 直接覆盖整个文件。
- **ji(沉淀) 前置检查**：
  - **分类匹配**：`category` 必须是 `patterns` (PAT-ID), `problems` (P-ID), 或 `regressions` (R-ID)。
  - **单复数兼容**：虽然工具已支持单数，但建议 AI 优先使用复数形式。
  - **ID 校验**：内容必须包含对应格式的 ID（如 PAT-2025-001），否则工具会拦截。
- 原因：直接编辑不会触发自动同步，导致内容只在本地

### 同步与冲突要求
- `ji(沉淀)` 会自动执行 `git add / commit / push`
- **冲突预警**：发现 ID 冲突（如 P-ID 重复）时，必须调用 `zhi` 确认是否需要重编号，严禁直接跳过或覆盖旧记录。
- **文件合并**：若必须进行大规模合并，优先使用 Git 提供的合并工具，严禁人工手动覆盖。
- 如果看到 "⚠️ Git 同步失败"，需要手动处理。
- remote：https://github.com/kexin94yyds/cunzhi-knowledge.git

### 经验沉淀引导
- 对话结束前 → 调用 `寸止` 简要回顾
- 引导用户思考：解决了什么问题？学到了什么？
- 用户有想法时 → 协助整理并记录

## 输出纪律

**禁止元评论模式：**
- ❌ "Based on..." / "根据..."
- ❌ "Looking at..." / "看起来..."
- ❌ "I can see that..." / "我看到..."
- ❌ "Let me..." / "让我..."

**替代方式：** 直接陈述结论，不加前缀说明

## Smart Guard

删除/重命名/移动文件前，执行 `grep_search` 搜索依赖：
- 依赖数 ≤2 → 直接执行
- 依赖数 3-5 → 列出文件，调用 `寸止` 确认
- 依赖数 ≥6 → 调用 `寸止` 说明高风险

命名：文件 kebab-case | 类 PascalCase | 函数 camelCase | 测试 *.test.ts
