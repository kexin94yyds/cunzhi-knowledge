# Bug 修复与知识库流程

## Bug 修复流程（IMPORTANT）

### 修复完成的必要条件
Bug 标记为"已修复"前，**必须同时满足**：
1. 创建回归检查，覆盖原始失败场景
2. 回归检查在当前版本实际通过
3. 问题原因、修复方式沉淀到 `problems.md`
4. 回归检查写入 `regressions.md`
5. 每个步骤完成后调用 `zhi` 汇报进度
6. 通过最终 `zhi` 授权

### 回归检查强制要求
- **P-ID 与 R-ID 一一对应**
- 格式：R-YYYY-NNN
- 类型：unit / e2e / integration / 手工检查
- 禁止只写 problems.md 而跳过 regressions.md

### 状态枚举
- **open** → **fixed** → **verified**
- 只有 `verified` 状态才能标记为已完成
- 禁止跳过 `fixed` 直接到 `verified`

## 问题解决三件套（强制流程）

解决问题后，**必须按顺序**完成：
1. **沉淀问题** → P-YYYY-NNN 写入 problems.md
2. **沉淀经验** → PAT-YYYY-NNN 写入 patterns.md
3. **沉淀回归** → R-YYYY-NNN 写入 regressions.md

**约束：**
- 三者 ID 后缀必须关联（如 P-2024-022 → PAT-2024-024 → R-2024-022）
- 未完成三件套前，禁止视为"问题已解决"

**交互流程（一次确认，自动完成）：**
1. **problems** → 自动沉淀 + 自动 push（不询问）
2. **patterns** → 调用 `zhi` 询问"是否需要补充？"
3. **regressions** → 根据类型处理：
   - **记录型** → 自动沉淀 + 自动 push
   - **验证型** → 沉淀后询问用户是否执行

## 全局知识库规则

### 唯一来源
- 所有问题与经验记录必须写入 `.cunzhi-knowledge/`
- Bug 记录：`problems.md`
- 回归经验：`regressions.md`
- 解决完问题后，必须调用 `zhi` 询问是否记录

### 同步要求
- 文件修改后：调用 `zhi` 询问是否执行 `git add / commit / push`
- remote：https://github.com/kexin94yyds/cunzhi-knowledge.git

### 经验沉淀引导
- 对话结束前 → 调用 `zhi` 简要回顾
- 引导用户思考：解决了什么问题？学到了什么？
- 用户有想法时 → 协助整理并记录

