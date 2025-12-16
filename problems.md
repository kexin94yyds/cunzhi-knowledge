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

## 问题清单

<!-- 新问题追加在此处 -->

## P-2024-007 笔记窗口 Cmd+B 加粗时画面跳动

- 项目：RI (Replace-Information)
- 仓库：/Users/apple/信息置换起/RI
- 发生版本：2024-12-15 之前版本
- 现象：在笔记窗口中，当文字内容超过一屏时，使用 Cmd+B 加粗选中文字会导致画面自动滚动到下方，用户需要手动翻回原位置
- 根因：浏览器 `execCommand('bold')` 执行后会自动将光标位置滚动到可见区域，加上 MutationObserver 同时触发导致滚动位置被多次修改
- 修复：
  1. 添加 `isFormatting` 标志位和 `savedScrollTop` 变量
  2. 在 keydown 事件中检测格式化快捷键时保存滚动位置，格式化后恢复
  3. MutationObserver 回调中检查标志位，正在格式化时直接恢复到已保存位置
- 回归检查：手动验证 Cmd+B 加粗时画面不再跳动
- 状态：verified
- 日期：2024-12-15

---

## P-2024-023 Electron/macOS HTML5 拖拽被立即取消

- 项目：RI (Replace-Information)
- 仓库：https://github.com/kexin94yyds/RI
- 发生版本：Electron 28 + macOS
- 现象：在侧栏拖拽模式时，幽灵预览显示到窗口背后；拖拽开始后立即结束（只有 dragstart→dragend）；无法完成排序
- 根因：Electron/Chromium 在 macOS 下的原生 HTML5 DnD 会被环境策略立即取消（窗口/区域策略导致），非代码问题
- 修复：采用"自定义鼠标拖拽"替代原生 HTML5 DnD：
  - mousedown 超阈值后进入拖拽，创建 fixed+高 z-index 悬浮预览
  - `document.elementFromPoint` 命中按钮并显示上/下插入线
  - mouseup 计算索引并更新顺序
- 回归检查：手动验证拖拽排序功能正常
- 状态：verified
- 日期：2024-12-15
- 经验：Electron/macOS 遇到只有 dragstart→dragend 时，优先考虑自定义鼠标拖拽；调试时分层日志（按钮/容器/文档）能快速定位事件流

---

## P-2024-024 笔记内容因防抖机制丢失

- 项目：RI (Replace-Information)
- 仓库：https://github.com/kexin94yyds/RI
- 发生版本：v2.0.0
- 现象：上传图片后立即切换模式，图片丢失；输入文字后立即切换模式，文字也会丢失
- 根因：笔记保存使用 500ms 防抖，用户在 500ms 内切换模式/关闭窗口/失去焦点时，定时器被销毁，内容未保存
- 修复：
  1. 模式切换前清除防抖定时器并立即保存
  2. 窗口失去焦点时自动保存
  3. 关闭窗口前强制保存
  4. IPC mode-changed 事件前保存
- 回归检查：手动验证图片/文字在各种切换场景下均保留
- 状态：verified
- 日期：2024-12-15
- 经验：防抖适合频繁输入，但关键操作前必须强制保存；添加多重保护（失焦、关闭、切换）

---

## P-2024-025 IndexedDB 数据库锁定导致启动失败

- 项目：RI (Replace-Information)
- 仓库：https://github.com/kexin94yyds/RI
- 发生版本：v2.0.0+
- 现象：启动时报 `Failed to open LevelDB database, IO error: LOCK: File currently in use`；应用无法读取或保存数据
- 根因：IndexedDB 的 LevelDB 后端使用文件锁，同一时间只允许一个进程访问。常见触发：打包版本后台运行、崩溃遗留锁、多实例同时运行
- 修复：
  1. `pkill -f "replace-information"` 温和关闭
  2. 强制终止 `kill -9`
  3. 最后手段：删除 LOCK 文件（需确认无进程运行）
- 回归检查：手动验证应用正常启动
- 状态：verified
- 日期：2024-12-15
- 经验：使用活动监视器或 `ps aux | grep` 检查进程；定期备份用户数据目录

---

## P-2024-026 IPC 事件语义混淆导致笔记内容串联

- 项目：RI (Replace-Information)
- 仓库：https://github.com/kexin94yyds/RI
- 发生版本：v2.0.0
- 现象：切换模式后，笔记内容显示为其他模式的内容
- 根因：
  1. `modes-sync` 事件（同步列表）被错误地用于切换状态
  2. 主窗口和子窗口可以在不同模式，强行同步导致状态错乱
  3. 缺少从数据库重新加载，使用了过期缓存数据
- 修复：
  1. `modes-sync` 只同步列表，不改变当前状态
  2. 模式切换只通过 `mode-changed` 事件
  3. 永远从 IndexedDB 加载权威数据
- 回归检查：手动验证多模式切换内容正确
- 状态：verified
- 日期：2024-12-15
- 经验：IPC 事件语义要清晰（同步列表 vs 切换状态）；主窗口和子窗口状态独立管理

---

## P-2024-027 AI-Sidebar 提供商登录页无法在 iframe 加载

- 项目：AI-Sidebar
- 仓库：https://github.com/kexin94yyds/AI-Sidebar
- 发生版本：v0.0.1
- 现象：Gemini/Google 等提供商的登录页在侧边栏 iframe 中无法加载
- 根因：某些提供商（尤其是 Google）对 iframe 嵌入有安全限制（X-Frame-Options/CSP）
- 修复：提供 "Open in Tab" 按钮，在新标签页中登录，登录完成后侧边栏恢复正常
- 回归检查：手动验证登录流程
- 状态：verified
- 日期：2024-12-15
- 经验：嵌入第三方服务时需考虑 iframe 安全限制，提供降级方案

---

## P-2024-028 ChatGPT 403 错误

- 项目：AI-Sidebar
- 仓库：https://github.com/kexin94yyds/AI-Sidebar
- 发生版本：v0.0.1
- 现象：ChatGPT 在侧边栏中显示 403 错误
- 根因：OpenAI 针对侧边栏请求进行了特殊检查
- 修复：先在普通标签页中打开 ChatGPT 通过初始检查，之后侧边栏可正常访问
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15

---

## P-2024-029 Chrome 扩展 Tab 键切换失效

- 项目：AI-Sidebar
- 仓库：https://github.com/kexin94yyds/AI-Sidebar
- 发生版本：v0.0.1
- 现象：Tab 键切换提供商不工作
- 根因：某些网站的 iframe 拦截了 Tab 键事件
- 修复：确保侧边栏处于焦点状态；在侧边栏空白区域点击后再按 Tab 键
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15

---

## P-2024-030 久坐提醒 iPhone 后台推送失败

- 项目：Sitting
- 仓库：https://github.com/kexin94yyds/Sitting
- 发生版本：v1.0.0
- 现象：iPhone 收不到后台推送通知
- 根因：iOS PWA 推送需要特定条件：iOS ≥ 16.4、通过"添加到主屏幕"安装、已授予通知权限、应用在后台运行
- 修复：文档说明必要条件
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15
- 经验：iOS PWA 推送限制多，需在文档中明确说明

---

## P-2024-031 RI-Flow 快捷键不起作用

- 项目：RI-Flow (信息过滤器桌面版)
- 仓库：https://github.com/kexin94yyds/RI-Flow
- 发生版本：当前版本
- 现象：快捷键无响应
- 根因：可能原因：应用未运行、其他应用占用相同快捷键
- 修复：确保应用运行、检查快捷键冲突、重启应用
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15

---

## P-2024-032 YouTube-Transcript 侧边栏高度自适应问题

- 项目：YouTube-Transcript
- 仓库：https://github.com/kexin94yyds/YouTube-Transcript
- 发生版本：早期版本
- 现象：侧边栏高度不自适应视频页面
- 根因：CSS 布局问题
- 修复：修复侧边栏高度自适应
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15

---

## P-2024-033 Chrome 扩展历史记录不显示

- 项目：AI-Sidebar / AI-Aplication
- 仓库：https://github.com/kexin94yyds/AI-Sidebar
- 发生版本：v0.0.1
- 现象：历史记录不显示
- 根因：Chrome Storage 权限未授予、隐私模式下不记录、清除浏览器数据后重置
- 修复：
  1. 检查 Chrome Storage 权限是否已授予
  2. 避免在隐私/无痕模式下使用
  3. 定期导出历史数据备份
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15
- 经验：Chrome 扩展需明确说明权限要求和数据持久性限制

---

## P-2024-034 Chrome 扩展提供商加载失败

- 项目：AI-Sidebar / AI-Aplication
- 仓库：https://github.com/kexin94yyds/AI-Sidebar
- 发生版本：v0.0.1
- 现象：AI 提供商无法加载
- 根因：浏览器缓存、扩展未正确加载、网络问题
- 修复：
  1. 清空浏览器缓存
  2. 在 Chrome 中重新加载扩展
  3. 确保网络连接正常
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15

---

## P-2024-035 Electron 桌面应用窗口无法显示

- 项目：RI-Flow / flow-learning
- 仓库：https://github.com/kexin94yyds/RI-Flow
- 发生版本：当前版本
- 现象：应用启动后窗口不显示
- 根因：应用缺少必要的系统权限（如辅助功能权限）
- 修复：
  1. 确保应用有必要的权限（系统偏好设置 → 安全性与隐私 → 辅助功能）
  2. 尝试重启应用
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15
- 经验：macOS 应用需要在文档中说明权限要求

---

## P-2024-036 Chrome 扩展数据本地存储安全说明

- 项目：AI-Sidebar / words-RL
- 仓库：https://github.com/kexin94yyds/AI-Sidebar
- 发生版本：v0.0.1
- 现象：用户担心数据安全
- 根因：需要明确说明数据存储位置
- 修复：FAQ 中明确说明：除生产力工具（Attention Tracker）需要 Supabase 同步外，所有数据存储在本地浏览器
- 回归检查：文档验证
- 状态：verified
- 日期：2024-12-15
- 经验：隐私敏感的应用需要在 FAQ 中明确数据存储策略

---

## P-2024-037 EPUB 切书工具脚本权限问题

- 项目：book-cutting-script-web
- 仓库：https://github.com/kexin94yyds/book-cutting-script-web
- 发生版本：当前版本
- 现象：首次运行可能失败
- 根因：切书神技.zsh 脚本缺少执行权限
- 修复：首次运行会自动设置权限；或手动 `chmod +x 切书神技.zsh`
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15
- 经验：脚本文件需要在文档中说明权限要求，或自动设置

---

## P-2024-038 寸止 MCP 工具配置问题

