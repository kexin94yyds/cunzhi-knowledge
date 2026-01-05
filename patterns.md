# 可复用模式 (Patterns Registry)

> 记录跨项目可复用的解决方案和最佳实践。

---

## Expertise Sections

### 🎯 提示词工程
| ID | 名称 | 核心要点 |
|----|------|----------|
| PAT-2024-001 | 行为导向原则 | 告诉 AI 做什么，不是描述概念 |
| PAT-2024-003 | XML 标签分组 | 结构清晰，便于 AI 解析 |
| PAT-2024-004 | 人类可读即 AI 可读 | 具体到行为 |
| PAT-2024-006 | 规则简化原则 | 重复逻辑合并 |
| PAT-2024-018 | 输出纪律 | 禁止元评论，直接输出结果 |
| PAT-2024-019 | 7 级成熟度模型 | L1 静态 → L7 元认知 |

### 🔧 MCP 工具开发
| ID | 名称 | 核心要点 |
|----|------|----------|
| PAT-2024-002 | Memory vs Knowledge 分层 | L1 缓存 + L2 持久化 |
| PAT-2024-007 | 外部依赖降级 | 无 API key 时用内置替代 |
| PAT-2024-020 | MCP Agent 规范格式 | 工具+约束+反模式 |
| PAT-2024-021 | ji 统一管理 memory/knowledge | 单一入口，action 区分 |

### 🛡️ 安全与防护
| ID | 名称 | 核心要点 |
|----|------|----------|
| PAT-2024-005 | Smart Guard 依赖检查 | 删文件前查依赖 |
| PAT-2024-017 | AI 防注入安全 | Lethal Trifecta 三要素 |
| PAT-2026-001 | 知识库目录的 .gitignore 保护与自动检测 | 例外保护 + 运行时风险检测 |

### 📱 桌面应用 (Electron/Tauri)
| ID | 名称 | 核心要点 |
|----|------|----------|
| PAT-2025-001 | macOS 应用精准焦点唤回模式 | 使用 PID 识别切换焦点 |
| PAT-2025-002 | 全局快捷键的运行时热切换 | 状态同步链与动态注册 |
| PAT-2025-003 | Tauri 应用动态快捷键同步 | 后端持久化与前端分层处理 |
| PAT-2025-004 | macOS 打包应用权限授权模式 | entitlements + NSAppleEventsUsageDescription + 自动化授权 |
| PAT-2025-005 | Electron 无边框窗口拖拽记忆 | -webkit-app-region: drag + electron-store 持久化 |
| PAT-2025-006 | macOS 全屏插件框架选型 | 全屏覆盖选 Electron，高性能选 Tauri |
| PAT-2026-005 | macOS Swift 全局热键监听 | NSEvent.addGlobalMonitorForEvents + 辅助功能权限 |
| PAT-2024-008 | macOS 拖拽替代 | 自定义鼠标拖拽 |
| PAT-2024-009 | 防抖保存安全 | 关键操作前强制保存 |
| PAT-2024-010 | IPC 事件语义分离 | 同步 ≠ 切换 |
| PAT-2024-011 | IndexedDB 锁定诊断 | lsof + pkill |

### 📱 iOS 移动开发
| ID | 名称 | 核心要点 |
|----|------|----------|
| PAT-2024-022 | iOS 后台持续运行 | 静音音频播放绕过系统限制 |
| PAT-2024-023 | AI/LLM 品牌图标获取 | lobehub/lobe-icons CDN |

### 🚀 部署与运维
| ID | 名称 | 核心要点 |
|----|------|----------|
| PAT-2024-016 | 全功能部署脚本 | 5 步流程 |
| PAT-2024-021 | 应用项目更新脚本规范 | 编译→构建→同步→签名→安装 |

