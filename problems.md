# 问题事实库（Problems Registry）

统一记录所有项目中发生过的问题，作为跨项目、长期可追溯的工程经验积累。
本文件是问题事实来源，不等同于 Issue 或 TODO。

---

## 条目格式说明

每个问题条目必须包含以下字段：

- **ID**：P-YYYY-NNN  
  - P 表示 Problem  
  - YYYY 为首次发现年份  
  - NNN 为当年递增序号，不复用、不回收
- **项目**：项目名称
- **仓库**：git 地址
- **发生版本**：commit hash 或 tag
- **现象**：实际观察到的异常行为（用户可见或系统层面）
- **根因**：技术层面的原因分析
- **修复**：采用的解决方案
- **回归检查**：关联的 R-ID
- **状态**：open / fixed / verified
- **日期**：YYYY-MM-DD

### 状态说明

- **open**：问题已发现，尚未完成修复
- **fixed**：代码已修复，但未完成回归验证
- **verified**：回归检查存在，且在当前版本中通过

---

## P-2026-001 .gitignore 通配符导致 .cunzhi-knowledge 文件被忽略

- 项目：iterate (CunZhi)
- 仓库：/Users/apple/cunzhi
- 发生版本：v0.5.0
- 现象：问题解决后，相关的 .md 文件没有在 .cunzhi-knowledge/ 中正确显示或被 IDE 识别。发现项目根目录的 .gitignore 包含 *.md 规则，导致知识库内的文件被忽略。
- 根因：项目级的 .gitignore 通配符规则（如 *.md）会递归影响子目录，包括作为 submodule 或独立仓库存在的 .cunzhi-knowledge/，导致 IDE（如 Windsurf）隐藏这些文件，且 git 操作受限。
- 修复：
  1. 在 .gitignore 中添加 `!.cunzhi-knowledge/` 和 `!.cunzhi-memory/` 例外保护。
  2. 在 .cunzhi-knowledge 中提供标准化保护模板。
  3. 增强 `ji(回忆)` 工具，使其能自动检测此类配置风险并提供一键修复建议。
- 回归检查：R-2026-001
- 状态：verified
- 日期：2026-01-03

---
## P-2026-002 AI Sidebar 导出/保存路径导致重复写入与来源校验缺失

- 项目：AI-Sidebar
- 仓库：/Users/apple/AI-sidebar 更新/AI-Sidebar
- 发生版本：51299728c58bc9bd6b5116eb98fbb7f7269b89d5
- 现象：
  1. 使用 Cmd/Option+S 保存对话时，历史库可能出现重复记录。
  2. 嵌入页面可发送伪造的 `AI_SIDEBAR_*` 消息触发下载或写库。
- 根因：
  1. 内容脚本同时走 `postMessage` 与 `chrome.runtime.sendMessage`，侧边栏即时保存 + 后台队列再次保存，导致重复。
  2. 侧边栏 `message` 监听未校验 `event.source`/`event.origin`。
- 修复：
  1. 保存路径二选一：仅保留 `postMessage` 或仅保留 runtime 队列；必要时在保存前去重。
  2. 严格校验消息来源（限定 `event.source` 为当前 iframe、`origin` 在白名单）。
- 回归检查：待补充
- 状态：open
- 日期：2026-01-05

---
## P-2026-004 跨 IDE 审计闭环缺乏自动执行行为