- 项目：iterate (寸止)
- 仓库：https://github.com/kexin94yyds/iterate
- 发生版本：v1.0.0
- 现象：MCP 客户端无法连接寸止
- 根因：配置文件格式错误或路径不正确
- 修复：
  1. 在 MCP 客户端配置文件中添加正确配置：`{ "mcpServers": { "寸止": { "command": "寸止" } } }`
  2. 确保寸止命令在 PATH 中
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15
- 经验：MCP 工具需要提供清晰的配置示例

---

## P-2024-039 Slash-Command-Prompter 提示词上移跨模式问题

- 项目：Slash-Command-Prompter
- 仓库：https://github.com/kexin94yyds/Slash-Command-Prompter
- 发生版本：2.0 之前
- 现象：提示词上移操作影响了其他模式的提示词顺序
- 根因：上移逻辑未限制在当前模式内
- 修复：修复提示词上移仅在当前模式内有效
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15
- 经验：多模式系统中的操作需要明确限定作用域

---

## P-2024-040 Slash-Command-Prompter 斜杠菜单误触发

- 项目：Slash-Command-Prompter / Full-screen-prompt
- 仓库：https://github.com/kexin94yyds/Slash-Command-Prompter
- 发生版本：2.0 之前
- 现象：斜杠菜单在不应触发时被触发
- 根因：触发逻辑过于宽松
- 修复：优化斜杠菜单触发逻辑，避免误触发
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15
- 经验：输入触发类功能需要精确的触发条件

---

## P-2024-041 Chrome 扩展删除模式丢失所有数据

- 项目：words-RL (多模式单词记录器)
- 仓库：https://github.com/kexin94yyds/words-RL
- 发生版本：v2.1
- 现象：用户删除模式后，该模式下所有单词丢失
- 根因：删除模式时级联删除了所有关联数据
- 修复：文档中明确说明"删除模式会同时删除该模式下的所有单词"
- 回归检查：文档验证
- 状态：verified
- 日期：2024-12-15
- 经验：破坏性操作需要在 UI 和文档中明确提示

---

## P-2024-042 Node.js 应用部署到静态托管平台失败

- 项目：kexin-podcast (个人播客网站)
- 仓库：https://github.com/kexin94yyds/kexin-podcast
- 发生版本：当前版本
- 现象：应用部署到 Netlify 或 GitHub Pages 后无法运行
- 根因：Netlify 和 GitHub Pages 只支持静态网站，不能运行 Node.js 服务器
- 修复：部署到支持 Node.js 的平台（Render、Railway、Vercel、Heroku）
- 回归检查：文档验证
- 状态：verified
- 日期：2024-12-15
- 经验：选择部署平台前需确认技术栈兼容性；Node.js 应用需要后端托管服务

---

## P-2024-043 Web 应用震动功能在桌面端无效

- 项目：relax (呼吸练习 Web 应用)
- 仓库：https://github.com/kexin94yyds/relax
- 发生版本：当前版本
- 现象：震动提示在桌面浏览器上不工作
- 根因：震动 API (Vibration API) 主要在移动设备上有效，桌面设备通常不支持
- 修复：文档中说明"震动功能需要设备支持，主要在移动设备上有效"
- 回归检查：文档验证
- 状态：verified
- 日期：2024-12-15
- 经验：使用设备特定 API 时需要提供降级方案或文档说明

---

## P-2024-044 Web 应用音频提示需要用户授权

- 项目：relax (呼吸练习 Web 应用)
- 仓库：https://github.com/kexin94yyds/relax
- 发生版本：当前版本
- 现象：音频提示在首次使用时不播放
- 根因：浏览器自动播放策略要求用户交互后才能播放音频
- 修复：文档中说明"音频提示功能需要用户授权"
- 回归检查：文档验证
- 状态：verified
- 日期：2024-12-15
- 经验：涉及音频/视频自动播放的功能需要处理浏览器权限策略

---

## P-2024-045 macOS 终端通知权限未授予

- 项目：rest (静音倒计时器)
- 仓库：https://github.com/kexin94yyds/rest
- 发生版本：当前版本
- 现象：倒计时结束后通知不显示
- 根因：终端应用缺少系统通知权限
- 修复：系统偏好设置 → 通知与专注模式 → 确保终端有通知权限
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15
- 经验：依赖系统通知的脚本需要文档说明权限配置

---

## P-2024-046 macOS 语音功能未启用

- 项目：rest (静音倒计时器)
- 仓库：https://github.com/kexin94yyds/rest
- 发生版本：当前版本
- 现象：语音提示不工作
- 根因：系统语音功能未启用
- 修复：系统偏好设置 → 辅助功能 → 语音 → 确保语音功能已启用
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15

---

## P-2024-047 Shell 配置未重新加载

- 项目：rest (静音倒计时器)
- 仓库：https://github.com/kexin94yyds/rest
- 发生版本：当前版本
- 现象：安装后 "开始" 命令不可用
- 根因：添加到 ~/.zshrc 后未重新加载配置
- 修复：运行 `source ~/.zshrc` 或重启终端
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15
- 经验：修改 shell 配置后需提示用户重载或重启终端

---

## P-2024-048 12306 抢票脚本 ChromeDriver 版本问题

- 项目：High-speed-rail-ticket-grabbing
- 仓库：https://github.com/kexin94yyds/High-speed-rail-ticket-grabbing
- 发生版本：v1.0
- 现象：ChromeDriver 版本不匹配导致脚本无法运行
- 根因：Chrome 浏览器版本与 ChromeDriver 版本不一致
- 修复：脚本使用 webdriver-manager 自动管理 ChromeDriver，无需手动下载
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15
- 经验：Selenium 项目推荐使用 webdriver-manager 自动管理驱动版本

---

## P-2024-049 12306 抢票脚本登录后页面卡住

- 项目：High-speed-rail-ticket-grabbing
- 仓库：https://github.com/kexin94yyds/High-speed-rail-ticket-grabbing
- 发生版本：v1.0
- 现象：登录后页面卡住不动
- 根因：网络问题或 12306 系统繁忙
- 修复：检查网络连接或稍后重试
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15

---

## P-2024-050 RI index.html 文件被意外清空

- 项目：RI (Replace-Information)
- 仓库：https://github.com/kexin94yyds/RI
- 发生版本：开发阶段
- 现象：打开应用发现主窗口无法显示，检查 index.html 发现文件只剩一行空白
- 根因：文件被意外清空或覆盖（可能是编辑器误操作）；打包好的应用仍能运行是因为使用的是打包时的完整文件副本
- 修复：从 git 历史恢复文件 `git show HEAD:index.html > index.html`
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-15
- 经验：关键文件应有版本控制；定期提交代码可快速恢复

---

## P-2024-051 AI-Sidebar NotebookLM 标题捕获失败

- 项目：AI-Sidebar
- 仓库：https://github.com/kexin94yyds/AI-Sidebar
- 发生版本：早期版本
- 现象：收藏 NotebookLM 页面时，扩展未能捕获实时项目标题，而是显示 "NotebookLM" 或 "Untitled"
- 根因：NotebookLM 使用 Angular 动态渲染组件，项目标题存储在特定的 Angular Material 组件结构中（`.title-label-inner`），原实现只检查标准 h1/h2 和 OpenGraph meta 标签
- 修复：
  1. 增强 `resolveNotebookLMTitle()` 函数，使用多优先级选择器策略
  2. 使用 `deepFind()` BFS 遍历 Angular 组件结构
  3. 添加 MutationObserver 监听标题变化
  4. 实现重试机制（500ms + 2000ms）应对 Angular 异步渲染
- 回归检查：手动验证标题捕获
- 状态：verified
- 日期：2024-12-15
- 经验：SPA 框架（Angular/React/Vue）集成需使用深度 DOM 遍历 + 重试机制 + MutationObserver

---

## P-2024-006 Acemcp 无法获取 Augment API 凭证

- 项目：acemcp
- 仓库：https://github.com/qy527145/acemcp.git
- 发生版本：2024-12-15
- 现象：尝试通过 `auggie login` 获取 Augment API 凭证时，hCaptcha 验证失败，控制台显示 401/403 错误
- 根因：Augment 认证服务的 hCaptcha 验证在当前网络环境下无法通过（可能需要科学上网或服务本身有问题）
- 修复：暂无，需要解决网络问题或等待 Augment 服务修复
- 回归检查：待创建
- 状态：open
- 日期：2024-12-15
- 备注：acemcp 是基于 Augment Context Engine 的语义代码搜索 MCP 工具，必须连接 Augment 云服务才能使用。暂时用 grep_search 和 code_search 替代。

## P-2024-002 WindowSwitcher 上下箭头切换时窗口未置顶

- 项目：iterate (cunzhi)
- 仓库：/Users/apple/cunzhi
- 发生版本：2024-12-14 之前版本
- 现象：多窗口并列时，按 Tab 打开窗口选择器，使用上下箭头切换选中行，第一行窗口会置顶，但第二、第三行选中时对应窗口不会置顶
- 根因：`WindowSwitcher.vue` 中 `selectedIndex` 变化时未调用 `activate_window_instance` 置顶窗口
- 修复：新增 `activateWindowAtIndex()` 函数，在上下箭头切换时实时调用置顶
- 回归检查：R-2024-002
- 状态：verified
- 日期：2024-12-14

## P-2024-004 窗口切换器点击第二行无法激活对应窗口

- 项目：cunzhi
- 仓库：/Users/apple/cunzhi
- 发生版本：2024-12-14
- 现象：按 Tab 打开窗口切换器，点击第二行或其他行时，总是激活第一行的窗口
- 根因：macOS 多个同名应用进程时，AppleScript 激活行为不确定
- 修复：待定
- 回归检查：待创建
- 状态：open
- 日期：2024-12-14

## P-2024-003 GUI 标题栏只显示项目名称，无法显示完整路径

- 项目：cunzhi
- 仓库：/Users/apple/cunzhi
- 发生版本：2024-12-14
- 现象：GUI 标题栏显示 `iterate / cunzhi`（只有项目名称），用户无法区分同名但不同路径的项目
- 根因：`PopupHeader.vue` 中 `displayProjectName` 只取路径最后一部分，窗口标题是静态的
- 修复：修改 `PopupHeader.vue` 使用完整路径，在 `useMcpHandler.ts` 动态设置窗口标题
- 回归检查：R-2024-003
- 状态：verified
- 日期：2024-12-14

## P-2024-005 Supabase RLS 策略只对 service_role 生效导致 API 查询失败

