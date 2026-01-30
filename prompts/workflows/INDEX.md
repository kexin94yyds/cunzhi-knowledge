# Workflows 索引

AI 根据用户请求中的关键词匹配以下 Workflows，匹配成功后读取对应文件。

## 可用 Workflows

| Workflow | 触发词 | 描述 |
|----------|--------|------|
| [iterate](iterate/SKILL.md) | iterate、cunzhi、寸止、端口不可用、服务器未启动 | 脚本交互与故障恢复 |
| [debug](debug/SKILL.md) | debug、调试、Bug、错误、排查 | 系统化调试方法论 |
| [batch-task](batch-task.md) | pai、派发、子代理、批量任务 | 子代理任务分配 |
| [plan](plan.md) | 计划、规划、plan | 任务实施计划 |
| [build](build.md) | 构建、编译、build | 项目构建流程 |
| [iterate-loop](iterate-loop.md) | iterate loop、iterative、迭代、感觉 | Iterative build loop |
| [model-routing](model-routing.md) | model routing、模型分流、选模型 | 任务规模与模型匹配 |
| [cross-project](cross-project.md) | cross project、跨项目、复用 | 跨项目复用实现 |
| [deploy](deploy.md) | 部署、发布、deploy | 部署发布流程 |
| [commit-push-pr](commit-push-pr.md) | 提交、推送、PR、commit | Git 提交流程 |
| [fix-lint](fix-lint.md) | lint、格式化、eslint | 代码格式修复 |
| [implement](implement.md) | 实现、开发、implement | 功能实现流程 |
| [review](review.md) | 审查、review、代码审查 | 代码审查流程 |
| [run-tests](run-tests.md) | 测试、test、运行测试 | 测试执行流程 |
| [validate](validate.md) | 验证、校验、validate | 验证检查流程 |
| [settle](settle.md) | 沉淀、三件套、settle | 问题沉淀流程 |
| [sync-knowledge](sync-knowledge.md) | 同步、sync、知识库 | 知识库同步 |

## 使用规则

1. **触发词匹配**：根据用户请求匹配触发词
2. **按需加载**：匹配成功后读取对应 .md 文件
3. **流程执行**：按文件中的步骤执行
