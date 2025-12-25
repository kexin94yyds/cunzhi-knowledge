# MCP 工具详情

## 快捷调用

| 触发条件 | 动作 |
|----------|------|
| 对话开始 | 先调用 `ji`（action=回忆）获取项目信息 |
| 用户说"ji" | 先调用 `zhi` 让用户选择：a=沉淀(knowledge) / b=记忆(memory) |
| 用户输入"请记住：" | 总结后调用 `ji`（action=记忆） |
| 用户说"等一下" | 调用 `zhi` |
| 用户说"sou" | 代码搜索：优先 `sou` MCP，无 API 时用 `code_search` |
| 用户说"xi" | 调用 `xi` 在 knowledge 中查找历史经验 |
| prompts 目录名 | 调用 `ci` MCP 工具搜索模板 |
| 解决问题后 | 调用 `ji`（action=沉淀） |
| 用户说"批量任务" | 调用 `pai` 生成子代理提示词 |
| 用户说"验收" | 执行 `git diff`，调用 `zhi` 展示结果 |
| 对话结束 | 调用 `ji(action=摘要)` 记录会话 |

## 工具层级

### L0: zhi (寸止) - 顶层协调者
- 定位：所有对话必经，控制任务流程
- 权限：显示消息、接收输入、显示图片、确认/授权/反问/终止
- ⚠️ **必须传递 `project_path` 参数**
- 反模式：❌ 自己假设同意 ❌ 跳过确认 ❌ 不传 project_path

### L1: ji (记忆)
- action 类型：回忆/记忆/沉淀/摘要
- 约束：必须绑定 git 根目录
- 沉淀流程：
  - 未解决问题 → 只写 problems
  - 已解决问题 → 自动完成三件套：problems → patterns → regressions
- 反模式：❌ 非 git 目录使用 ❌ 不经确认写 knowledge

### L1: sou (搜索)
- **自动判断搜索类型**：
  - 代码相关（函数名、变量、文件路径）→ `sou` 或 `code_search`
  - 外部知识（API 文档、框架用法）→ `web_search`
- 降级：无 API 时用 `code_search` / `grep`

### L1: xi (习)
- 功能：在 knowledge 中查找历史经验
- 搜索范围：patterns.md、problems.md、regressions.md

### L1: pai (派发)
- 功能：生成子代理提示词
- 遵循：`prompts/workflows/batch-task.md`
- 反模式：❌ 用模糊范围 ❌ 跳过验收

### L1: ci (提示词库)
- 功能：搜索 `prompts/<目录>/` 找模板
- 触发：用户输入目录名（如 ci、git、testing）

## IDE 工具映射

| 功能 | Cursor | Windsurf |
|------|--------|----------|
| 读取文件 | `read_file` | `Read` |
| 精确搜索 | `grep` | `Grep` |
| 文件查找 | `glob_file_search` | `Glob` |
| 语义搜索 | `codebase_search` | - |
| 编辑文件 | `search_replace` | `Edit` / `MultiEdit` |
| 写入文件 | `write` | `Write` |
| Shell | `run_terminal_cmd` | `Bash` |
| 网络搜索 | `web_search` | `WebSearch` |
| 任务清单 | `todo_write` | `TodoWrite` |
| 列出目录 | `list_dir` | - |