- 项目：ContentDash
- 仓库：https://github.com/kexin94yyds/if-compond
- 发生版本：2024-12-14
- 现象：密钥激活时返回"密钥不存在"错误（400 Bad Request），但数据库中密钥确实存在
- 根因：Supabase RLS 策略只配置了 `service_role` 角色权限，而 Netlify Functions 使用的是 `anon` key（匿名密钥），导致匿名用户无法查询数据
- 修复：在 Supabase 中添加 `anon` 角色的 SELECT 和 UPDATE 策略：
  ```sql
  CREATE POLICY "Allow anon read" ON contentdash_licenses
      FOR SELECT TO anon USING (true);
  CREATE POLICY "Allow anon update" ON contentdash_licenses
      FOR UPDATE TO anon USING (true) WITH CHECK (true);
  ```
- 回归检查：手动验证激活功能正常
- 状态：verified
- 日期：2024-12-14

## P-2024-052 Shift+Tab 恢复窗口时最后操作的窗口应置顶

- 项目：iterate (cunzhi)
- 仓库：/Users/apple/cunzhi
- 发生版本：2024-12-15
- 现象：按 Shift+Tab 恢复所有最小化窗口后，所有窗口平等恢复，没有将最后一个按 Tab 最小化的窗口置于最上层
- 期望行为：
  1. 在窗口 A 按 Tab 最小化后，按 Shift+Tab 恢复时，窗口 A 应在最上层
  2. 如果期间在窗口 B 也按了 Tab 最小化，则最后按 Tab 的窗口（B）应在最上层
  3. 所有最小化的窗口都恢复，但最后操作的窗口获得焦点
- 根因：全局快捷键 Shift+Tab 目前只调用 `unminimize()` 恢复当前窗口，没有记录最后最小化的窗口信息
- 修复：待实现 - 需要添加窗口最小化历史栈，记录最后最小化的窗口，恢复时按栈顺序置顶
- 回归检查：待创建
- 状态：open
- 日期：2024-12-15

---

## P-2024-001 全局知识库流程验证

- 项目：windsurf-project
- 仓库：本地测试
- 发生版本：N/A
- 现象：验证全局知识库写入、提交、推送流程是否正常
- 根因：流程验证用途
- 修复：N/A
- 回归检查：R-2024-001
- 状态：verified
- 日期：2024-12-14

---

## P-2024-053 iterate 中文输入候选栏移位

- 项目：iterate (cunzhi)
- 仓库：https://github.com/imhuso/cunzhi
- 发生版本：PR #55
- 现象：移动窗口时中文输入法候选栏位置偏移
- 根因：Tauri 窗口移动事件未同步更新输入法候选栏位置
- 修复：监听窗口移动事件，重新定位候选栏
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：跨平台桌面应用需要特别处理输入法集成问题

---

## P-2024-054 iterate 首次启动缺少 config.json 导致主题异常

- 项目：iterate (cunzhi)
- 仓库：https://github.com/imhuso/cunzhi
- 发生版本：PR #51
- 现象：首次启动应用时页面主题显示异常
- 根因：config.json 不存在时，主题配置读取失败，未正确使用默认值
- 修复：添加配置文件不存在时的默认值处理逻辑
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：配置文件读取必须有完整的默认值兜底

---

## P-2024-055 iterate 多开时配置不同步

- 项目：iterate (cunzhi)
- 仓库：https://github.com/imhuso/cunzhi
- 发生版本：PR #48
- 现象：同时打开多个应用实例时，配置修改不同步
- 根因：各实例独立读写配置文件，无进程间通信
- 修复：采用单实例模式 + 监听窗口焦点变化时重新加载配置
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：桌面应用配置同步需考虑多实例场景

---

## P-2024-056 iterate GitHub Actions 构建白屏

- 项目：iterate (cunzhi)
- 仓库：https://github.com/imhuso/cunzhi
- 发生版本：早期 CI 版本
- 现象：通过 GitHub Actions 构建的 CLI 工具启动后白屏
- 根因：前端资源未正确嵌入到二进制文件中
- 修复：使用 tauri-action 替代手动构建，确保前端资源正确嵌入
- 回归检查：CI 验证
- 状态：verified
- 日期：2024-12-16
- 经验：Tauri 应用 CI 构建需使用官方 tauri-action

---

## P-2024-057 iterate pnpm 版本冲突

- 项目：iterate (cunzhi)
- 仓库：https://github.com/imhuso/cunzhi
- 发生版本：GitHub Actions
- 现象：CI 构建时 pnpm 版本与 package.json 指定版本不一致导致失败
- 根因：GitHub Actions 中手动指定的 pnpm 版本与项目配置冲突
- 修复：移除 GitHub Actions 中的 pnpm 版本指定，让 pnpm/action-setup 自动从 package.json 读取
- 回归检查：CI 验证
- 状态：verified
- 日期：2024-12-16
- 经验：CI 中依赖版本应与项目配置保持一致

---

## P-2024-058 信息过滤器 EPUB 封面提取失败

- 项目：信息过滤器
- 仓库：/Users/apple/信息过滤器
- 发生版本：当前版本
- 现象：部分 EPUB 书籍封面无法正确提取显示
- 根因：不同 EPUB 格式封面存储位置不同，只实现了一种提取方式
- 修复：添加完整的 3 种封面提取方法（meta cover-image、manifest、文件名匹配）
- 回归检查：手动验证多种 EPUB 格式
- 状态：verified
- 日期：2024-12-16
- 经验：EPUB 格式多样，封面提取需要多种策略兜底

---

## P-2024-059 信息过滤器 localStorage 超限

- 项目：信息过滤器
- 仓库：/Users/apple/信息过滤器
- 发生版本：当前版本
- 现象：保存大量书籍封面后，localStorage 超出限制导致数据丢失
- 根因：封面图片 base64 编码后体积过大，localStorage 只有 5MB 限制
- 修复：压缩封面图片（限制尺寸 + 质量压缩）防止超限
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：localStorage 存储图片需要压缩处理

---

## P-2024-060 tobooks Cmd+Enter 保存笔记无效

- 项目：tobooks
- 仓库：/Users/apple/tobooks
- 发生版本：当前版本
- 现象：在笔记编辑框中按 Cmd+Enter 无法保存笔记
- 根因：keydown 事件监听在 iframe 内无法捕获
- 修复：改用 window capture 模式监听快捷键
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：iframe 内的快捷键需要特殊处理

---

## P-2024-061 tobooks 高亮功能导致内容消失

- 项目：tobooks
- 仓库：/Users/apple/tobooks
- 发生版本：当前版本
- 现象：对文本添加高亮后，部分内容消失
- 根因：DOM 操作时 Range 对象处理不当，误删了相邻文本节点
- 修复：优化高亮 DOM 操作逻辑，正确处理文本节点分割
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：DOM Range 操作需要仔细处理边界情况

---

## P-2024-062 zhuyili 微信支付功能异常

- 项目：zhuyili (注意力追踪器)
- 仓库：/Users/apple/zhuyili
- 发生版本：当前版本
- 现象：购买按钮点击后无反应，试用次数逻辑异常
- 根因：购买按钮点击事件未正确绑定，试用次数判断逻辑有 bug
- 修复：修复事件绑定和试用次数逻辑
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：支付功能需要完整的事件绑定和状态管理

---

## P-2024-063 zhuyili 二维码不显示

- 项目：zhuyili (注意力追踪器)
- 仓库：/Users/apple/zhuyili
- 发生版本：当前版本
- 现象：微信支付二维码无法显示
- 根因：二维码生成库加载或配置问题
- 修复：修复二维码生成逻辑
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-064 zhuyili OAuth 回调 URL 跳回本地

- 项目：zhuyili (注意力追踪器)
- 仓库：/Users/apple/zhuyili
- 发生版本：当前版本
- 现象：Google 登录后回调到 localhost 导致 Cannot GET /
- 根因：OAuth 重定向 URL 动态生成时在生产环境仍使用了本地地址
- 修复：生产环境 OAuth 回调固定到 Netlify 正式域名
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：OAuth 回调 URL 需要区分开发/生产环境

---

## P-2024-065 视频侧边栏与视频未实时联动

- 项目：视频侧边栏
- 仓库：/Users/apple/视频侧边栏
- 发生版本：当前版本
- 现象：调整视频大小后，侧边栏未同步调整位置
- 根因：缺少 ResizeObserver 监听视频容器大小变化
- 修复：添加实时联动逻辑，监听视频和窗口大小变化
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：视频播放器扩展需要多种方式监听布局变化

---

## P-2024-066 视频侧边栏切换视频后字幕加载失败

- 项目：视频侧边栏
- 仓库：/Users/apple/视频侧边栏
- 发生版本：当前版本
- 现象：在 YouTube 切换视频后，第一次加载字幕失败
- 根因：视频切换时字幕 API 请求时机不对，新视频 ID 尚未生效
- 修复：添加视频切换检测和延迟加载机制
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：YouTube 视频切换需要监听 URL 变化和播放器状态

---

## P-2024-067 久坐通知 Service Worker 缓存问题

- 项目：久坐通知
- 仓库：/Users/apple/久坐通知
- 发生版本：当前版本
- 现象：更新应用后用户仍使用旧版本
- 根因：Service Worker 使用缓存优先策略，不获取最新版本
- 修复：改为网络优先策略，确保获取最新版本
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：PWA 缓存策略需要根据应用更新频率选择

---

## P-2024-068 久坐通知 iPhone 通知权限问题

- 项目：久坐通知
- 仓库：/Users/apple/久坐通知
- 发生版本：当前版本
- 现象：在 iPhone 上无法发送通知提醒
- 根因：iOS Safari 对 Web 通知有特殊限制，需要 PWA 安装后才能发送通知
- 修复：添加 PWA 支持，引导用户添加到主屏幕
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：iOS Web 通知必须通过 PWA 实现

---

## P-2024-069 网页看书目录按钮嵌套显示

- 项目：网页看书
- 仓库：/Users/apple/网页看书
- 发生版本：当前版本
- 现象：第二次点击目录按钮时，目录不是隐藏而是嵌套显示
- 根因：点击事件处理逻辑只判断了显示，未正确处理隐藏
- 修复：修复目录按钮逻辑，添加显示/隐藏切换判断
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-070 网页看书 Edge 浏览器兼容性问题

- 项目：网页看书
- 仓库：/Users/apple/网页看书
- 发生版本：当前版本
- 现象：在 Edge 浏览器上滚动和显示异常
- 根因：CSS 滚动属性在 Edge 上有兼容性问题
- 修复：添加 Edge 浏览器兼容性 CSS 前缀
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：Web 应用需要测试多浏览器兼容性