- 项目：CodexMCP / CunZhi
- 仓库：/Users/apple/codex/codexmcp
- 发生版本：n/a
- 现象：虽然建立了审计 Prompt 模板，但 Codex 审计通过后，用户仍需手动复制 Diff 并贴回 `problems.md` 进行状态翻转，操作不连贯。
- 根因：缺乏“AI 助手感知 Codex 输出并自动执行”的行为闭环逻辑。
- 修复：
  1. 借鉴 `oh-my-opencode` 的行为闭环逻辑，在 `audit-with-codex.md` 中强制要求 Codex 输出 unified diff。
  2. 在 `rules/` 中明确 AI 助手在收到该 Diff 后，必须先通过 `zhi` 请求用户确认；确认后再应用该 Diff 并同步。
  3. **演进（初心守护）**：借鉴 `oh-my-opencode` 的压缩注入机制，在 `00-global.md` 中强制要求长对话压缩时保留原始需求 and 禁令，确保长期任务不偏移。
  4. **汇报机制**：增加“感知汇报”规则，要求 AI 主动声明已加载的模板/规则，增强透明度。
  5. **演进（状态语义）**：引入 `audited (Codex已审计)` 作为“审计通过”的独立状态；`verified` 仅在回归检查实际通过后才允许。
- 回归检查：R-2026-004
- 状态：audited (Codex已审计)
- 日期：2026-01-05

---
## P-2026-003 AI 协作工作流缺乏跨 IDE 审计闭环

- 项目：CodexMCP / CunZhi
- 仓库：/Users/apple/codex/codexmcp
- 发生版本：n/a
- 现象：在使用 AI 助手（如 Windsurf/Claude Code）进行开发时，虽然遵循了“寸止”三件套规则，但缺乏另一高效模型 (Codex) 的交叉审计。手动整理改动信息发送给 Codex 费时费力。
- 根因：IDE 之间的上下文隔离，且缺乏自动化的“改动摘要 + 审计 Prompt”生成机制。
- 修复：
  1. 在 `.cunzhi-knowledge/prompts/workflows/` 下创建 `audit-with-codex.md` 模板。
  2. 规定在任务收尾调用 `zhi` 时，AI 必须基于当前改动和“三件套”自动生成一段可供用户复制到 Codex 的审计 Prompt。
- 回归检查：待补充 (R-2026-003)
- 状态：fixed
- 日期：2026-01-05

---
## P-2025-004 打包应用重命名导致权限失效与 Apple Events (-1743) 错误

- 项目：Full-screen-prompt (Electron)
- 仓库：/Users/apple/提示词最新的/Full-screen-prompt
- 发生版本：2.0.0 (Prompter)
- 现象：
  1. 应用从 "Prompt" 重命名为 "Prompter" 后，在辅助功能已授权的情况下，点击插入依然无效。
  2. 开发者工具 Console 报错：`execution error: 未获得授权将Apple事件发送给System Events。 (-1743)`。
  3. 应用通过 Dock 退出时无法彻底关闭，进程常驻后台。
- 根因：
  1. **Bundle ID 变更**：macOS 的 TCC 权限绑定 Bundle ID。重命名并修改 appId 后，旧权限不再适用于新应用。
  2. **缺少 Entitlements**：打包后的应用运行在沙盒或 Hardened Runtime 下，需要显式声明 `com.apple.security.automation.apple-events` 权限。
  3. **自动化权限 (Automation)**：模拟按键 `tell application "System Events" to keystroke` 属于跨应用控制，需要用户在“隐私与安全性 -> 自动化”中手动授权。
- 修复：
  1. 在 `package.json` 中配置 `hardenedRuntime: true` 并指向包含自动化权限的 `entitlements.mac.plist`。
  2. 在 `Info.plist` (通过 `extendInfo`) 添加 `NSAppleEventsUsageDescription` 描述。
  3. 引导用户重置辅助功能权限并前往“自动化”设置开启 System Events 授权。
  4. 在 `main.js` 中增加 `before-quit` 监听以确保彻底退出。
- 回归检查：R-2025-004
- 状态：verified
- 日期：2025-12-30

---
## P-2025-003 Electron 无边框窗口拖拽失效与位置丢失

- 项目：Full-screen-prompt (Electron)
- 仓库：/Users/apple/提示词最新的/Full-screen-prompt
- 发生版本：2.0.0
- 现象：
  1. 应用采用无边框（frame: false）设计后，窗口没有任何区域可以拖动，用户无法调整窗口位置。
  2. 每次使用快捷键呼出窗口时，窗口总是重置到屏幕中央，无法记住用户上次摆放的位置。
