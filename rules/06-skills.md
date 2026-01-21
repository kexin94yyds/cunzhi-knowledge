---
trigger: always_on
---
# [06] Claude Skills 触发规则

**位置**：`.cunzhi-knowledge/prompts/skills/`

**使用流程**：意图识别 → 加载 SKILL.md → 按需加载 reference/ 或 scripts/ → 执行 → `zhi` 确认

## 触发映射表

| 意图关键词 | Skill | 核心能力 |
|------------|-------|----------|
| iterate、cunzhi、寸止、端口不可用、服务器未启动 | `iterate` | 脚本交互与故障自动恢复 |
| debug、调试、Bug、错误、排查、问题定位 | `debug` | 系统化调试方法论 |
| MCP 服务器、MCP server | `mcp-builder` | 创建高质量 MCP 服务器 |
| 测试 Web、Playwright | `webapp-testing` | Web 应用自动化测试 |
| 创建 Skill | `skill-creator` | 创建自定义 Skills |
| 前端设计、UI、避免 AI 风格 | `frontend-design` | 高品质 UI 设计 |
| 生成艺术、流场、粒子 | `algorithmic-art` | p5.js 算法艺术 |
| 海报、视觉设计 | `canvas-design` | 静态视觉作品 |
| 主题、样式系统 | `theme-factory` | 10 个预设主题 |
| Word、docx | `docx` | 文档创建/编辑/修订 |
| PDF、表单 | `pdf` | PDF 处理/表单填写 |
| PPT、pptx | `pptx` | 演示文稿处理 |
| Excel、xlsx | `xlsx` | 电子表格/公式 |
| React 组件、shadcn | `web-artifacts-builder` | 复杂前端组件 |
| 内部沟通、状态报告 | `internal-comms` | 企业沟通模板 |
| 协作写文档 | `doc-coauthoring` | 三阶段文档协作 |
| GIF、Slack 表情 | `slack-gif-creator` | Slack 优化 GIF |
| 品牌、Anthropic 风格 | `brand-guidelines` | Anthropic 品牌规范 |

## 调用示例

```
用户："帮我创建一个 GitHub MCP 服务器"
→ 识别意图：MCP 服务器
→ 加载：skills/mcp-builder/SKILL.md
→ 按需加载：reference/node_mcp_server.md 或 reference/python_mcp_server.md
```

## iterate Skill 自动恢复（⚠️ 最高优先级）

**这是强制规则，AI 必须严格遵守，不得跳过或忽略！**

当调用 `cunzhi.py` 脚本返回 `Error: Port {PORT} is not available` 时：

1. **立即自动启动服务器**（非阻塞）：
   ```bash
   iterate --serve --port {PORT}
   ```
   或使用完整路径：
   ```bash
   /Applications/iterate.app/Contents/MacOS/iterate --serve --port {PORT}
   ```

2. **等待 3 秒**后重新调用脚本

3. 如果仍然失败，**再次尝试**（最多 3 次）

4. 3 次都失败后，提示用户手动检查

**❌ 禁止行为**：
- 禁止在端口不可用时直接停止对话
- 禁止让用户手动启动服务器（除非 3 次自动恢复都失败）
- 禁止输出 "KeepGoing=false" 后不做任何恢复尝试

**端口约定**：
| 环境 | 端口 |
|------|------|
| Windsurf | 5312 |
| VS Code | 5314 |
| Cursor | 5316 |