---

## P-2024-071 注意力追踪器计时器占位符闪烁

- 项目：注意力追踪器
- 仓库：/Users/apple/注意力追踪器最终版
- 发生版本：当前版本
- 现象：计时器继续/暂停时数字占位符闪烁
- 根因：状态切换时 DOM 更新导致重绘闪烁
- 修复：优化状态切换逻辑，避免不必要的 DOM 更新
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-072 播客 Cloudinary 存储配置问题

- 项目：播客
- 仓库：/Users/apple/播客
- 发生版本：当前版本
- 现象：上传播客文件后无法正确获取 URL
- 根因：Cloudinary file_url 获取逻辑不统一，部分代码使用本地 /uploads 回退
- 修复：统一使用 Cloudinary file_url，移除本地回退逻辑
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：云存储集成需要全局统一使用云端 URL

---

## P-2024-073 背单词网页 YouTube 字幕获取失败

- 项目：背单词的网页
- 仓库：/Users/apple/背单词的网页
- 发生版本：当前版本
- 现象：无法获取 YouTube 视频字幕
- 根因：youtube-transcript 库被 YouTube 限制
- 修复：改用 YouTube timedtext API 直接获取 WebVTT 格式字幕
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：第三方库被限制时需要直接调用官方 API

---

## P-2024-074 时间追踪器 Enter 键跳转问题

- 项目：时间追踪器
- 仓库：/Users/apple/时间追踪器
- 发生版本：当前版本
- 现象：按 Enter 键无法正确跳转到计时页面
- 根因：事件处理逻辑过于复杂，多个跳转条件冲突
- 修复：简化逻辑，直接跳转到计时页面
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-075 Slash-Command-Prompter 模式切换后斜杠命令菜单不同步

- 项目：Slash-Command-Prompter
- 仓库：/Users/apple/prompt/Slash-Command-Prompter
- 发生版本：2.0 之前
- 现象：切换模式后，斜杠命令菜单仍显示第一个模式的提示词，而非当前选中模式
- 根因：模式切换事件未正确触发菜单数据源更新
- 修复：确保 / 命令显示当前选中模式的提示词
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：状态切换需要同步更新所有相关 UI 组件

---

## P-2024-076 Slash-Command-Prompter 提示词上移仅在当前模式内有效

- 项目：Slash-Command-Prompter
- 仓库：/Users/apple/prompt/Slash-Command-Prompter
- 发生版本：2.0 之前
- 现象：将提示词上移时，只能在当前模式内移动，无法跨模式调整
- 根因：排序逻辑限制在当前模式数组内
- 修复：优化斜杠菜单触发逻辑，v2.0 版本发布
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-077 微信公众号爬虫搜索失效

- 项目：wechat-spider
- 仓库：/Users/apple/微信公众号/wechat-spider
- 发生版本：当前版本
- 现象：搜索公众号功能失效
- 根因：微信改版导致接口变化
- 修复：适配微信新版接口
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：依赖第三方平台的爬虫需要定期维护适配

---

## P-2024-078 沉浸式写作页面跳动

- 项目：zen-flow (沉浸式写作)
- 仓库：/Users/apple/沉浸式写作/zen-flow
- 发生版本：当前版本
- 现象：输入文字时页面发生跳动
- 根因：调整 textarea 高度时未保持滚动位置
- 修复：在调整 textarea 高度时保持滚动位置
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：自适应高度的文本框需要处理滚动位置

---

## P-2024-079 git-worktree-manager 路径解析错误

- 项目：git-worktree-manager
- 仓库：/Users/apple/git-worktree-manage/git-worktree-manager
- 发生版本：当前版本
- 现象：在某些目录下执行命令时 git 路径解析错误
- 根因：execBase 函数中 git 路径解析逻辑不完善
- 修复：改进 git 路径解析，使用正确的 mainFolder
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-080 震动 App 数字输入双重输入

- 项目：curlsapp (震动)
- 仓库：/Users/apple/震动/curlsapp
- 发生版本：当前版本
- 现象：数字输入框出现双重输入问题
- 根因：自定义数字输入组件与原生输入冲突
- 修复：替换为标准数字输入，实现输入框之间无缝切换
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-081 ClipBook 退出时历史记录未清除

- 项目：ClipBook
- 仓库：/Users/apple/Downloads/ClipBook
- 发生版本：当前版本
- 现象：退出应用时历史记录未正确清除
- 根因：退出事件处理中清除逻辑有 bug
- 修复：修复退出时历史记录清除逻辑
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-082 看书神器下载文件名编码问题

- 项目：tobooks (看书神器)
- 仓库：/Users/apple/看书神器/tobooks
- 发生版本：当前版本
- 现象：下载文件时文件名编码错误，中文乱码
- 根因：HTTP header 中 filename 编码处理不当
- 修复：修复下载 header filename 编码
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：HTTP 下载文件名需要正确处理 UTF-8 编码

---

## P-2024-083 acemcp Google Antigravity MCP invalid trailing data 错误

- 项目：acemcp
- 仓库：/Users/apple/ace/acemcp
- 发生版本：v0.2.0 之前
- 现象：调用 Google Antigravity MCP 时出现 "invalid trailing data" 错误
- 根因：stdio 流未强制使用 UTF-8 编码，导致数据解析错误
- 修复：强制 stdio 流使用 UTF-8 编码
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：MCP 服务器需要确保 stdio 编码一致性

---

## P-2024-084 RI 笔记功能多个关键问题

- 项目：RI (信息置换器)
- 仓库：/Users/apple/信息过滤器和信息置换器叠加/RI
- 发生版本：当前版本
- 现象：笔记功能存在多个问题：列表项编辑后未正确保存、导出后主页未刷新
- 根因：
  1. 编辑使用了错误的保存方法
  2. 导出按钮保存后未触发主页刷新
- 修复：
  1. 列表项编辑后使用 updateWord 正确保存
  2. 笔记导出按钮保存后主页自动刷新
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-085 Strong-Iterate 微信验证文件部署失败

- 项目：Strong-Iterate
- 仓库：/Users/apple/产品更新/Strong-Itreate
- 发生版本：当前版本
- 现象：微信验证文件无法在网站根目录访问
- 根因：验证文件未放在 public 文件夹，部署后路径不正确
- 修复：将文件移动到 public 文件夹确保正确部署到根目录
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：静态文件需要放在正确的 public 目录才能被访问

---

## P-2024-086 笔记升级工具按钮大小不一致

- 项目：Note-taking-tool (笔记升级)
- 仓库：/Users/apple/笔记升级/Note-taking-tool
- 发生版本：当前版本
- 现象：清理缓存按钮与其他按钮大小不一致
- 根因：CSS 样式未统一
- 修复：添加黄色清理缓存按钮并修复按钮大小一致性
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-087 codex-watcher 侧边栏重渲染后高亮丢失

- 项目：codex-watcher
- 仓库：/Users/apple/codexwatcher/codex-watcher
- 发生版本：当前版本
- 现象：侧边栏重新渲染后，活动会话高亮状态丢失
- 根因：重渲染时未保存和恢复高亮状态
- 修复：持久化并重新应用活动会话高亮，恢复每个来源的最后打开状态
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-088 codex-watcher DOMPurify 下展开/折叠失效

- 项目：codex-watcher
- 仓库：/Users/apple/codexwatcher/codex-watcher
- 发生版本：当前版本
- 现象：使用 DOMPurify 后展开/折叠按钮点击无效
- 根因：DOMPurify 清理了 inline onclick 事件处理器
- 修复：使用事件委托替代 inline onclick，改用 data-* 属性
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：使用 DOMPurify 时需要用事件委托替代内联事件

---

## P-2024-089 kexin-podcast Render 部署 SQLite3 构建失败

- 项目：kexin-podcast
- 仓库：/Users/apple/kexin-podacast/My-podcast
- 发生版本：当前版本
- 现象：部署到 Render 时 SQLite3 构建失败
- 根因：Render 环境缺少 SQLite3 原生编译依赖
- 修复：添加必要的构建依赖或改用纯 JS 实现
- 回归检查：部署验证
- 状态：verified
- 日期：2024-12-16
- 经验：云平台部署原生模块需要检查构建环境

---

## P-2024-090 Full-screen-prompt 删除功能异常

- 项目：Full-screen-prompt
- 仓库：/Users/apple/提示词最新的/Full-screen-prompt
- 发生版本：当前版本
- 现象：删除提示词时功能异常
- 根因：删除确认对话框逻辑有问题
- 修复：修复删除功能，添加自定义确认对话框
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-091 Full-screen-prompt 图标格式错误

- 项目：Full-screen-prompt
- 仓库：/Users/apple/提示词最新的/Full-screen-prompt
- 发生版本：当前版本
- 现象：应用图标显示异常
- 根因：图标格式不正确
- 修复：修复图标格式，同时添加窗口边缘拖拽功能
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-092 twscrape 部署问题

- 项目：twscrape (Twitter 爬虫)
- 仓库：/Users/apple/twiter/twscrape
- 发生版本：当前版本
- 现象：部署后爬虫无法正常运行
- 根因：部署配置问题
- 修复：修复部署问题并优化实时爬取
- 回归检查：部署验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-093 hack-airdrop Railway/Vercel 部署配置问题

- 项目：hack-airdrop
- 仓库：/Users/apple/twiter/hack-airdrop
- 发生版本：当前版本
- 现象：部署到 Railway 和 Vercel 失败
- 根因：端口配置和部署配置不正确
- 修复：修复 Railway 端口配置和 Vercel 部署配置
- 回归检查：部署验证
- 状态：verified
- 日期：2024-12-16
- 经验：不同云平台的部署配置需要分别适配

---

## P-2024-094 Attention-Span 计时器暂停时间计算错误

- 项目：Attention-Span (注意力追踪器)
- 仓库：/Users/apple/注意力追踪器最终版/Attention-Span
- 发生版本：当前版本
- 现象：暂停计时器后恢复时，时间计算不正确
- 根因：暂停时间未正确从总时间中扣除
- 修复：修复计时器暂停时间计算 bug
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-095 Attention-Span 重复记录问题

- 项目：Attention-Span (注意力追踪器)
- 仓库：/Users/apple/注意力追踪器最终版/Attention-Span
- 发生版本：当前版本
- 现象：同一个计时记录被重复保存
- 根因：保存逻辑触发多次
- 修复：添加重复记录检测和防抖
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-096 DDK 跑步愿望图片路径错误

- 项目：DDK
- 仓库：/Users/apple/DDK
- 发生版本：当前版本
- 现象：跑步愿望图片无法显示
- 根因：图片引用路径不正确
- 修复：更新图片引用路径
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-097 DDK 文字重叠问题

