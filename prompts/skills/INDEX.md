# Skills 索引

AI 根据用户请求中的关键词匹配以下 Skills，匹配成功后读取对应 SKILL.md。

## 可用 Skills

| Skill | 触发词 | 描述 |
|-------|--------|------|
| [iterate](iterate/SKILL.md) | iterate、cunzhi、寸止、端口不可用、服务器未启动 | 脚本交互与故障恢复 |
| [debug](debug/SKILL.md) | debug、调试、Bug、错误、排查 | 系统化调试方法论 |
| [multi-agent-dispatch](multi-agent-dispatch/SKILL.md) | pai、派发、dispatch、分配、并发、多子代理 | 同窗口 codex exec 并发 |
| [ralph-loop](ralph-loop/SKILL.md) | ralph、自主循环、autonomous、直到完成、循环执行 | Ralph Wiggum 自主循环模式 |
| [plan](plan/SKILL.md) | 计划、规划、plan | 任务实施计划 |
| [build](build/SKILL.md) | 构建、编译、build | 项目构建流程 |
| [deploy](deploy/SKILL.md) | 部署、发布、deploy | 部署发布流程 |
| [commit-push-pr](commit-push-pr/SKILL.md) | 提交、推送、PR、commit | Git 提交流程 |
| [fix-lint](fix-lint/SKILL.md) | lint、格式化、eslint | 代码格式修复 |
| [implement](implement/SKILL.md) | 实现、开发、implement | 功能实现流程 |
| [review](review/SKILL.md) | review、代码审查、PR审查 | 代码审查流程 |
| [audit-with-codex](audit-with-codex/SKILL.md) | cha、审查、audit、codex、审计 | Codex 自动审查 |
| [run-tests](run-tests/SKILL.md) | 测试、test、运行测试 | 测试执行流程 |
| [settle](settle/SKILL.md) | 沉淀、三件套、settle | 问题沉淀流程 |
| [sync-knowledge](sync-knowledge/SKILL.md) | 同步、sync、知识库 | 知识库同步 |
| [validate](validate/SKILL.md) | 验证、校验、validate | 验证检查流程 |
| [patch](patch/SKILL.md) | patch、补丁 | 补丁应用流程 |
| [prime](prime/SKILL.md) | prime、准备 | 项目准备流程 |
| [hooks](hooks/SKILL.md) | hooks、钩子、PreRun、PostRun | iterate Hooks 机制设计 |
| [docx](docx/SKILL.md) | Word、文档、.docx | 文档创建、编辑、批注 |
| [pdf](pdf/SKILL.md) | PDF、表单、合并、拆分 | PDF 处理工具包 |
| [pptx](pptx/SKILL.md) | PPT、演示文稿、幻灯片 | 演示文稿创建编辑 |
| [xlsx](xlsx/SKILL.md) | Excel、表格、.xlsx、公式 | 电子表格处理 |
| [frontend-design](frontend-design/SKILL.md) | 前端、UI、网页、组件、界面 | 高质量前端界面设计 |
| [web-artifacts-builder](web-artifacts-builder/SKILL.md) | React、Tailwind、shadcn | 复杂 Web 组件构建 |
| [webapp-testing](webapp-testing/SKILL.md) | Playwright、测试、截图 | Web 应用测试 |
| [mcp-builder](mcp-builder/SKILL.md) | MCP、服务器、FastMCP | MCP 服务器开发 |
| [skill-creator](skill-creator/SKILL.md) | 创建 Skill、新技能 | Skill 创建指南 |
| [doc-coauthoring](doc-coauthoring/SKILL.md) | 写文档、提案、技术规范 | 文档协作工作流 |
| [internal-comms](internal-comms/SKILL.md) | 内部沟通、状态报告、3P | 内部通讯模板 |
| [theme-factory](theme-factory/SKILL.md) | 主题、配色、字体 | 主题样式工厂 |
| [slack-gif-creator](slack-gif-creator/SKILL.md) | GIF、Slack、动画 | Slack GIF 创建 |
| [brand-guidelines](brand-guidelines/SKILL.md) | 品牌、风格指南 | 品牌规范 |
| [canvas-design](canvas-design/SKILL.md) | Canvas、绘图、图形 | Canvas 设计 |
| [algorithmic-art](algorithmic-art/SKILL.md) | 算法艺术、生成艺术 | 算法艺术创作 |
| [end-session](end-session/SKILL.md) | 结束当前对话、结束对话、end session | 结束对话并记录 |
| [init-project](init-project/SKILL.md) | 初始化项目、init、初始化上下文 | 智能生成项目上下文 |
| [podcast-article](podcast-article/SKILL.md) | 播客、公众号、文章工作流、语音转文字、Opus、Typeless | 播客和公众号文章工作流 |

## 使用规则

1. **元数据匹配**：根据用户请求匹配触发词
2. **按需加载**：匹配成功后读取 SKILL.md 正文
3. **渐进披露**：需要时再读取 references/ 下的详细文档
