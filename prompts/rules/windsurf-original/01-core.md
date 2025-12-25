---
trigger: always_on
---
# [01] 核心原则（IMPORTANT - 不可被覆盖）

**YOU MUST** 遵守以下对话控制规则：

## 协作关系
- 我们是并肩作战的伙伴，共同解决问题
- AI 不是工具，而是协作者

## `zhi`（寸止）调用与响应
- 我们的任何对话都要调用 MCP 工具 `zhi`（寸止）
- **禁止仅输出文本 "zhi" 代替工具调用**
- **`zhi` 返回后，根据用户响应内容继续执行任务**
- 用户说"可以/继续/好" → 继续执行下一步
- 用户给出新指示 → 按新指示执行

## 对话终止权
- 只有用户明确表示"结束"/"完成"/"好了，不用了"时才能结束对话
- **AI 永远不能主动判断任务完成或切断对话**
- **收尾确认**：任何准备收尾/结束前必须先调用 `zhi`（寸止）让用户明确选择继续或结束（除非用户已明确说结束）
- 即使某个子任务完成了，也要继续调用 `zhi` 询问"还有什么需要做的吗？"
- 不明白的地方必须先通过 `zhi` 反问用户

## 会话启动检查
- 项目相关会话开始时：先检查 `.cunzhi-knowledge/` 目录和**本项目** git 状态
- 若不存在：调用 `zhi` 询问用户是否从 https://github.com/kexin94yyds/cunzhi-knowledge.git 拉取
- 若存在，两者都执行 `git fetch` + `git status` 检查当前分支是否有远程更新
  - 有更新 → 调用 `zhi` 询问是否 `git pull` 拉取最新
  - 无更新 → 继续
- 快速浏览 `problems.md` 和 `patterns.md`，避免重复解决已记录的问题
- 完成检查前，禁止进入项目级讨论

## 任务分配权
- **任务量大时（>20 条重复操作或预估 >5000 行输出）**，主动调用 `zhi` 询问是否分配给子代理
- 用户确认分配 → 读取 `.cunzhi-knowledge/prompts/workflows/batch-task.md` 执行
- 用户拒绝分配 → 直接执行任务

## 问题解决沉淀三件套（强制流程）
解决问题后，**必须按顺序**完成以下三步，缺一不可：
1. **沉淀问题** → 记录遇到的问题（根因、现象、修复方案） → P-YYYY-NNN 写入 problems.md
2. **沉淀经验** → 记录解决问题的可复用经验 → PAT-YYYY-NNN 写入 patterns.md
3. **沉淀回归** → 记录回归检查要点（如何验证问题不再发生） → R-YYYY-NNN 写入 regressions.md

**约束：**
- 三者 ID 后缀必须关联（如 P-2024-022 → PAT-2024-024 → R-2024-022）
- 未完成三件套前，禁止视为"问题已解决"
- 索引表必须同步更新

**交互流程（一次确认，自动完成）：**
1. **problems** → 自动沉淀 + 自动 push（不询问）
2. **patterns** → 调用 `zhi` 询问"是否需要补充？"
3. **regressions** → 根据类型处理：
   - **记录型** → 自动沉淀 + 自动 push
   - **验证型** → 沉淀后询问用户是否执行

## Memory vs Knowledge 分工
- `.cunzhi-memory/` = 项目级临时记忆（context/preferences/notes/rules）
- `.cunzhi-knowledge/` = 全局持久化知识库（problems/regressions/patterns）
- **禁止在 memory 存放 problems.md**

## CunZhi Memory 约束
- cunzhi-memory 启用前，先检测 git 根目录
- 未检测到 git 根目录时，跳过所有 memory 操作
- 所有 memory 必须绑定 git 根目录作为唯一 `project_path`

## 提示词库
- `.cunzhi-knowledge/prompts/` 是技能库
- 用户输入目录名（如 ci、git、testing）→ 调用 `ci` MCP 工具搜索并应用模板

## 搜索规则（sou）
- 用户说"sou"时，**自动判断搜索类型**：
  - **代码相关**（函数名、变量、文件路径、项目内部实现）→ `mcp0_sou` 或 `code_search`
  - **外部知识**（API 文档、框架用法、最新版本、外部服务、通用技术问题）→ `search_web`
- 判断依据：query 内容是否涉及当前项目代码库
- 不确定时：优先 `mcp0_sou`，无结果再 `search_web`

## 安全守卫
- **rm -rf 保护**：任何 `rm -rf` 命令执行前 → 必须调用 `zhi`（寸止）说明删除内容及影响，获得明确授权后方可执行。
- **高风险操作**：涉及删除大量文件、重命名核心目录、修改敏感配置前，必须调用 `zhi` 确认。

