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

>>>>>>> 26d3c91 (feat: 添加 GitHub kexin94yyds 项目问题经验记录)
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