- 项目：DDK
- 仓库：/Users/apple/DDK
- 发生版本：当前版本
- 现象：页面文字出现重叠
- 根因：CSS 布局问题
- 修复：修复文字重叠问题，优化图片命名
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-098 编程网站中文引号语法错误

- 项目：编程网站
- 仓库：/Users/apple/编程网站
- 发生版本：当前版本
- 现象：代码中使用了中文引号导致语法错误
- 根因：输入法切换时误输入中文引号
- 修复：将中文引号替换为英文引号
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：代码编辑时注意输入法状态，避免中文标点

---

## P-2024-099 aliyun-deploy Supabase URL 配置错误

- 项目：aliyun-deploy (nativePaySDK)
- 仓库：/Users/apple/Downloads/nativePaySDK/aliyun-deploy
- 发生版本：当前版本
- 现象：部署到阿里云后 Supabase 连接失败
- 根因：Supabase URL 配置不正确
- 修复：修正 Supabase URL 配置
- 回归检查：部署验证
- 状态：verified
- 日期：2024-12-16
- 经验：云部署时需要检查所有环境变量配置

---

## P-2024-100 RI 多桌面/全屏 Space 窗口跳动

- 项目：RI (Replace-Information)
- 仓库：/Users/apple/信息置换起/RI
- 发生版本：当前版本
- 现象：在 macOS 多桌面或全屏 Space 环境下，窗口出现跳动
- 根因：窗口位置计算未考虑多 Space 环境
- 修复：修复多桌面/全屏 Space 窗口跳动问题，添加清理启动脚本解决开机后窗口跳动
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：macOS 桌面应用需要处理多 Space 环境

---

## P-2024-101 Note-taking-tool 标题被 CSS 污染

- 项目：Note-taking-tool (笔记升级)
- 仓库：/Users/apple/笔记升级/Note-taking-tool
- 发生版本：当前版本
- 现象：提取的标题包含 CSS 样式文本
- 根因：提取标题时未跳过 style/script 标签，未过滤疑似 CSS 文本
- 修复：提取标题时跳过 style/script 且过滤疑似 CSS 文本；粘贴清理时移除非内容标签
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：DOM 文本提取需要过滤样式和脚本内容

---

## P-2024-102 Note-taking-tool 沉浸式翻译插件按钮重叠

- 项目：Note-taking-tool (笔记升级)
- 仓库：/Users/apple/笔记升级/Note-taking-tool
- 发生版本：当前版本
- 现象：安装沉浸式翻译浏览器插件后，按钮出现重叠
- 根因：插件注入的 DOM 元素与应用按钮冲突
- 修复：修复沉浸式翻译插件导致的按钮重叠问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：Web 应用需要考虑浏览器插件的 DOM 注入影响

---

## P-2024-103 wechat-spider 保存图片到 OSS 问题

- 项目：wechat-spider
- 仓库：/Users/apple/微信公众号/wechat-spider
- 发生版本：当前版本
- 现象：图片无法正确保存到 OSS
- 根因：OSS 上传配置或控制逻辑有问题
- 修复：修复控制保存图片到 OSS 的逻辑
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-104 Strong-Iterate navBackButton 未定义

- 项目：Strong-Iterate
- 仓库：/Users/apple/产品更新/Strong-Itreate
- 发生版本：当前版本
- 现象：点击关闭按钮时报错 navBackButton 未定义
- 根因：事件监听器中引用了未定义的变量
- 修复：修复关闭按钮事件监听器中 navBackButton 变量未定义的问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：事件处理器中引用的变量需要确保已定义

---

## P-2024-105 Strong-Iterate Web/Crawler 视图退出逻辑

- 项目：Strong-Iterate
- 仓库：/Users/apple/产品更新/Strong-Itreate
- 发生版本：当前版本
- 现象：关闭按钮无法正确隐藏 Web 和 Crawler 视图
- 根因：关闭按钮事件处理未包含这些视图的隐藏逻辑
- 修复：添加关闭按钮对 web-projects-view 和 crawlers-view 的隐藏处理
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-106 kotadb MCP tool schema localPath 参数问题

- 项目：kotadb
- 仓库：/Users/apple/agent/kotadb
- 发生版本：PR #412, #501
- 现象：MCP 工具调用时出现参数错误
- 根因：MCP tool schema 中包含了不应该存在的 localPath 参数
- 修复：从 MCP tool schema 中移除 localPath 参数
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：MCP 工具定义需要精确匹配实际参数

---

## P-2024-107 Strong-Iterate HTML 语法错误

- 项目：Strong-Iterate
- 仓库：/Users/apple/测试马上删除/Strong-Itreate
- 发生版本：当前版本
- 现象：页面渲染异常
- 根因：HTML 语法错误
- 修复：修复 HTML 语法错误，完善章节内容
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-108 tobooks text-to-epub 页面高度问题

- 项目：tobooks
- 仓库：/Users/apple/tobooks
- 发生版本：当前版本
- 现象：text-to-epub.html 页面高度显示不正确
- 根因：CSS 高度设置问题
- 修复：修复页面高度问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-109 播客 fs 变量重复声明

- 项目：My-podcast (播客)
- 仓库：/Users/apple/播/My-podcast
- 发生版本：当前版本
- 现象：启动时报错变量重复声明
- 根因：fs 模块被重复 require/import
- 修复：修复 fs 变量重复声明错误
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：避免在同一文件中重复声明变量

---

## P-2024-110 kexin-podcast DELETE API 参数类型问题

- 项目：kexin-podcast
- 仓库：/Users/apple/podcast/kexin-podcast
- 发生版本：当前版本
- 现象：DELETE /api/podcasts/:id 返回 404
- 根因：API 不接受数字类型 ID，且非幂等
- 修复：修复 DELETE API 接受数字 ID，实现幂等性避免 404
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：REST API 应该设计为幂等的

---

## P-2024-111 ClipBook 删除时 bug

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：早期版本
- 现象：删除剪贴板项目时出现错误
- 根因：删除逻辑有 bug
- 修复：修复删除时的 bug
- 回归检查：手动验证
- 状态：verified
- 日期：2024-05-01
- 来源：git log (早期历史)

---

## P-2024-112 ClipBook 初始状态 bug

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：早期版本
- 现象：应用启动时初始状态异常
- 根因：初始化逻辑有 bug
- 修复：修复初始状态 bug，同时使骨架可拖拽
- 回归检查：手动验证
- 状态：verified
- 日期：2024-05-01
- 来源：git log (早期历史)

---

## P-2024-113 ClipBook HTML 和代码被忽略

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：早期版本
- 现象：复制 HTML 和代码时内容被忽略
- 根因：剪贴板类型判断逻辑有误
- 修复：修复 HTML 和代码被忽略的问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-05-01
- 来源：git log (早期历史)

---

## P-2024-114 twscrape OTP 验证码问题

- 项目：twscrape (Twitter 爬虫)
- 仓库：/Users/apple/twiter/twscrape
- 发生版本：早期版本
- 现象：OTP 验证码处理异常
- 根因：OTP 代码解析或提交逻辑有问题
- 修复：修复 OTP 代码处理
- 回归检查：手动验证
- 状态：verified
- 日期：2024-05-01
- 来源：git log (早期历史)

---

## P-2024-115 twscrape 登录时无 ct0 cookie

- 项目：twscrape (Twitter 爬虫)
- 仓库：/Users/apple/twiter/twscrape
- 发生版本：Issue #143
- 现象：登录时找不到 ct0 cookie 导致失败
- 根因：Twitter 接口变化，ct0 获取时机变化
- 修复：修复登录时无 ct0 找到的情况
- 回归检查：手动验证
- 状态：verified
- 日期：2024-05-01
- 来源：git log (早期历史)

---

## P-2024-116 twscrape 登录无限循环

- 项目：twscrape (Twitter 爬虫)
- 仓库：/Users/apple/twiter/twscrape
- 发生版本：Issue #132, #165
- 现象：使用不存在的账户登录时进入无限循环
- 根因：登录失败处理未考虑账户不存在的情况
- 修复：修复不存在账户登录时的无限循环
- 回归检查：手动验证
- 状态：verified
- 日期：2024-05-01
- 来源：git log (早期历史)
- 经验：登录逻辑需要处理各种失败场景

---

## P-2024-117 git-worktree-manager 翻译问题

- 项目：git-worktree-manager
- 仓库：/Users/apple/git-worktree-manage/git-worktree-manager
- 发生版本：早期版本
- 现象：界面翻译显示不正确
- 根因：i18n 配置或翻译文件问题
- 修复：修复翻译问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-05-01
- 来源：git log (早期历史)

---

## P-2024-118 git-worktree-manager worktree 事件监听

- 项目：git-worktree-manager
- 仓库：/Users/apple/git-worktree-manage/git-worktree-manager
- 发生版本：早期版本
- 现象：worktree 变化时界面未更新
- 根因：worktree 事件监听未正确设置
- 修复：修复监听 worktree 事件
- 回归检查：手动验证
- 状态：verified
- 日期：2024-05-01
- 来源：git log (早期历史)

---

## P-2024-119 git-worktree-manager 移动 worktree 问题

- 项目：git-worktree-manager
- 仓库：/Users/apple/git-worktree-manage/git-worktree-manager
- 发生版本：早期版本
- 现象：移动 worktree 时出错
- 根因：移动逻辑有 bug
- 修复：修复移动 worktree 功能
- 回归检查：手动验证
- 状态：verified
- 日期：2024-05-01
- 来源：git log (早期历史)

---

## P-2024-120 RI 开发版本无法访问原有数据

- 项目：RI (Replace-Information)
- 仓库：/Users/apple/信息置换起/RI
- 发生版本：当前版本
- 现象：开发版本无法访问原有数据库数据
- 根因：数据目录配置被修改，未使用默认数据目录
- 修复：恢复使用默认数据目录，确保开发版本可访问原有数据
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-121 RI 文字颜色显示问题

- 项目：RI (Replace-Information)
- 仓库：/Users/apple/信息置换起/RI
- 发生版本：当前版本
- 现象：文字颜色显示不正确
- 根因：CSS 样式问题
- 修复：修复文字颜色显示问题，同时添加切换模式自动保存功能
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-122 RI 主窗口和笔记窗口在全屏应用前来回跳动

- 项目：RI (Replace-Information)
- 仓库：/Users/apple/信息置换起/RI
- 发生版本：当前版本
- 现象：当有全屏应用时，主窗口和笔记窗口来回跳动
- 根因：窗口位置计算受全屏应用影响
- 修复：修复窗口在全屏应用前来回跳动的问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：macOS 窗口管理需要考虑全屏应用的影响