- 根因：
  1. 缺少 `-webkit-app-region: drag` 配置，且原有的手动拖拽逻辑层被遮挡或失效。
  2. main.js 中未实现窗口位置的持久化存储逻辑。
- 修复：
  1. 在 `app.html` 中为 `body` 和顶层 `drag-bar` 添加 `-webkit-app-region: drag`。
  2. 扩大顶部拖拽区域（32px 高度）并置于最高层级（z-index: 10000）。
  3. 为搜索框、按钮等交互元素添加 `no-drag` 排除拖拽。
  4. 在 `main.js` 中使用 `electron-store` 在窗口移动和关闭时保存 `bounds`，并在 `showOnActiveSpace` 时恢复。
- 回归检查：R-2025-003
- 状态：verified
- 日期：2025-12-30

---
## P-2025-002 Tauri 2.0 macOS 兼容性与全屏显示限制

- 项目：Full-screen-prompt (Tauri)
- 仓库：/Users/apple/提示词最新的/Full-screen-prompt
- 发生版本：Tauri 2.0.0-rc + Core-Graphics 0.24
- 现象：
  1. 编译错误：Tauri 2.0 中 `ns_window()` 返回 `Result` 而非 `Option`；`WindowExtMacOS` 导入失效。
  2. 运行时崩溃：设置 `NS_WINDOW_STYLE_NONACTIVATING_PANEL` 或在 FFI 回调中抛出 Objective-C 异常导致 panic。
  3. 全屏不可见：窗口在全屏应用（如 Chrome）上虽可接收输入但肉眼不可见。
- 根因：
  1. API 变更：Tauri 2.0 重构了 macOS 扩展接口。
  2. 库封装限制：`core-graphics` 0.24 删除了 `display` 模块，需手动声明 FFI 绑定。
  3. 框架硬伤：Tauri 底层 `tao` 库目前不支持 `visibleOnFullScreen` 属性（见 tao#189）。
- 修复：
  1. 适配 Tauri 2.0 Result 类型和移除废弃导入。
  2. 手动声明 `CGWindowLevelKey` 绑定。
  3. 决策：由于 Tauri 全屏限制为框架级硬伤，暂时切回 Electron 版本作为生产方案。
- 回归检查：R-2025-002
- 状态：fixed
- 日期：2025-12-30

---
## P-2025-001 Windsurf/Cursor 编辑器插入失败

- 项目：Full-screen-prompt (Electron)
- 仓库：/Users/apple/提示词最新的/Full-screen-prompt
- 发生版本：2.0.0
- 现象：在 Windsurf 或 Cursor 等编辑器中，选择提示词后无法自动粘贴到光标位置，而在备忘录等应用中正常。
- 根因：原方案使用 `activateAppByName` 激活应用，但在 Windsurf 这类基于 VS Code 的编辑器中，进程名称（如 `Windsurf` vs `Windsurf Helper`）或窗口层级较为复杂，导致 AppleScript 无法精准切回编辑器焦点。
- 修复：将激活逻辑从“按名称”改为“按 PID（进程 ID）”。在呼出窗口时记录当前前台 PID，插入时通过 PID 强制激活。同时增加了 150ms 的激活缓冲时间。
- 回归检查：R-2025-001
- 状态：verified
- 日期：2025-12-30

---
## P-2025-001 磁盘空间不足导致最新数据丢失

