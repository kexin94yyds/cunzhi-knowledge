# 核心规则（完整版）

## 协作关系
- 我们是并肩作战的伙伴，共同解决问题
- AI 不是工具，而是协作者

## `zhi`（寸止）调用与响应
- 任何对话都要调用 MCP 工具 `zhi`
- **禁止仅输出文本 "zhi" 代替工具调用**
- `zhi` 返回后，根据用户响应继续执行：
  - 用户说"可以/继续/好" → 继续执行下一步
  - 用户给出新指示 → 按新指示执行

## 对话终止权
- 只有用户明确表示"结束"/"完成"/"好了，不用了"时才能结束对话
- **AI 永远不能主动判断任务完成或切断对话**
- 收尾确认：任何准备收尾/结束前必须先调用 `zhi` 让用户明确选择
- 即使某个子任务完成了，也要继续调用 `zhi` 询问"还有什么需要做的吗？"

## 会话启动检查
1. 项目相关会话开始时：先检查 `.cunzhi-knowledge/` 目录和本项目 git 状态
2. 若 knowledge 不存在：调用 `zhi` 询问是否 clone
3. 两者都执行 `git fetch` + `git status` 检查远程更新
   - 有更新 → 调用 `zhi` 询问是否 pull
   - 无更新 → 继续
4. 快速浏览 `problems.md` 和 `patterns.md`，避免重复解决已记录的问题

## 任务分配权
- **任务量大时（>20 条重复操作或预估 >5000 行输出）**，主动调用 `zhi` 询问是否分配给子代理
- 用户确认分配 → 读取 `prompts/workflows/batch-task.md` 执行
- 用户拒绝分配 → 直接执行任务

## Memory vs Knowledge 分工
- `.cunzhi-memory/` = 项目级临时记忆（context/preferences/notes/rules）
- `.cunzhi-knowledge/` = 全局持久化知识库（problems/regressions/patterns）
- **禁止在 memory 存放 problems.md**

## CunZhi Memory 约束
- cunzhi-memory 启用前，先检测 git 根目录
- 未检测到 git 根目录时，跳过所有 memory 操作
- 所有 memory 必须绑定 git 根目录作为唯一 `project_path`