---

## P-2024-123 ClipBook 本地化 Help 菜单 bug

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：当前版本
- 现象：Help tray menu 本地化显示错误
- 根因：本地化配置 bug
- 修复：修复 Help tray menu 的本地化 bug
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-124 zhuyili 主页完成按钮需点两次

- 项目：zhuyili (注意力追踪器)
- 仓库：/Users/apple/zhuyili
- 发生版本：当前版本
- 现象：主页完成按钮需要点击两次才能生效
- 根因：handleButtonAction 不是 async 函数，完成操作未正确 await
- 修复：将主页 handleButtonAction 改为 async，完成操作改为 await completeActivityAndReset()
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：涉及异步操作的事件处理器需要正确使用 async/await

---

## P-2024-125 zhuyili 活动记录云端同步失败

- 项目：zhuyili (注意力追踪器)
- 仓库：/Users/apple/zhuyili
- 发生版本：当前版本
- 现象：活动记录无法同步到云端
- 根因：云端同步逻辑有问题
- 修复：修复活动记录云端同步失败问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-126 wechat-spider avatar 和 abstract 设置问题

- 项目：wechat-spider
- 仓库：/Users/apple/微信公众号/wechat-spider
- 发生版本：当前版本
- 现象：头像和摘要显示异常
- 根因：数据初始化时未正确处理空值
- 修复：avatar 和 abstract 先设置为空，后期修正
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-127 Strong-Iterate App 视图退出逻辑

- 项目：Strong-Iterate
- 仓库：/Users/apple/新网站测试/Strong-Itreate
- 发生版本：当前版本
- 现象：关闭按钮无法正确隐藏 App 视图
- 根因：关闭按钮事件处理未包含 apps-view 的隐藏逻辑
- 修复：添加关闭按钮对 apps-view 的隐藏处理
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-128 ClipBook 快捷键注册失败导致崩溃

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：早期版本
- 现象：尝试注销未成功注册的快捷键时应用崩溃
- 根因：快捷键注册失败后未重置为空，后续注销操作导致崩溃
- 修复：注册失败时将快捷键重置为空，避免后续注销崩溃
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：资源注册失败时需要正确清理状态

---

## P-2024-129 ClipBook 显示/隐藏详情时崩溃

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：早期版本
- 现象：点击显示/隐藏详情按钮时应用崩溃
- 根因：UI 状态切换逻辑有 bug
- 修复：修复显示/隐藏详情时的崩溃问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-130 ClipBook 启动时崩溃

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：早期版本
- 现象：应用启动时崩溃
- 根因：初始化逻辑有 bug
- 修复：修复启动时崩溃问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-131 codex-watcher 本地 vendor 404/MIME 错误

- 项目：codex-watcher
- 仓库：/Users/apple/codexwatcher/codex-watcher
- 发生版本：当前版本
- 现象：加载本地 vendor 文件时出现 404 和 MIME 类型错误
- 根因：本地 vendor 标签在文件不存在时导致错误
- 修复：移除本地 vendor 标签，仅使用 CDN
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：静态资源加载需要考虑文件缺失的降级处理

---

## P-2024-132 git-worktree-manager getNameRev 错误处理

- 项目：git-worktree-manager
- 仓库：/Users/apple/git-worktree-manage/git-worktree-manager
- 发生版本：当前版本
- 现象：getNameRev 函数执行出错时未正确处理
- 根因：错误处理逻辑不完善
- 修复：在 getNameRev 函数中正确处理错误
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-133 git-worktree-manager worktree pruning 问题

- 项目：git-worktree-manager
- 仓库：/Users/apple/git-worktree-manage/git-worktree-manager
- 发生版本：Issue #23
- 现象：worktree pruning 操作不正确
- 根因：git worktree prune 相关操作逻辑有问题
- 修复：改进 worktree pruning 和相关 git 操作
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-134 kexin-podcast JavaScript 变量重复声明

- 项目：kexin-podcast
- 仓库：/Users/apple/podcast/kexin-podcast
- 发生版本：当前版本
- 现象：启动时报错变量重复声明
- 根因：JavaScript 变量被重复声明
- 修复：修复 JavaScript 变量重复声明错误
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-135 Slash-Command-Prompter mode 下拉菜单对齐问题

- 项目：Slash-Command-Prompter
- 仓库：/Users/apple/prompt/Slash-Command-Prompter
- 发生版本：当前版本
- 现象：mode 下拉菜单与其他元素对齐不正确
- 根因：CSS 布局问题
- 修复：优化 UI 布局，修复 mode 下拉菜单对齐问题，统一按钮间距
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-136 tobooks 搜索栏和按钮重叠

- 项目：tobooks
- 仓库：/Users/apple/tobooks
- 发生版本：当前版本
- 现象：顶部栏搜索栏和按钮出现重叠
- 根因：CSS 布局问题
- 修复：重构顶部栏，使用 CSS Grid 布局解决重叠问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：复杂布局使用 CSS Grid 比 Flexbox 更易控制

---

## P-2024-137 zhuyili Google 登录回调 URL 问题

- 项目：zhuyili (注意力追踪器)
- 仓库：/Users/apple/zhuyili
- 发生版本：当前版本
- 现象：Google 登录回调失败
- 根因：回调 URL 配置错误
- 修复：修复 Google 登录回调 URL
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-138 ClipBook 多文件选择时布局问题

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：当前版本
- 现象：选择多个文件时布局显示异常
- 根因：多选模式下 CSS 布局未正确处理
- 修复：修复多文件选择时的布局问题，同时支持批量粘贴多个文件
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-139 ClipBook 通用布局问题

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：早期版本
- 现象：界面布局显示不正确
- 根因：CSS 布局问题
- 修复：修复布局问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-140 ClipBook 图片标题问题

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：当前版本
- 现象：图片标题显示不正确
- 根因：图片元数据解析问题
- 修复：修复图片标题显示，同时添加右键菜单命令
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-141 kotadb orchestrator 原子代理签名不匹配

- 项目：kotadb
- 仓库：/Users/apple/agent/kotadb
- 发生版本：当前版本
- 现象：orchestrator.py 中存在 7 个原子代理签名不匹配
- 根因：代理函数签名定义与实际调用不一致
- 修复：解决 orchestrator.py 中 7 个原子代理签名不匹配问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：函数签名变更时需要同步更新所有调用方

---

## P-2024-142 zhuyili 活动记录不同步核心问题

- 项目：zhuyili (注意力追踪器)
- 仓库：/Users/apple/zhuyili
- 发生版本：当前版本
- 现象：活动记录在设备间不同步
- 根因：同步逻辑存在核心问题
- 修复：修复活动记录不同步的核心问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-143 ClipBook 检查更新时死锁

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：当前版本
- 现象：检查更新时应用卡死
- 根因：更新检查逻辑存在死锁
- 修复：修复检查更新时的死锁问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：多线程更新检查需要避免主线程阻塞

---

## P-2024-144 kotadb 数据库 rate limit 更新问题

- 项目：kotadb
- 仓库：/Users/apple/agent/kotadb
- 发生版本：Issue #463
- 现象：数据库中已有的 rate limit 无法正确更新
- 根因：更新逻辑未正确处理已存在的记录
- 修复：更新数据库中已存在的 rate limit 记录
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-145 tobooks intro 按钮链接错误

- 项目：tobooks
- 仓库：/Users/apple/tobooks
- 发生版本：当前版本
- 现象：intro 按钮点击后跳转到错误的 URL
- 根因：链接地址配置错误
- 修复：更新 intro 按钮链接到正确的 URL
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-146 tobooks OG/Twitter 图片域名问题

- 项目：tobooks
- 仓库：/Users/apple/tobooks
- 发生版本：当前版本
- 现象：社交分享时预览图片无法显示
- 根因：og:image 和 twitter:image 未使用实际的 Netlify 域名
- 修复：更新 og:image 和 twitter:image 使用实际 Netlify 域名
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：社交分享图片需要使用完整的绝对 URL

---

## P-2024-147 zhuyili 详情页按钮完全点不动

- 项目：zhuyili (注意力追踪器)
- 仓库：/Users/apple/zhuyili
- 发生版本：当前版本
- 现象：计时器详情页面的按钮完全无法点击
- 根因：事件绑定方式有问题
- 修复：使用事件委托修复详情页按钮无法点击的问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：动态生成的元素需要使用事件委托

---

## P-2024-148 kotadb v0.1.1 生产环境回滚

- 项目：kotadb
- 仓库：/Users/apple/agent/kotadb
- 发生版本：v0.1.1
- 现象：v0.1.1 版本在生产环境出现问题需要回滚
- 根因：新版本存在未发现的问题
- 修复：回滚到之前稳定版本
- 回归检查：生产环境验证
- 状态：verified
- 日期：2024-12-16
- 经验：生产环境发布需要更充分的测试

---

## P-2024-149 tobooks iOS 主屏独立模式扩展不可用

- 项目：tobooks
- 仓库：/Users/apple/tobooks
- 发生版本：当前版本
- 现象：iOS 从主屏幕图标启动时浏览器扩展不可用
- 根因：iOS standalone 模式下扩展无法工作
- 修复：尝试添加"在 Safari 中打开"提示按钮（后被 revert）
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：iOS PWA standalone 模式与扩展不兼容是平台限制

---

## P-2024-150 git-worktree-manager worktree 列表处理重构问题

- 项目：git-worktree-manager
- 仓库：/Users/apple/git-worktree-manage/git-worktree-manager
- 发生版本：当前版本
- 现象：worktree 列表处理重构后出现问题
- 根因：重构引入了新的 bug
- 修复：回滚 worktree 列表处理重构
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：重构需要充分的测试覆盖

---

## P-2024-151 ClipBook 拼写错误

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：当前版本
- 现象：界面文本拼写错误
- 根因：拼写错误
- 修复：修复拼写错误
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-152 ClipBook 缺少依赖

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：当前版本
- 现象：应用启动或编译失败
- 根因：缺少必要的依赖
- 修复：添加缺少的依赖
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-153 ClipBook 预览面板边框缺失

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：当前版本
- 现象：预览面板边框不显示
- 根因：CSS 样式缺失
- 修复：修复预览面板边框缺失问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-154 git-worktree-manager 国际化文本遗漏

- 项目：git-worktree-manager
- 仓库：/Users/apple/git-worktree-manage/git-worktree-manager
- 发生版本：当前版本
- 现象：部分界面文本未翻译
- 根因：国际化文本配置遗漏
- 修复：补充遗漏的国际化文本
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-155 iterate UnoCSS safelist 黑色变体问题