- 项目：RI (Replace-Information)
- 仓库：/Users/apple/信息置换起/RI
- 发生版本：2.1.1
- 现象：用户退出应用后再次打开，发现最新数据全部丢失。
- 根因：系统磁盘空间完全耗尽（ENOSPC），导致 ElectronStore 在保存 `config.json` 时写入失败，且 IndexedDB 事务无法提交。
- 修复：
  1. 实现自动备份机制：应用启动时及运行期间每 30 分钟备份一次 `config.json` 和 `IndexedDB` 目录。
  2. 限制备份数量：保留最近 10 次备份以平衡安全与空间占用。
  3. 暴露备份 API：允许通过 `window.electronAPI.backup` 进行手动备份、查看列表及恢复。
- 回归检查：R-2025-001
- 状态：verified
- 日期：2025-12-31

---
## P-2025-005 全局快捷键开关失效及系统快捷键冲突

- 项目：iterate (CunZhi)
- 仓库：/Users/apple/cunzhi
- 发生版本：v1.2.0
- 现象：
  1. 点击快捷键开关图标，状态虽变但快捷键在窗口聚焦时仍生效。
  2. `Tab`/`Shift+Tab` 拦截了系统级组合键（如 `Cmd+Tab`），导致无法切换应用。
  3. 修改代码后由于缺失 `@tauri-apps/api/event` 中的 `listen` 导入，导致前端无法接收状态变更。
- 根因：
  1. 仅注销了全局插件快捷键，未禁用前端 `document` 级别的本地监听器。
  2. 键盘事件处理器缺乏对修饰键（Cmd/Alt/Ctrl）的排除逻辑。
  3. `AppContent.vue` 中未导入 `listen` 函数，导致异步状态同步失败。
- 修复：
  1. 在 `AppContent.vue` 的 `handleGlobalKeydown` 中增加 `globalShortcutEnabled` 校验。
  2. 优化 `Tab`/`Shift+Tab` 拦截逻辑，明确排除带修饰键的情况。
  3. 补齐 `listen` 导入，确保 `global-shortcut-state-changed` 事件能被正确处理。
  4. 移除 `PopupHeader.vue` 中冗余的“已禁”文本，优化 UI。
- 回归检查：R-2025-005
- 状态：verified
- 日期：2025-12-30

---
## P-2025-004 全局快捷键无法临时禁用

- 项目：iterate (CunZhi)
- 仓库：/Users/apple/cunzhi
- 发生版本：v1.2.0
- 现象：用户希望在某些场景下临时关闭全局快捷键（如 `Shift+Tab`），避免冲突，但目前只能通过系统设置或修改配置文件实现，操作不便。
- 根因：缺乏快捷键状态的运行时管理机制和 UI 快速切换入口。
- 修复：
  1. 后端：在 `ShortcutConfig` 和 `AppState` 中增加 `global_enabled` 状态。
  2. 逻辑：重构前端快捷键注册逻辑，支持动态监听状态变化并执行 `register/unregister`。
  3. UI：在弹窗头部（`PopupHeader`）增加闪电图标按钮，支持一键切换。
- 回归检查：R-2025-004
- 状态：fixed
- 日期：2025-12-29

---
## P-2025-003 上下文追加项无法按需禁用

- 项目：iterate (CunZhi)
- 仓库：/Users/apple/cunzhi
- 发生版本：v1.2.0
- 现象：弹窗中的“上下文追加”项（如“是否生成总结性Markdown文档”）总是会追加内容到输入框，用户无法在弹窗中临时选择不追加某一项。
- 根因：数据结构 `CustomPrompt` 缺少启用状态标志（`is_active`），且前端 UI 只提供了模板状态切换（Switch），没有提供项级别的开启/关闭控制。
- 修复：
  1. 后端：在 `CustomPrompt` 结构体中添加 `is_active` 字段，并新增 `update_conditional_prompt_active` 命令。
  2. 前端：在弹窗 UI 的上下文追加区域，为每项添加 Checkbox 勾选框；只有 `is_active` 为 true 的项才会参与内容追加。
  3. 设置：在自定义 Prompt 设置页面增加“是否启用”开关。
- 回归检查：R-2025-003
- 状态：fixed
- 日期：2025-12-29