### 📚 其他
| ID | 名称 | 核心要点 |
|----|------|----------|
| PAT-2024-012 | Chrome 扩展 iframe 降级 | Open in Tab |
| PAT-2024-013 | PWA 推送限制 | iOS 16.4+ |
| PAT-2024-014 | macOS 权限说明 | 辅助功能/屏幕录制 |
| PAT-2024-015 | 脚本权限自动设置 | chmod +x |
| PAT-2024-025 | grep 中文字符用法 | 用 `-e` 或 `--` 避免误解析 |
| PAT-2025-004 | 上下文追加项的精细化控制 | 两级控制与 UI 状态联动 |

---

## PAT-2026-001 知识库目录的 .gitignore 保护与自动检测模式

- **场景**：项目根目录存在破坏性的 `.gitignore` 规则（如 `*.md`, `*.json`），导致插件目录或知识库子仓库的文件被意外忽略，IDE 不可见。
- **模式描述**：
  1. **防御性例外**：在项目 `.gitignore` 中显式添加 `!.cunzhi-knowledge/` 规则。
  2. **模板化配置**：在知识库中提供标准的 `gitignore-protection.txt` 模板。
  3. **运行时感知**：工具在执行相关操作（如 `ji 回忆`）时，主动解析 `.gitignore` 文件，检测是否存在忽略风险。
  4. **引导式修复**：发现风险时，不仅提示警告，还提供精确的修复命令（如 `cat template >> .gitignore`）。
- **关联问题**：P-2026-001
- **日期**：2026-01-03

---
## PAT-2025-004 上下文追加项的精细化控制

- 来源：CunZhi 弹窗系统优化
- 日期：2025-12-29

**核心原则**：
- **两级控制**：区分“内容切换（Switch）”与“是否生效（Checkbox）”。
- **UI 状态联动**：当某项被禁用（Unchecked）时，其操作控件（Switch）应同步禁用，并提供视觉反馈（如降低不透明度）。
- **默认安全原则**：新创建或预设的项默认应处于激活状态（`is_active: true`），由用户按需关闭。

**实现模式**：
- **数据层**：在条件性 Prompt 结构中引入 `is_active` 状态位。
- **逻辑层**：生成最终 Prompt 时，先过滤掉 `is_active === false` 的项，再根据 `current_state` 选择对应的模板内容。
- **持久化**：独立的 RPC 命令 `update_conditional_prompt_active` 用于快速同步单个项的激活状态。

---

## PAT-2025-003 Tauri 应用中的动态快捷键状态同步模式

- **场景**：需要在 Tauri 应用中动态启用/禁用全局快捷键（Plugin Global Shortcut）以及本地键盘监听器（document event listener）。
- **模式描述**：
  1. **后端持久化**：在 Rust 后端 `AppState` 中使用 `AtomicBool` 维护启用状态，并同步到配置文件。
  2. **事件驱动同步**：通过 `app.emit` 发送自定义事件（如 `global-shortcut-state-changed`）通知所有窗口前端。
  3. **前端分层处理**：
     - **插件层**：接收事件后调用 `register`/`unregister` 操作系统的全局快捷键。
     - **监听层**：在本地 `keydown`/`keyup` 处理器中增加对响应式状态位（如 `globalShortcutEnabled`）的校验。
  4. **精确拦截**：在本地处理器中，拦截 `Tab` 等常用键时，必须明确排除 `metaKey`/`ctrlKey`/`altKey` 等修饰键，防止干扰系统原生快捷键（如 `Cmd+Tab`）。
- **关联问题**：P-2025-004, P-2025-005
- **日期**：2025-12-30

## PAT-2025-002 全局快捷键的运行时热切换

- 来源：CunZhi 快捷键管理优化
- 日期：2025-12-29

**核心原则**：
- **状态同步链**：配置文件 (Disk) -> AppConfig (Memory) -> AppState Atomic (Runtime) -> 前端事件 (UI)。
- **动态注册**：全局快捷键不应仅在应用启动时注册一次，而应封装为可重复调用的 `register/unregister` 逻辑。
- **视觉一致性**：UI 上的切换按钮应通过监听后端推送的事件（如 `global-shortcut-state-changed`）来同步状态，确保多窗口下的表现一致。