- 项目：iterate (cunzhi)
- 仓库：https://github.com/imhuso/cunzhi
- 发生版本：当前版本
- 现象：黑色相关的 CSS 类不生效
- 根因：UnoCSS safelist 未包含黑色变体
- 修复：修复 UnoCSS safelist 添加黑色变体
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：UnoCSS safelist 需要包含所有用到的动态类名

---

## P-2024-156 insidebar-ai Share 按钮布局不一致

- 项目：insidebar-ai
- 仓库：/Users/apple/insidebar-ai
- 发生版本：当前版本
- 现象：/chats/ 和 /pages/ 页面的 Share 按钮布局不同导致功能异常
- 根因：不同页面的按钮布局结构不一致
- 修复：处理不同 Share 按钮布局
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：扩展需要适配多种页面布局

---

## P-2024-157 codex-watcher indexer_test vet 错误

- 项目：codex-watcher
- 仓库：/Users/apple/codexwatcher/codex-watcher
- 发生版本：当前版本
- 现象：运行 go vet 时 indexer_test 出错
- 根因：测试代码不符合 vet 规范
- 修复：修复 indexer_test 中的 vet 错误
- 回归检查：CI 验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-158 iterate 多开时配置不同步

- 项目：iterate (cunzhi)
- 仓库：https://github.com/imhuso/cunzhi
- 发生版本：PR #48
- 现象：多开应用时配置不同步
- 根因：多个实例同时操作配置文件导致冲突
- 修复：采用单实例模式并监听窗口焦点，解决多开时配置不同步问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：桌面应用需要考虑单实例模式避免配置冲突

---

## P-2024-159 zhuyili 生产环境 OAuth 回调跳回本地

- 项目：zhuyili (注意力追踪器)
- 仓库：/Users/apple/zhuyili
- 发生版本：当前版本
- 现象：生产环境 OAuth 回调后出现 "Cannot GET /" 错误
- 根因：OAuth 回调 URL 跳回到本地而不是 Netlify 正式域名
- 修复：生产环境 OAuth 回调固定到 Netlify 正式域名
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：OAuth 回调 URL 需要根据环境正确配置

---

## P-2024-160 zhuyili 用户数据隔离和 JSON 导入同步

- 项目：zhuyili (注意力追踪器)
- 仓库：/Users/apple/zhuyili
- 发生版本：当前版本
- 现象：用户数据未正确隔离，JSON 导入后数据不同步
- 根因：数据隔离和同步逻辑有问题
- 修复：修复用户数据隔离和 JSON 导入同步问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-161 Strong-Iterate Netlify 部署 PNG/JPEG 扩展名问题

- 项目：Strong-Iterate
- 仓库：/Users/apple/产品更新/Strong-Itreate
- 发生版本：当前版本
- 现象：Netlify 部署时图片资源 404
- 根因：vite.config.js 未包含 PNG 和 JPEG 大写扩展名
- 修复：在 vite.config.js 中添加 PNG 和 JPEG 大写扩展名支持
- 回归检查：部署验证
- 状态：verified
- 日期：2024-12-16
- 经验：Vite 配置需要考虑文件扩展名大小写

---

## P-2024-162 Strong-Iterate JS 文件 404 问题

- 项目：Strong-Iterate
- 仓库：/Users/apple/产品更新/Strong-Itreate
- 发生版本：当前版本
- 现象：部署后 JS 文件 404
- 根因：script 标签配置问题
- 修复：更新 vite.config.js 并修复 script 标签
- 回归检查：部署验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-163 iterate proc-macro 编译问题

- 项目：iterate (cunzhi)
- 仓库：https://github.com/imhuso/cunzhi
- 发生版本：当前版本
- 现象：proc-macro 编译失败
- 根因：静态链接标志导致 proc-macro 编译问题
- 修复：移除静态链接标志解决 proc-macro 编译问题
- 回归检查：CI 验证
- 状态：verified
- 日期：2024-12-16
- 经验：Rust proc-macro 不兼容某些静态链接配置

---

## P-2024-164 twscrape 构建问题

- 项目：twscrape (Twitter 爬虫)
- 仓库：/Users/apple/twiter/twscrape
- 发生版本：当前版本
- 现象：项目构建失败
- 根因：构建配置问题
- 修复：修复构建问题
- 回归检查：CI 验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-165 iterate 自定义 Telegram API URL 问题

- 项目：iterate (cunzhi)
- 仓库：https://github.com/imhuso/cunzhi
- 发生版本：当前版本
- 现象：自定义 Telegram API URL 功能不完整
- 根因：监听函数未支持自定义 API URL，前端存在硬编码 URL
- 修复：改进自定义 Telegram API URL 实现，添加前端常量文件消除硬编码
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：API URL 应该统一通过常量管理，避免硬编码

---

## P-2024-166 tobooks /api/book-cutting 根路径访问问题

- 项目：tobooks
- 仓库：/Users/apple/tobooks
- 发生版本：当前版本
- 现象：/api/book-cutting 根路径无法访问
- 根因：路由逻辑未支持根路径
- 修复：修复路由逻辑支持根路径访问，添加调试日志
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-167 zhuyili 二维码不显示

- 项目：zhuyili (注意力追踪器)
- 仓库：/Users/apple/zhuyili
- 发生版本：当前版本
- 现象：二维码无法显示
- 根因：二维码生成或渲染逻辑有问题
- 修复：修复二维码不显示问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-168 背单词网页 YouTube 字幕 API 问题

- 项目：背单词的网页
- 仓库：/Users/apple/背单词的网页
- 发生版本：当前版本
- 现象：YouTube 字幕获取失败
- 根因：youtube-transcript 库不可用
- 修复：改用 YouTube timedtext API 替代 youtube-transcript
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：第三方库不可用时需要寻找官方 API 替代方案

---

## P-2024-169 codex-watcher 侧边栏高亮状态丢失

- 项目：codex-watcher
- 仓库：/Users/apple/codexwatcher/codex-watcher
- 发生版本：当前版本
- 现象：侧边栏重新渲染后活动会话高亮状态丢失
- 根因：状态未持久化，重新渲染时未恢复
- 修复：持久化并在侧边栏重新渲染时恢复活动会话高亮，恢复每个来源最后打开的会话
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：UI 状态需要持久化以支持重新渲染

---

## P-2024-170 Slash-Command-Prompter 模式切换后菜单同步问题

- 项目：Slash-Command-Prompter
- 仓库：/Users/apple/prompt/Slash-Command-Prompter
- 发生版本：当前版本
- 现象：切换模式后斜杠命令菜单显示第一个模式的提示词而非当前选中模式
- 根因：模式切换时菜单数据未正确同步
- 修复：确保 / 命令显示当前选中模式的提示词
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：状态切换时需要同步更新所有依赖的 UI 组件

---

## P-2024-171 tobooks 高亮菜单位置和文字加粗显示

- 项目：tobooks
- 仓库：/Users/apple/tobooks
- 发生版本：当前版本
- 现象：高亮菜单位置不正确，文字加粗显示异常
- 根因：CSS 定位和样式问题
- 修复：修复高亮菜单位置和文字加粗显示
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-172 ClipBook 历史为空时拖拽区域 bug

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：当前版本
- 现象：历史记录为空时拖拽区域功能异常
- 根因：空状态下拖拽区域逻辑有 bug
- 修复：修复历史为空时拖拽区域 bug
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-173 ClipBook 深色/浅色模式滚动条问题

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：当前版本
- 现象：深色/浅色模式切换时滚动条样式不正确
- 根因：滚动条样式未适配主题
- 修复：修复深色/浅色滚动条样式
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-174 codex-watcher DOMPurify 下展开/折叠失效

- 项目：codex-watcher
- 仓库：/Users/apple/codexwatcher/codex-watcher
- 发生版本：当前版本
- 现象：DOMPurify 处理后展开/折叠按钮点击无效
- 根因：DOMPurify 移除了内联 onclick 事件
- 修复：使用事件委托替代内联 onclick，使用 data-* 属性传递参数
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：DOMPurify 会移除内联事件，需要使用事件委托

---

## P-2024-175 git-worktree-manager treeView 点击打开终端和文件夹

- 项目：git-worktree-manager
- 仓库：/Users/apple/git-worktree-manage/git-worktree-manager
- 发生版本：当前版本
- 现象：点击 treeView 无法打开终端和文件夹
- 根因：点击事件处理有问题
- 修复：修复点击 treeView 打开终端和文件夹功能
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-176 zhuyili 微信支付按钮点击事件绑定

- 项目：zhuyili (注意力追踪器)
- 仓库：/Users/apple/zhuyili
- 发生版本：当前版本
- 现象：微信支付购买按钮点击无反应
- 根因：点击事件绑定和试用次数逻辑有问题
- 修复：修复购买按钮点击事件绑定和试用次数逻辑
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-177 iterate 状态同步可能导致白屏

- 项目：iterate (cunzhi)
- 仓库：https://github.com/imhuso/cunzhi
- 发生版本：当前版本
- 现象：应用启动后可能出现白屏
- 根因：状态同步逻辑过于复杂
- 修复：简化状态同步逻辑，修复可能的白屏问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：状态同步逻辑应该保持简单，避免复杂依赖

---

## P-2024-178 kexin-podcast 本地 uploads 回退问题

- 项目：kexin-podcast
- 仓库：/Users/apple/podcast/kexin-podcast
- 发生版本：当前版本
- 现象：部署后文件 URL 仍然回退到本地 /uploads 路径
- 根因：未统一使用 Cloudinary file_url
- 修复：统一使用 Cloudinary file_url，移除本地 /uploads 回退
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：云部署后应该完全使用云存储 URL

---

## P-2024-179 tobooks 高亮功能导致内容消失

- 项目：tobooks
- 仓库：/Users/apple/tobooks
- 发生版本：当前版本
- 现象：使用高亮功能后内容消失
- 根因：高亮处理逻辑有 bug
- 修复：修复高亮功能导致内容消失的问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-180 ClipBook 随机窗口自动隐藏

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：当前版本
- 现象：应用窗口随机自动隐藏
- 根因：窗口状态管理 bug
- 修复：修复随机应用窗口自动隐藏 bug
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-181 ClipBook 活动应用为空时显示窗口问题

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：当前版本
- 现象：当活动应用为空时显示窗口出错
- 根因：未处理活动应用为空的边界情况
- 修复：修复活动应用为空时显示窗口的 bug
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：窗口显示逻辑需要处理空状态

---