**实现模式**：
- **原子变量保护**：在 `AppState` 中使用 `AtomicBool` 记录状态，确保在 Rust 层级也能进行低开销的状态检查。
- **生命周期管理**：在前端组件 `onUnmounted` 时执行注销，并在 `onMounted` 时根据后端状态决定是否注册。

---

## PAT-2025-004 macOS 打包应用权限授权模式

- 场景：在 macOS 上分发打包后的 Electron 应用，且应用需要通过 AppleScript 控制其他应用（如模拟粘贴、激活窗口）。
- 实现关键点：
  1. **Hardened Runtime & Entitlements**：
     - 在 `package.json` 的 `mac` 构建配置中开启 `hardenedRuntime: true`。
     - 必须包含 `entitlements.mac.plist`，并声明 `com.apple.security.automation.apple-events` 为 `true`。
  2. **Info.plist 描述**：
     - 在 `Info.plist` 中添加 `NSAppleEventsUsageDescription` 描述文字，否则系统不会弹出授权框。
  3. **用户引导**：
     - 若报错 `-1743`，引导用户前往“系统设置 -> 隐私与安全性 -> 自动化”检查权限。
     - 若 Bundle ID 变更，引导用户重置并重新勾选“辅助功能”。
- 关联问题：P-2025-004

## PAT-2025-005 Electron 无边框窗口拖拽记忆模式

- 场景：在 macOS 上开发无边框（frame: false）的 Electron 应用，需要支持窗口拖拽并记住上次呼出的位置。
- 实现关键点：
  1. **HTML/CSS 拖拽区域**：
     - 为 `body` 或顶层元素添加 `-webkit-app-region: drag`。
     - 为交互元素（input, button, list）添加 `no-drag` 排除。
     - 确保拖拽层的 `z-index` 足够高，防止被内容遮挡。
  2. **位置持久化**：
     - 使用 `electron-store` 在 `moved` 和 `close` 事件中保存窗口 `bounds`。
     - 呼出时使用 `screen.getAllDisplays()` 校验保存的位置是否在当前可用屏幕内，防止拔掉外接显示器后窗口“飞走”。
- 关联问题：P-2025-003

## PAT-2025-006 macOS 全屏插件框架选型模式

- 场景：在 macOS 上开发需要覆盖在全屏应用（如全屏浏览器、代码编辑器）之上的工具类插件。
- 决策逻辑：
  1. **全屏覆盖能力**：若必须在全屏模式下可见，**目前唯一可靠方案是 Electron**。通过 `setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true })` 实现。
  2. **Tauri 的限制**：Tauri 底层的 `tao` 库目前（2025Q1）不支持 `visibleOnFullScreen` 选项，虽能接收输入但窗口无法被渲染引擎绘制到全屏 Space 的顶层。
  3. **层级选型**：在 Electron 中应使用 `'screen-saver'` 或 `'maximum'` 等级以确保覆盖系统级 UI。
- 关联问题：P-2025-002

## PAT-2025-001 macOS 应用精准焦点唤回模式

- 场景：在 macOS 开发全局快捷键唤起的工具类应用（如粘贴板、提示词库）时，需要精准将焦点切换回之前的应用。
- 模式：使用 Unix PID 识别而非应用名称。
- 实现关键点：
  1. 呼出窗口前捕获 PID：`tell application "System Events" to get unix id of first application process whose frontmost is true`
  2. 插入/返回前强制激活 PID：`tell application "System Events" to set frontmost of first application process whose unix id is {pid} to true`
  3. 留出激活延迟：在激活指令后设置 100-200ms 的延时，再发送按键事件。
- 关联问题：P-2025-001
- 日期：2025-12-31