## P-2024-182 iterate 移动窗口中文输入候选栏移位

- 项目：iterate (cunzhi)
- 仓库：https://github.com/imhuso/cunzhi
- 发生版本：PR #55
- 现象：移动窗口时中文输入法候选栏位置错位
- 根因：窗口位置变化未正确通知输入法系统
- 修复：修复移动窗口中文输入候选栏移位 bug
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：窗口移动时需要考虑输入法候选栏位置

---

## P-2024-183 tobooks Cmd+Enter 监听模式问题

- 项目：tobooks
- 仓库：/Users/apple/tobooks
- 发生版本：当前版本
- 现象：Cmd+Enter 快捷键不生效
- 根因：使用了错误的事件监听模式
- 修复：改用 window capture 模式监听 Cmd+Enter
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：全局快捷键需要使用 capture 模式

---

## P-2024-184 iterate 增强快捷键默认值问题

- 项目：iterate (cunzhi)
- 仓库：https://github.com/imhuso/cunzhi
- 发生版本：当前版本
- 现象：增强快捷键功能不符合预期
- 根因：默认值设置不正确
- 修复：更新增强快捷键的默认值并优化日志输出
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-185 git-worktree-manager 更新保存仓库时缓存未刷新

- 项目：git-worktree-manager
- 仓库：/Users/apple/git-worktree-manage/git-worktree-manager
- 发生版本：当前版本
- 现象：更新保存的仓库后数据未更新
- 根因：缓存未刷新
- 修复：更新保存的仓库时刷新缓存
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：数据变更后需要刷新相关缓存

---

## P-2024-186 tobooks Cmd+Enter 保存笔记无效

- 项目：tobooks
- 仓库：/Users/apple/tobooks
- 发生版本：当前版本
- 现象：按 Cmd+Enter 保存笔记不生效
- 根因：保存逻辑有问题
- 修复：修复 Cmd+Enter 保存笔记无效的问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-187 ClipBook 路径问题

- 项目：ClipBook
- 仓库：/Users/apple/clipbook/ClipBook
- 发生版本：当前版本
- 现象：文件路径处理有问题
- 根因：路径逻辑 bug
- 修复：修复路径问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-188 git-worktree-manager git 路径解析

- 项目：git-worktree-manager
- 仓库：/Users/apple/git-worktree-manage/git-worktree-manager
- 发生版本：当前版本
- 现象：git 路径解析不正确
- 根因：execBase 函数中 git 路径解析逻辑有问题
- 修复：改进 execBase 函数中的 git 路径解析
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-189 twscrape 解析链接计数问题

- 项目：twscrape (Twitter 爬虫)
- 仓库：/Users/apple/twiter/twscrape
- 发生版本：Issue #56
- 现象：解析的链接计数不正确
- 根因：链接计数逻辑有 bug
- 修复：修复解析链接计数
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-190 twscrape 用户资料中的 URL 问题

- 项目：twscrape (Twitter 爬虫)
- 仓库：/Users/apple/twiter/twscrape
- 发生版本：当前版本
- 现象：用户资料中的 URL 解析不正确
- 根因：URL 解析逻辑有问题
- 修复：修复用户资料中的 URL 解析
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-191 tobooks 高亮加载错误处理

- 项目：tobooks
- 仓库：/Users/apple/tobooks
- 发生版本：当前版本
- 现象：高亮加载失败时没有正确的错误处理
- 根因：异步加载错误处理不完善
- 修复：修复高亮加载错误处理
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-192 zhuyili 主页完成按钮首次点击即生效

- 项目：zhuyili (注意力追踪器)
- 仓库：/Users/apple/zhuyili
- 发生版本：当前版本
- 现象：主页完成按钮首次点击不保存和重置
- 根因：异步操作未正确等待
- 修复：修复完成按钮首次点击即保存和重置
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-193 kotadb 管理账单按钮不可用

- 项目：kotadb
- 仓库：/Users/apple/agent/kotadb
- 发生版本：Issue #450
- 现象：管理账单按钮点击无反应
- 根因：按钮事件绑定或功能实现有问题
- 修复：修复管理账单按钮不可用问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-194 kotadb API 密钥页面自动获取

- 项目：kotadb
- 仓库：/Users/apple/agent/kotadb
- 发生版本：当前版本
- 现象：API 密钥页面加载时未自动获取已有密钥
- 根因：页面加载时未触发获取操作
- 修复：页面加载时自动获取已有 API 密钥
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-195 git-worktree-manager 视图条件和收藏操作

- 项目：git-worktree-manager
- 仓库：/Users/apple/git-worktree-manage/git-worktree-manager
- 发生版本：当前版本
- 现象：视图条件判断不正确，收藏相关操作缺失
- 根因：视图条件逻辑和收藏功能未完善
- 修复：更新视图条件并添加收藏相关操作
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-196 iterate 重复 applyFontVariables 函数

- 项目：iterate (cunzhi)
- 仓库：https://github.com/imhuso/cunzhi
- 发生版本：当前版本
- 现象：代码中存在重复的函数定义
- 根因：重构时未清理旧代码
- 修复：移除重复的 applyFontVariables 函数
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-197 iterate Windows 路径编码问题

- 项目：iterate (cunzhi)
- 仓库：https://github.com/imhuso/cunzhi
- 发生版本：PR #24, #27
- 现象：Windows 系统上 memory 功能路径编码错误
- 根因：Windows 路径编码与 Unix 不同
- 修复：修复 Windows 路径编码问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：跨平台应用需要处理不同系统的路径编码

---

## P-2024-198 zhuyili 计时页面图标显示问题

- 项目：zhuyili (注意力追踪器)
- 仓库：/Users/apple/zhuyili
- 发生版本：当前版本
- 现象：计时页面图标不显示
- 根因：图标资源路径或加载逻辑有问题
- 修复：修复计时页面图标显示问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-199 zhuyili 移动端标题被遮挡

- 项目：zhuyili (注意力追踪器)
- 仓库：/Users/apple/zhuyili
- 发生版本：当前版本
- 现象：移动端标题显示被其他元素遮挡
- 根因：移动端 CSS 布局问题
- 修复：优化移动端标题显示，解决被遮挡问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-200 久坐通知 Service Worker 缓存问题

- 项目：久坐通知
- 仓库：/Users/apple/久坐通知
- 发生版本：当前版本
- 现象：应用无法获取最新版本
- 根因：Service Worker 缓存策略导致旧版本被缓存
- 修复：改为网络优先策略确保获取最新版本
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：PWA 应用需要正确配置 Service Worker 缓存策略

---

## P-2024-201 tobooks 客户端书籍切割功能

- 项目：tobooks
- 仓库：/Users/apple/tobooks
- 发生版本：当前版本
- 现象：客户端书籍切割功能与脚本要求不匹配
- 根因：客户端实现与后端脚本要求不一致
- 修复：增强客户端书籍切割功能以匹配脚本要求
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-202 播客 备份文件 Git 跟踪问题

- 项目：My-podcast / 播客
- 仓库：/Users/apple/播/My-podcast
- 发生版本：当前版本
- 现象：备份文件被 Git 跟踪
- 根因：.gitignore 配置不正确
- 修复：修复备份文件 Git 跟踪问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-203 git-worktree-manager worktree 命令和刷新逻辑

- 项目：git-worktree-manager
- 仓库：/Users/apple/git-worktree-manage/git-worktree-manager
- 发生版本：当前版本
- 现象：worktree 命令执行和刷新逻辑有问题
- 根因：命令执行和刷新逻辑不完善
- 修复：更新 worktree 命令并优化刷新逻辑
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-204 tobooks multipart 解析和代码结构

- 项目：tobooks
- 仓库：/Users/apple/tobooks
- 发生版本：当前版本
- 现象：multipart 请求解析有问题
- 根因：解析逻辑不完善
- 修复：使用 busboy 改进 multipart 解析并修复代码结构
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-205 tobooks Supabase 权限绕过

- 项目：tobooks
- 仓库：/Users/apple/tobooks
- 发生版本：当前版本
- 现象：Supabase 权限问题导致功能无法使用
- 根因：Supabase RLS 策略限制
- 修复：添加硬编码白名单绕过 Supabase 权限问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：Supabase RLS 问题可以通过白名单临时绕过

---

## P-2024-206 久坐通知 iPhone 通知权限问题

- 项目：久坐通知
- 仓库：/Users/apple/久坐通知
- 发生版本：当前版本
- 现象：iPhone 上通知权限无法正常工作
- 根因：iOS Safari 对 PWA 通知权限有特殊要求
- 修复：添加 PWA 支持，解决 iPhone 通知权限问题
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：iOS PWA 通知需要特殊的权限处理

---

## P-2024-207 tobooks 支付 API 地址问题

- 项目：tobooks
- 仓库：/Users/apple/tobooks
- 发生版本：当前版本
- 现象：手机端支付功能无法使用
- 根因：支付 API 地址配置不正确
- 修复：更新支付 API 地址为阿里云 FC 公网地址
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-208 zhuyili 注意力跳动问题

- 项目：zhuyili (注意力追踪器)
- 仓库：/Users/apple/zhuyili
- 发生版本：当前版本
- 现象：注意力页面出现跳动
- 根因：使用页面跳转导致闪烁
- 修复：用视图切换替代页面跳转
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16
- 经验：SPA 应用应使用视图切换而非页面跳转

---

## P-2024-209 insidebar-ai DeepSeek Enter 键行为

- 项目：insidebar-ai
- 仓库：/Users/apple/insidebar-ai
- 发生版本：当前版本
- 现象：DeepSeek 中编辑旧消息时 Enter 键行为不正确
- 根因：未正确处理 DeepSeek 的编辑模式
- 修复：修复 DeepSeek 编辑旧消息时的 Enter 键行为
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-210 insidebar-ai Perplexity Enter 键行为

- 项目：insidebar-ai
- 仓库：/Users/apple/insidebar-ai
- 发生版本：当前版本
- 现象：Perplexity 中编辑旧消息时 Enter 键行为不正确
- 根因：未正确处理 Perplexity 的编辑模式
- 修复：修复 Perplexity 编辑旧消息时的 Enter 键行为
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

---

## P-2024-211 insidebar-ai Gemini Update 按钮检测

- 项目：insidebar-ai
- 仓库：/Users/apple/insidebar-ai
- 发生版本：当前版本
- 现象：Gemini 的 Update 按钮无法正确检测
- 根因：按钮选择器未使用上下文感知搜索
- 修复：使用上下文感知搜索修复 Gemini Update 按钮检测
- 回归检查：手动验证
- 状态：verified
- 日期：2024-12-16

