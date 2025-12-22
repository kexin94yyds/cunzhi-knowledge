# 回归检查索引 (Regressions Registry)

> 记录所有回归检查，确保已修复的问题不会再次发生。

---

## 索引表

### 🖥️ 桌面应用 (Tauri/Electron)
| ID | 关联问题 | 名称 | 类型 |
|----|----------|------|------|
| R-2024-002 | P-2024-002 | WindowSwitcher 上下箭头切换窗口置顶 | 手工检查 |
| R-2024-003 | P-2024-003 | GUI 标题栏显示完整路径 | 手工检查 |
| R-2024-022 | P-2024-022 | iterate.app 更新后工具同步 | 脚本检查 |
| R-2024-052 | P-2024-052 | Shift+Tab 恢复窗口置顶顺序 | 手工检查 |
| R-2024-053 | P-2024-053 | 中文输入候选栏位置 | 手工检查 |

### 🔧 知识库与流程
| ID | 关联问题 | 名称 | 类型 |
|----|----------|------|------|
| R-2024-001 | P-2024-001 | 全局知识库流程验证 | 流程验证 |

### 🌐 Web/SaaS
| ID | 关联问题 | 名称 | 类型 |
|----|----------|------|------|
| R-2024-005 | P-2024-005 | Supabase RLS anon 角色权限 | 手工检查 |
| R-2024-051 | P-2024-051 | AI-Sidebar NotebookLM 标题捕获 | 手工检查 |

---

## 条目格式说明

每个回归检查应包含：
- **ID**: R-YYYY-NNN 格式
- **关联问题**: P-ID
- **类型**: unit / e2e / integration / 手工检查 / 脚本检查 / CI 验证 / 部署验证 / 流程验证
- **位置**: 测试文件路径（手工检查类填 N/A）
- **关键断言**: 检查的核心逻辑
- **运行方式**: 执行命令

---

## 详细记录

<!-- 新回归检查追加在此处 -->

## R-2024-022 iterate.app 更新后工具同步

- problem: P-2024-022
- type: script
- location: `update.sh`
- assertion: 
  1. 新增 MCP 工具后，运行 `./update.sh`
  2. 检查 `/Applications/iterate.app/Contents/MacOS/iterate` 的 MD5 与 `target/release/iterate` 相同
  3. 检查 `/Applications/iterate.app/Contents/MacOS/寸止` 的 MD5 与 `target/release/寸止` 相同
  4. 重启 iterate.app，确认新工具显示在工具列表中
- method: 
  ```bash
  md5 /Applications/iterate.app/Contents/MacOS/iterate target/release/iterate
  md5 /Applications/iterate.app/Contents/MacOS/寸止 target/release/寸止
  ```
- status: verified

---

## R-2024-001 全局知识库流程验证

- problem: P-2024-001
- type: process
- assertion: 全局知识库写入、提交、推送流程正常
- method: manual

---

## R-2024-002 WindowSwitcher 上下箭头切换窗口置顶

- problem: P-2024-002
- type: manual
- location: `src/frontend/components/common/WindowSwitcher.vue`
- assertion: 
  1. 打开多个 iterate 窗口并列显示
  2. 按 Tab 键打开窗口选择器
  3. 使用上下箭头切换选中行
  4. 每次切换时，对应窗口应实时置顶显示
- method: 手工测试验证
- 代码检查点：确保 `handleKeydown` 中 ArrowUp/ArrowDown 分支调用了 `activateWindowAtIndex(selectedIndex.value)`

---

## R-2024-003 GUI 标题栏显示完整路径

- problem: P-2024-003
- type: manual
- assertion: GUI 标题栏显示完整项目路径，可区分同名项目
- method: manual

---

## R-2024-005 Supabase RLS anon 角色权限

- problem: P-2024-005
- type: manual
- assertion: anon 角色可正常查询和更新密钥数据
- method: manual

---

## R-2024-051 AI-Sidebar NotebookLM 标题捕获失败

- problem: P-2024-051
- type: manual
- assertion: 
  1. 在 AI-Sidebar 中打开 NotebookLM 页面
  2. 收藏该页面
  3. 检查收藏标题是否显示实际项目名称（非 "NotebookLM" 或 "Untitled"）
- method: manual

---

## R-2024-052 Shift+Tab 恢复窗口时最后操作的窗口应置顶

- problem: P-2024-052
- type: manual
- assertion: 
  1. 打开多个 iterate 窗口 A、B
  2. 在窗口 A 按 Tab 最小化
  3. 在窗口 B 按 Tab 最小化
  4. 按 Shift+Tab 恢复所有窗口
  5. 窗口 B（最后最小化的）应在最上层获得焦点
- method: manual
- status: 待修复后验证（P-2024-052 状态为 open）

---

## R-2024-053 iterate 中文输入候选栏移位

- problem: P-2024-053
- type: manual
- assertion: 
  1. 打开 iterate 窗口
  2. 切换到中文输入法
  3. 拖动移动窗口位置
  4. 输入中文时候选栏应跟随窗口位置正确显示
- method: manual

---

## R-2024-054 iterate 首次启动缺少 config.json 导致主题异常

- problem: P-2024-054
- type: manual
- assertion: 
  1. 删除 config.json 文件模拟首次启动
  2. 启动应用
  3. 主题应正常显示（使用默认值）
- method: manual

---

## R-2024-055 iterate 多开时配置不同步

- problem: P-2024-055
- type: manual
- assertion: 
  1. 打开两个 iterate 实例
  2. 在实例 A 修改配置
  3. 切换到实例 B，焦点变化后配置应同步更新
- method: manual

---

## R-2024-056 iterate GitHub Actions 构建白屏

- problem: P-2024-056
- type: ci
- assertion: 
  1. 触发 GitHub Actions 构建
  2. 下载构建产物
  3. 启动应用，界面应正常显示（非白屏）
- method: ci

---

## R-2024-057 iterate pnpm 版本冲突

- problem: P-2024-057
- type: ci
- assertion: 
  1. GitHub Actions 中 pnpm 版本应从 package.json 自动读取
  2. CI 构建不应因版本冲突失败
- method: ci

---

## R-2024-058 信息过滤器 EPUB 封面提取失败

- problem: P-2024-058
- type: manual
- assertion: 
  1. 导入多种格式的 EPUB 书籍
  2. 检查封面是否正确显示
  3. 覆盖 meta cover-image、manifest、文件名匹配三种提取方式
- method: manual

---

## R-2024-059 信息过滤器 localStorage 超限

- problem: P-2024-059
- type: manual
- assertion: 
  1. 导入大量带封面的书籍
  2. 封面应被压缩存储
  3. localStorage 不应超限报错
- method: manual

---

## R-2024-060 tobooks Cmd+Enter 保存笔记无效

- problem: P-2024-060
- type: manual
- assertion: 
  1. 打开 tobooks 笔记编辑框
  2. 输入内容后按 Cmd+Enter
  3. 笔记应成功保存
- method: manual

---

## R-2024-061 tobooks 高亮功能导致内容消失

- problem: P-2024-061
- type: manual
- assertion: 
  1. 选中一段文本
  2. 添加高亮
  3. 文本内容应完整保留，不应消失
- method: manual

---

## R-2024-062 zhuyili 微信支付功能异常

- problem: P-2024-062
- type: manual
- assertion: 
  1. 点击购买按钮
  2. 应正确响应并进入支付流程
  3. 试用次数逻辑正常
- method: manual

---

## R-2024-063 zhuyili 二维码不显示

- problem: P-2024-063
- type: manual
- assertion: 
  1. 触发微信支付流程
  2. 支付二维码应正常显示
- method: manual

---

## R-2024-064 zhuyili OAuth 回调 URL 跳回本地

- problem: P-2024-064
- type: manual
- assertion: 
  1. 在生产环境点击 Google 登录
  2. 完成授权后应回调到正式域名
  3. 不应跳转到 localhost
- method: manual

---

## R-2024-065 视频侧边栏与视频未实时联动

- problem: P-2024-065
- type: manual
- assertion: 
  1. 打开带侧边栏的视频页面
  2. 调整视频大小或窗口大小
  3. 侧边栏应实时同步调整位置
- method: manual

---

## R-2024-066 视频侧边栏切换视频后字幕加载失败

- problem: P-2024-066
- type: manual
- assertion: 
  1. 在 YouTube 播放一个视频并加载字幕
  2. 切换到另一个视频
  3. 字幕应正常加载（首次即成功）
- method: manual

---

## R-2024-067 久坐通知 Service Worker 缓存问题

- problem: P-2024-067
- type: manual
- assertion: 
  1. 部署新版本应用
  2. 用户刷新页面
  3. 应获取最新版本（非缓存旧版本）
- method: manual

---

## R-2024-068 久坐通知 iPhone 通知权限问题

- problem: P-2024-068
- type: manual
- assertion: 
  1. 在 iPhone Safari 中打开应用
  2. 添加到主屏幕（安装 PWA）
  3. 授予通知权限后应能正常收到通知
- method: manual

---

## R-2024-069 网页看书目录按钮嵌套显示

- problem: P-2024-069
- type: manual
- assertion: 
  1. 点击目录按钮显示目录
  2. 再次点击目录按钮
  3. 目录应隐藏（非嵌套显示）
- method: manual

---

## R-2024-070 网页看书 Edge 浏览器兼容性问题

- problem: P-2024-070
- type: manual
- assertion: 
  1. 在 Edge 浏览器中打开应用
  2. 滚动和显示应正常
  3. 无 CSS 兼容性问题
- method: manual

---

## R-2024-111 ClipBook 删除时 bug

- problem: P-2024-111
- type: manual
- location: N/A
- assertion: 删除剪贴板项目时不出错，项目正确从列表中移除
- method: manual

---

## R-2024-112 ClipBook 初始状态 bug

- problem: P-2024-112
- type: manual
- location: N/A
- assertion: 应用启动时初始状态正常，骨架可拖拽
- method: manual

---

## R-2024-113 ClipBook HTML 和代码被忽略

- problem: P-2024-113
- type: manual
- location: N/A
- assertion: 复制 HTML 和代码时内容正确保存和显示
- method: manual

---

## R-2024-114 twscrape OTP 验证码问题

- problem: P-2024-114
- type: manual
- location: N/A
- assertion: OTP 验证码能正确解析和提交
- method: manual

---

## R-2024-115 twscrape 登录时无 ct0 cookie

- problem: P-2024-115
- type: manual
- location: N/A
- assertion: 登录时能正确获取 ct0 cookie，登录流程正常完成
- method: manual

---

## R-2024-116 twscrape 登录无限循环

- problem: P-2024-116
- type: manual
- location: N/A
- assertion: 使用不存在的账户登录时不会进入无限循环，正确报错
- method: manual

---

## R-2024-117 git-worktree-manager 翻译问题

- problem: P-2024-117
- type: manual
- location: N/A
- assertion: 界面翻译显示正确
- method: manual

---

## R-2024-118 git-worktree-manager worktree 事件监听

- problem: P-2024-118
- type: manual
- location: N/A
- assertion: worktree 变化时界面实时更新
- method: manual

---

## R-2024-119 git-worktree-manager 移动 worktree 问题

- problem: P-2024-119
- type: manual
- location: N/A
- assertion: 移动 worktree 操作正常完成，无报错
- method: manual

---

## R-2024-120 RI 开发版本无法访问原有数据

- problem: P-2024-120
- type: manual
- location: N/A
- assertion: 开发版本能正确访问默认数据目录中的原有数据
- method: manual

---

## R-2024-121 RI 文字颜色显示问题

- problem: P-2024-121
- type: manual
- location: N/A
- assertion: 文字颜色显示正确，切换模式时自动保存
- method: manual

---

## R-2024-122 RI 主窗口和笔记窗口在全屏应用前来回跳动

- problem: P-2024-122
- type: manual
- location: N/A
- assertion: 在 macOS 全屏应用环境下，主窗口和笔记窗口位置稳定不跳动
- method: manual

---

## R-2024-123 ClipBook 本地化 Help 菜单 bug

- problem: P-2024-123
- type: manual
- location: N/A
- assertion: Help tray menu 本地化显示正确
- method: manual

---

## R-2024-124 zhuyili 主页完成按钮需点两次

- problem: P-2024-124
- type: manual
- location: N/A
- assertion: 主页完成按钮点击一次即可生效，handleButtonAction 正确 await 异步操作
- method: manual

---

## R-2024-125 zhuyili 活动记录云端同步失败

- problem: P-2024-125
- type: manual
- location: N/A
- assertion: 活动记录能正确同步到云端
- method: manual

---

## R-2024-126 wechat-spider avatar 和 abstract 设置问题

- problem: P-2024-126
- type: manual
- location: N/A
- assertion: 头像和摘要显示正常，空值时正确处理
- method: manual

---

## R-2024-127 Strong-Iterate App 视图退出逻辑

- problem: P-2024-127
- type: manual
- location: N/A
- assertion: 关闭按钮能正确隐藏 apps-view
- method: manual

---

## R-2024-128 ClipBook 快捷键注册失败导致崩溃

- problem: P-2024-128
- type: manual
- location: N/A
- assertion: 快捷键注册失败时不崩溃，状态正确重置为空
- method: manual

---

## R-2024-129 ClipBook 显示/隐藏详情时崩溃

- problem: P-2024-129
- type: manual
- location: N/A
- assertion: 点击显示/隐藏详情按钮时不崩溃，状态正常切换
- method: manual

---

## R-2024-130 ClipBook 启动时崩溃

- problem: P-2024-130
- type: manual
- location: N/A
- assertion: 应用启动时不崩溃，正常初始化
- method: manual

---

## R-2024-091 Full-screen-prompt 图标格式错误

- problem: P-2024-091
- type: manual
- assertion: 应用图标正常显示，窗口边缘可拖拽
- method: manual

---

## R-2024-092 twscrape 部署问题

- problem: P-2024-092
- type: manual
- assertion: 部署后爬虫正常运行，实时爬取功能正常
- method: deploy

---

## R-2024-093 hack-airdrop Railway/Vercel 部署配置问题

- problem: P-2024-093
- type: manual
- assertion: Railway 端口配置正确，Vercel 部署成功
- method: deploy

---

## R-2024-094 Attention-Span 计时器暂停时间计算错误

- problem: P-2024-094
- type: manual
- assertion: 暂停计时器后恢复时，时间计算正确，暂停时间从总时间中正确扣除
- method: manual

---

## R-2024-095 Attention-Span 重复记录问题

- problem: P-2024-095
- type: manual
- assertion: 同一计时记录不会被重复保存，防抖机制生效
- method: manual

---

## R-2024-096 DDK 跑步愿望图片路径错误

- problem: P-2024-096
- type: manual
- assertion: 跑步愿望图片正常显示，路径引用正确
- method: manual

---

## R-2024-097 DDK 文字重叠问题

- problem: P-2024-097
- type: manual
- assertion: 页面文字无重叠，CSS 布局正常
- method: manual

---

## R-2024-098 编程网站中文引号语法错误

- problem: P-2024-098
- type: manual
- assertion: 代码中无中文引号，语法正确
- method: manual

---

## R-2024-099 aliyun-deploy Supabase URL 配置错误

- problem: P-2024-099
- type: manual
- assertion: 阿里云部署后 Supabase 连接成功，环境变量配置正确
- method: deploy

---

## R-2024-100 RI 多桌面/全屏 Space 窗口跳动

- problem: P-2024-100
- type: manual
- assertion: 在 macOS 多桌面或全屏 Space 环境下，窗口无跳动，清理启动脚本正常工作
- method: manual

---

## R-2024-101 Note-taking-tool 标题被 CSS 污染

- problem: P-2024-101
- type: manual
- assertion: 提取标题时跳过 style/script 标签，不包含 CSS 样式文本
- method: manual

---

## R-2024-102 Note-taking-tool 沉浸式翻译插件按钮重叠

- problem: P-2024-102
- type: manual
- assertion: 安装沉浸式翻译浏览器插件后，按钮无重叠
- method: manual

---

## R-2024-103 wechat-spider 保存图片到 OSS 问题

- problem: P-2024-103
- type: manual
- assertion: 图片正确保存到 OSS，上传逻辑正常
- method: manual

---

## R-2024-104 Strong-Iterate navBackButton 未定义

- problem: P-2024-104
- type: manual
- assertion: 点击关闭按钮无报错，navBackButton 变量已正确定义
- method: manual

---

## R-2024-105 Strong-Iterate Web/Crawler 视图退出逻辑

- problem: P-2024-105
- type: manual
- assertion: 关闭按钮正确隐藏 web-projects-view 和 crawlers-view
- method: manual

---

## R-2024-106 kotadb MCP tool schema localPath 参数问题

- problem: P-2024-106
- type: manual
- assertion: MCP tool schema 中无 localPath 参数，工具调用正常
- method: manual

---

## R-2024-107 Strong-Iterate HTML 语法错误

- problem: P-2024-107
- type: manual
- assertion: HTML 语法正确，页面渲染正常
- method: manual

---

## R-2024-108 tobooks text-to-epub 页面高度问题

- problem: P-2024-108
- type: manual
- assertion: text-to-epub.html 页面高度显示正确
- method: manual

---

## R-2024-109 播客 fs 变量重复声明

- problem: P-2024-109
- type: manual
- assertion: 启动无变量重复声明错误，fs 模块只声明一次
- method: manual

---

## R-2024-110 kexin-podcast DELETE API 参数类型问题

- problem: P-2024-110
- type: manual
- assertion: DELETE /api/podcasts/:id 接受数字 ID，API 幂等不返回 404
- method: manual

---

## R-2024-071 注意力追踪器计时器占位符闪烁

- problem: P-2024-071
- type: manual
- assertion: 计时器继续/暂停时数字占位符不闪烁，状态切换平滑无重绘
- method: manual

---

## R-2024-072 播客 Cloudinary 存储配置问题

- problem: P-2024-072
- type: manual
- assertion: 上传播客文件后能正确获取 Cloudinary URL，不回退到本地 /uploads 路径
- method: manual

---

## R-2024-073 背单词网页 YouTube 字幕获取失败

- problem: P-2024-073
- type: manual
- assertion: 能够通过 YouTube timedtext API 正确获取 WebVTT 格式字幕
- method: manual

---

## R-2024-074 时间追踪器 Enter 键跳转问题

- problem: P-2024-074
- type: manual
- assertion: 按 Enter 键能正确跳转到计时页面，无跳转条件冲突
- method: manual

---

## R-2024-075 Slash-Command-Prompter 模式切换后斜杠命令菜单不同步

- problem: P-2024-075
- type: manual
- assertion: 切换模式后，斜杠命令菜单显示当前选中模式的提示词，而非第一个模式
- method: manual

---

## R-2024-076 Slash-Command-Prompter 提示词上移仅在当前模式内有效

- problem: P-2024-076
- type: manual
- assertion: 提示词上移操作仅在当前模式内移动，不影响其他模式
- method: manual

---

## R-2024-077 微信公众号爬虫搜索失效

- problem: P-2024-077
- type: manual
- assertion: 搜索公众号功能正常，已适配微信新版接口
- method: manual

---

## R-2024-078 沉浸式写作页面跳动

- problem: P-2024-078
- type: manual
- assertion: 输入文字时页面不跳动，调整 textarea 高度时保持滚动位置
- method: manual

---

## R-2024-079 git-worktree-manager 路径解析错误

- problem: P-2024-079
- type: manual
- assertion: 在任意目录下执行命令时 git 路径正确解析，使用正确的 mainFolder
- method: manual

---

## R-2024-080 震动 App 数字输入双重输入

- problem: P-2024-080
- type: manual
- assertion: 数字输入框无双重输入问题，输入框之间无缝切换
- method: manual

---

## R-2024-081 ClipBook 退出时历史记录未清除

- problem: P-2024-081
- type: manual
- assertion: 退出应用时历史记录正确清除
- method: manual

---

## R-2024-082 看书神器下载文件名编码问题

- problem: P-2024-082
- type: manual
- assertion: 下载文件时中文文件名正确显示，无乱码
- method: manual

---

## R-2024-083 acemcp Google Antigravity MCP invalid trailing data 错误

- problem: P-2024-083
- type: manual
- assertion: 调用 Google Antigravity MCP 时无 "invalid trailing data" 错误，stdio 流使用 UTF-8 编码
- method: manual

---

## R-2024-084 RI 笔记功能多个关键问题

- problem: P-2024-084
- type: manual
- assertion: 
  1. 列表项编辑后使用 updateWord 正确保存
  2. 笔记导出按钮保存后主页自动刷新
- method: manual

---

## R-2024-085 Strong-Iterate 微信验证文件部署失败

- problem: P-2024-085
- type: manual
- assertion: 微信验证文件位于 public 文件夹，部署后可在网站根目录访问
- method: manual

---

## R-2024-086 笔记升级工具按钮大小不一致

- problem: P-2024-086
- type: manual
- assertion: 清理缓存按钮与其他按钮大小一致
- method: manual

---

## R-2024-087 codex-watcher 侧边栏重渲染后高亮丢失

- problem: P-2024-087
- type: manual
- assertion: 侧边栏重新渲染后，活动会话高亮状态保留，每个来源的最后打开状态恢复
- method: manual

---

## R-2024-088 codex-watcher DOMPurify 下展开/折叠失效

- problem: P-2024-088
- type: manual
- assertion: 使用 DOMPurify 后展开/折叠按钮点击有效，使用事件委托替代 inline onclick
- method: manual

---

## R-2024-089 kexin-podcast Render 部署 SQLite3 构建失败

- problem: P-2024-089
- type: deploy
- assertion: 部署到 Render 时 SQLite3 构建成功，包含必要的构建依赖
- method: deploy

---

## R-2024-090 Full-screen-prompt 删除功能异常

- problem: P-2024-090
- type: manual
- assertion: 删除提示词功能正常，自定义确认对话框工作正确
- method: manual

---

## R-2024-031 RI-Flow 快捷键不起作用

- problem: P-2024-031
- type: manual
- assertion: 确保应用运行、无快捷键冲突、重启后快捷键正常响应
- method: manual

---

## R-2024-032 YouTube-Transcript 侧边栏高度自适应问题

- problem: P-2024-032
- type: manual
- assertion: 侧边栏高度随视频页面自适应调整
- method: manual

---

## R-2024-033 Chrome 扩展历史记录不显示

- problem: P-2024-033
- type: manual
- assertion: 
  1. Chrome Storage 权限已授予
  2. 非隐私模式下历史记录正常显示
  3. 清除浏览器数据后重新记录
- method: manual

---

## R-2024-034 Chrome 扩展提供商加载失败

- problem: P-2024-034
- type: manual
- assertion: 清空缓存、重新加载扩展后，AI 提供商正常加载
- method: manual

---

## R-2024-035 Electron 桌面应用窗口无法显示

- problem: P-2024-035
- type: manual
- assertion: 
  1. 应用有辅助功能权限（系统偏好设置 → 安全性与隐私 → 辅助功能）
  2. 重启后窗口正常显示
- method: manual

---

## R-2024-036 Chrome 扩展数据本地存储安全说明

- problem: P-2024-036
- type: manual
- assertion: FAQ 中明确说明数据存储位置（本地浏览器，Attention Tracker 除外）
- method: 文档验证

---

## R-2024-037 EPUB 切书工具脚本权限问题

- problem: P-2024-037
- type: manual
- assertion: 首次运行自动设置权限或手动 `chmod +x 切书神技.zsh` 后正常执行
- method: manual

---

## R-2024-038 寸止 MCP 工具配置问题

- problem: P-2024-038
- type: manual
- assertion: 
  1. MCP 客户端配置正确：`{ "mcpServers": { "寸止": { "command": "寸止" } } }`
  2. 寸止命令在 PATH 中
  3. MCP 客户端成功连接
- method: manual

---

## R-2024-039 Slash-Command-Prompter 提示词上移跨模式问题

- problem: P-2024-039
- type: manual
- assertion: 提示词上移操作仅影响当前模式，不影响其他模式顺序
- method: manual

---

## R-2024-040 Slash-Command-Prompter 斜杠菜单误触发

- problem: P-2024-040
- type: manual
- assertion: 斜杠菜单仅在正确条件下触发，无误触发情况
- method: manual

---

## R-2024-041 Chrome 扩展删除模式丢失所有数据

- problem: P-2024-041
- type: manual
- assertion: 文档中明确说明"删除模式会同时删除该模式下的所有单词"
- method: 文档验证

---

## R-2024-042 Node.js 应用部署到静态托管平台失败

- problem: P-2024-042
- type: manual
- assertion: 文档说明 Node.js 应用需部署到支持后端的平台（Render/Railway/Vercel/Heroku）
- method: 文档验证

---

## R-2024-043 Web 应用震动功能在桌面端无效

- problem: P-2024-043
- type: manual
- assertion: 文档说明"震动功能需要设备支持，主要在移动设备上有效"
- method: 文档验证

---

## R-2024-044 Web 应用音频提示需要用户授权

- problem: P-2024-044
- type: manual
- assertion: 文档说明"音频提示功能需要用户授权"
- method: 文档验证

---

## R-2024-045 macOS 终端通知权限未授予

- problem: P-2024-045
- type: manual
- assertion: 系统偏好设置 → 通知与专注模式 → 终端有通知权限后，通知正常显示
- method: manual

---

## R-2024-046 macOS 语音功能未启用

- problem: P-2024-046
- type: manual
- assertion: 系统偏好设置 → 辅助功能 → 语音 → 启用后语音提示正常
- method: manual

---

## R-2024-047 Shell 配置未重新加载

- problem: P-2024-047
- type: manual
- assertion: `source ~/.zshrc` 或重启终端后，"开始"命令可用
- method: manual

---

## R-2024-048 12306 抢票脚本 ChromeDriver 版本问题

- problem: P-2024-048
- type: manual
- assertion: webdriver-manager 自动管理 ChromeDriver，脚本正常运行
- method: manual

---

## R-2024-049 12306 抢票脚本登录后页面卡住

- problem: P-2024-049
- type: manual
- assertion: 网络正常情况下，登录后页面不卡住
- method: manual

---

## R-2024-050 RI index.html 文件被意外清空

- problem: P-2024-050
- type: manual
- assertion: 
  1. index.html 文件内容完整
  2. 如被清空可通过 `git show HEAD:index.html > index.html` 恢复
- method: manual

---

## R-2024-007 笔记窗口 Cmd+B 加粗时画面跳动

- problem: P-2024-007
- type: manual
- assertion: 
  1. 打开笔记窗口，输入超过一屏的文字内容
  2. 选中中间位置的文字
  3. 按 Cmd+B 加粗选中文字
  4. 画面不应自动滚动，光标位置保持不变
- method: manual

---

## R-2024-023 Electron/macOS HTML5 拖拽被立即取消

- problem: P-2024-023
- type: manual
- assertion: 
  1. 在 macOS 上打开 RI 应用侧栏拖拽模式
  2. 拖拽侧栏项目进行排序
  3. 拖拽过程中应显示悬浮预览，而非被立即取消
  4. 拖拽完成后顺序正确更新
- method: manual

---

## R-2024-024 笔记内容因防抖机制丢失

- problem: P-2024-024
- type: manual
- assertion: 
  1. 上传图片后立即切换模式，图片应保留
  2. 输入文字后立即切换模式，文字应保留
  3. 窗口失去焦点时，内容应自动保存
  4. 关闭窗口前，内容应强制保存
- method: manual

---

## R-2024-025 IndexedDB 数据库锁定导致启动失败

- problem: P-2024-025
- type: manual
- assertion: 
  1. 应用正常启动，无 LevelDB LOCK 错误
  2. 若遇到锁定问题，`pkill -f "replace-information"` 可解决
- method: manual

---

## R-2024-026 IPC 事件语义混淆导致笔记内容串联

- problem: P-2024-026
- type: manual
- assertion: 
  1. 切换模式后，笔记内容应为当前模式的内容
  2. `modes-sync` 事件只同步列表，不改变当前状态
  3. 模式切换只通过 `mode-changed` 事件触发
- method: manual

---

## R-2024-027 AI-Sidebar 提供商登录页无法在 iframe 加载

- problem: P-2024-027
- type: manual
- assertion: 
  1. 打开 AI-Sidebar 侧边栏
  2. 选择 Gemini/Google 等需要登录的提供商
  3. 应显示 "Open in Tab" 按钮作为降级方案
  4. 点击后在新标签页中完成登录，侧边栏恢复正常
- method: manual

---

## R-2024-028 ChatGPT 403 错误

- problem: P-2024-028
- type: manual
- assertion: 
  1. 先在普通标签页打开 ChatGPT 完成初始检查
  2. 之后侧边栏可正常访问 ChatGPT
- method: manual

---

## R-2024-029 Chrome 扩展 Tab 键切换失效

- problem: P-2024-029
- type: manual
- assertion: 
  1. 确保侧边栏处于焦点状态
  2. 在侧边栏空白区域点击后按 Tab 键
  3. 应能正常切换提供商
- method: manual

---

## R-2024-030 久坐提醒 iPhone 后台推送失败

- problem: P-2024-030
- type: manual
- assertion: 
  1. iOS 版本 ≥ 16.4
  2. 通过"添加到主屏幕"安装 PWA
  3. 已授予通知权限
  4. 应用在后台运行时可收到推送
- method: manual

---

## R-2024-131 codex-watcher 本地 vendor 404/MIME 错误

- problem: P-2024-131
- type: manual
- location: N/A
- assertion: 
  1. 加载 codex-watcher 页面无 404 或 MIME 类型错误
  2. 仅使用 CDN 加载 vendor 资源
  3. 页面功能正常运行
- method: manual

---

## R-2024-132 git-worktree-manager getNameRev 错误处理

- problem: P-2024-132
- type: manual
- location: N/A
- assertion: 
  1. getNameRev 函数执行出错时不抛出未捕获异常
  2. 错误被正确处理并返回合理的默认值
- method: manual

---

## R-2024-133 git-worktree-manager worktree pruning 问题

- problem: P-2024-133
- type: manual
- location: N/A
- assertion: 
  1. git worktree prune 操作正确执行
  2. 无效的 worktree 被正确清理
  3. 有效的 worktree 不受影响
- method: manual

---

## R-2024-134 kexin-podcast JavaScript 变量重复声明

- problem: P-2024-134
- type: manual
- location: N/A
- assertion: 
  1. 应用启动时无变量重复声明错误
  2. 控制台无相关报错
- method: manual

---

## R-2024-135 Slash-Command-Prompter mode 下拉菜单对齐问题

- problem: P-2024-135
- type: manual
- location: N/A
- assertion: 
  1. mode 下拉菜单与其他 UI 元素对齐正确
  2. 按钮间距统一
- method: manual

---

## R-2024-136 tobooks 搜索栏和按钮重叠

- problem: P-2024-136
- type: manual
- location: N/A
- assertion: 
  1. 顶部栏搜索栏和按钮不重叠
  2. 调整窗口大小时布局保持正确
  3. CSS Grid 布局正常工作
- method: manual

---

## R-2024-137 zhuyili Google 登录回调 URL 问题

- problem: P-2024-137
- type: manual
- location: N/A
- assertion: 
  1. Google 登录后正确回调到应用
  2. 登录流程完整无错误
- method: manual

---

## R-2024-138 ClipBook 多文件选择时布局问题

- problem: P-2024-138
- type: manual
- location: N/A
- assertion: 
  1. 选择多个文件时布局显示正常
  2. 批量粘贴多个文件功能正常
- method: manual

---

## R-2024-139 ClipBook 通用布局问题

- problem: P-2024-139
- type: manual
- location: N/A
- assertion: 
  1. 界面布局显示正确
  2. 各组件位置和尺寸正常
- method: manual

---

## R-2024-140 ClipBook 图片标题问题

- problem: P-2024-140
- type: manual
- location: N/A
- assertion: 
  1. 图片标题正确显示
  2. 右键菜单命令正常工作
- method: manual

---

## R-2024-141 kotadb orchestrator 原子代理签名不匹配

- problem: P-2024-141
- type: manual
- location: N/A
- assertion: 
  1. orchestrator.py 中所有代理函数签名与调用一致
  2. 无签名不匹配错误
- method: manual

---

## R-2024-142 zhuyili 活动记录不同步核心问题

- problem: P-2024-142
- type: manual
- location: N/A
- assertion: 
  1. 活动记录在设备间正确同步
  2. 同步逻辑无延迟或数据丢失
- method: manual

---

## R-2024-143 ClipBook 检查更新时死锁

- problem: P-2024-143
- type: manual
- location: N/A
- assertion: 
  1. 检查更新时应用不卡死
  2. 更新检查正常完成
- method: manual

---

## R-2024-144 kotadb 数据库 rate limit 更新问题

- problem: P-2024-144
- type: manual
- location: N/A
- assertion: 
  1. 数据库中已有的 rate limit 可正确更新
  2. 更新后数据一致性正确
- method: manual

---

## R-2024-145 tobooks intro 按钮链接错误

- problem: P-2024-145
- type: manual
- location: N/A
- assertion: 
  1. intro 按钮点击后跳转到正确的 URL
- method: manual

---

## R-2024-146 tobooks OG/Twitter 图片域名问题

- problem: P-2024-146
- type: manual
- location: N/A
- assertion: 
  1. og:image 使用完整的 Netlify 域名
  2. twitter:image 使用完整的 Netlify 域名
  3. 社交分享预览图片正常显示
- method: manual

---

## R-2024-147 zhuyili 详情页按钮完全点不动

- problem: P-2024-147
- type: manual
- location: N/A
- assertion: 
  1. 计时器详情页面的按钮可正常点击
  2. 事件委托正确绑定
- method: manual

---

## R-2024-148 kotadb v0.1.1 生产环境回滚

- problem: P-2024-148
- type: manual
- location: N/A
- assertion: 
  1. 生产环境版本稳定运行
  2. 回滚后功能正常
- method: 生产环境验证

---

## R-2024-149 tobooks iOS 主屏独立模式扩展不可用

- problem: P-2024-149
- type: manual
- location: N/A
- assertion: 
  1. iOS standalone 模式下有适当的提示或降级方案
  2. 用户了解平台限制
- method: manual

---

## R-2024-150 git-worktree-manager worktree 列表处理重构问题

- problem: P-2024-150
- type: manual
- location: N/A
- assertion: 
  1. worktree 列表正确显示
  2. 列表操作（添加/删除/移动）正常工作
- method: manual

---

## R-2024-151 ClipBook 拼写错误

- problem: P-2024-151
- type: manual
- location: N/A
- assertion: 界面文本拼写正确
- method: manual

---

## R-2024-152 ClipBook 缺少依赖

- problem: P-2024-152
- type: manual
- location: N/A
- assertion: 应用正常启动和编译，无依赖缺失错误
- method: manual

---

## R-2024-153 ClipBook 预览面板边框缺失

- problem: P-2024-153
- type: manual
- location: N/A
- assertion: 预览面板边框正常显示
- method: manual

---

## R-2024-154 git-worktree-manager 国际化文本遗漏

- problem: P-2024-154
- type: manual
- location: N/A
- assertion: 所有界面文本正确翻译
- method: manual

---

## R-2024-155 iterate UnoCSS safelist 黑色变体问题

- problem: P-2024-155
- type: manual
- location: N/A
- assertion: 黑色相关 CSS 类正常生效
- method: manual

---

## R-2024-156 insidebar-ai Share 按钮布局不一致

- problem: P-2024-156
- type: manual
- location: N/A
- assertion: /chats/ 和 /pages/ 页面的 Share 按钮功能正常
- method: manual

---

## R-2024-157 codex-watcher indexer_test vet 错误

- problem: P-2024-157
- type: ci
- location: N/A
- assertion: go vet 无 indexer_test 相关错误
- method: ci

---

## R-2024-158 iterate 多开时配置不同步

- problem: P-2024-158
- type: manual
- location: N/A
- assertion: 多开应用时配置正确同步
- method: manual

---

## R-2024-159 zhuyili 生产环境 OAuth 回调跳回本地

- problem: P-2024-159
- type: manual
- location: N/A
- assertion: 生产环境 OAuth 回调到 Netlify 正式域名，无 "Cannot GET /" 错误
- method: manual

---

## R-2024-160 zhuyili 用户数据隔离和 JSON 导入同步

- problem: P-2024-160
- type: manual
- location: N/A
- assertion: 用户数据正确隔离，JSON 导入后数据同步
- method: manual

---

## R-2024-161 Strong-Iterate Netlify 部署 PNG/JPEG 扩展名问题

- problem: P-2024-161
- type: deploy
- location: N/A
- assertion: Netlify 部署后图片资源正常显示
- method: deploy

---

## R-2024-162 Strong-Iterate JS 文件 404 问题

- problem: P-2024-162
- type: deploy
- location: N/A
- assertion: 部署后 JS 文件正常加载
- method: deploy

---

## R-2024-163 iterate proc-macro 编译问题

- problem: P-2024-163
- type: ci
- location: N/A
- assertion: proc-macro 正常编译
- method: ci

---

## R-2024-164 twscrape 构建问题

- problem: P-2024-164
- type: ci
- location: N/A
- assertion: 项目正常构建
- method: ci

---

## R-2024-165 iterate 自定义 Telegram API URL 问题

- problem: P-2024-165
- type: manual
- location: N/A
- assertion: 自定义 Telegram API URL 功能完整，无硬编码 URL
- method: manual

---

## R-2024-166 tobooks /api/book-cutting 根路径访问问题

- problem: P-2024-166
- type: manual
- location: N/A
- assertion: /api/book-cutting 根路径可正常访问
- method: manual

---

## R-2024-167 zhuyili 二维码不显示

- problem: P-2024-167
- type: manual
- location: N/A
- assertion: 二维码正常显示
- method: manual

---

## R-2024-168 背单词网页 YouTube 字幕 API 问题

- problem: P-2024-168
- type: manual
- location: N/A
- assertion: YouTube 字幕通过 timedtext API 正常获取
- method: manual

---

## R-2024-169 codex-watcher 侧边栏高亮状态丢失

- problem: P-2024-169
- type: manual
- location: N/A
- assertion: 侧边栏重新渲染后活动会话高亮状态保留
- method: manual

---

## R-2024-170 Slash-Command-Prompter 模式切换后菜单同步问题

- problem: P-2024-170
- type: manual
- location: N/A
- assertion: 切换模式后斜杠命令菜单显示当前选中模式的提示词
- method: manual

---

## R-2024-171 tobooks 高亮菜单位置和文字加粗显示

- problem: P-2024-171
- type: manual
- location: N/A
- assertion: 高亮菜单位置正确，文字加粗正常显示
- method: manual

---

## R-2024-172 ClipBook 历史为空时拖拽区域 bug

- problem: P-2024-172
- type: manual
- location: N/A
- assertion: 历史记录为空时拖拽区域功能正常
- method: manual

---

## R-2024-173 ClipBook 深色/浅色模式滚动条问题

- problem: P-2024-173
- type: manual
- location: N/A
- assertion: 深色/浅色模式切换时滚动条样式正确
- method: manual

---

## R-2024-174 codex-watcher DOMPurify 下展开/折叠失效

- problem: P-2024-174
- type: manual
- location: N/A
- assertion: 使用事件委托后展开/折叠按钮点击有效
- method: manual

---

## R-2024-175 git-worktree-manager treeView 点击打开终端和文件夹

- problem: P-2024-175
- type: manual
- location: N/A
- assertion: 点击 treeView 可正常打开终端和文件夹
- method: manual

---

## R-2024-176 zhuyili 微信支付按钮点击事件绑定

- problem: P-2024-176
- type: manual
- location: N/A
- assertion: 微信支付购买按钮点击正常响应，试用次数逻辑正确
- method: manual

---

## R-2024-177 iterate 状态同步可能导致白屏

- problem: P-2024-177
- type: manual
- location: N/A
- assertion: 应用启动无白屏
- method: manual

---

## R-2024-178 kexin-podcast 本地 uploads 回退问题

- problem: P-2024-178
- type: manual
- location: N/A
- assertion: 部署后文件 URL 使用 Cloudinary，不回退到 /uploads
- method: manual

---

## R-2024-179 tobooks 高亮功能导致内容消失

- problem: P-2024-179
- type: manual
- location: N/A
- assertion: 使用高亮功能后内容不消失
- method: manual

---

## R-2024-180 ClipBook 随机窗口自动隐藏

- problem: P-2024-180
- type: manual
- location: N/A
- assertion: 应用窗口不会随机自动隐藏
- method: manual

---

## R-2024-181 ClipBook 活动应用为空时显示窗口问题

- problem: P-2024-181
- type: manual
- location: N/A
- assertion: 活动应用为空时显示窗口正常
- method: manual

---

## R-2024-182 iterate 移动窗口中文输入候选栏移位

- problem: P-2024-182
- type: manual
- location: N/A
- assertion: 移动窗口时中文输入法候选栏位置正确
- method: manual

---

## R-2024-183 tobooks Cmd+Enter 监听模式问题

- problem: P-2024-183
- type: manual
- location: N/A
- assertion: Cmd+Enter 快捷键正常生效
- method: manual

---

## R-2024-184 iterate 增强快捷键默认值问题

- problem: P-2024-184
- type: manual
- location: N/A
- assertion: 增强快捷键功能符合预期
- method: manual

---

## R-2024-185 git-worktree-manager 更新保存仓库时缓存未刷新

- problem: P-2024-185
- type: manual
- location: N/A
- assertion: 更新保存的仓库后数据正确刷新
- method: manual

---

## R-2024-186 tobooks Cmd+Enter 保存笔记无效

- problem: P-2024-186
- type: manual
- location: N/A
- assertion: 按 Cmd+Enter 保存笔记正常生效
- method: manual

---

## R-2024-187 ClipBook 路径问题

- problem: P-2024-187
- type: manual
- location: N/A
- assertion: 文件路径处理正确
- method: manual

---

## R-2024-188 git-worktree-manager git 路径解析

- problem: P-2024-188
- type: manual
- location: N/A
- assertion: execBase 函数中 git 路径解析正确
- method: manual

---

## R-2024-189 twscrape 解析链接计数问题

- problem: P-2024-189
- type: manual
- location: N/A
- assertion: 解析的链接计数正确
- method: manual

---

## R-2024-190 twscrape 用户资料中的 URL 问题

- problem: P-2024-190
- type: manual
- location: N/A
- assertion: 用户资料中的 URL 解析正确
- method: manual

---

## R-2024-191 tobooks 高亮加载错误处理

- problem: P-2024-191
- type: manual
- location: N/A
- assertion: 高亮加载失败时有正确的错误处理
- method: manual

---

## R-2024-192 zhuyili 主页完成按钮首次点击即生效

- problem: P-2024-192
- type: manual
- location: N/A
- assertion: 完成按钮首次点击即保存和重置
- method: manual

---

## R-2024-193 kotadb 管理账单按钮不可用

- problem: P-2024-193
- type: manual
- location: N/A
- assertion: 管理账单按钮点击正常响应
- method: manual

---

## R-2024-194 kotadb API 密钥页面自动获取

- problem: P-2024-194
- type: manual
- location: N/A
- assertion: API 密钥页面加载时自动获取已有密钥
- method: manual

---

## R-2024-195 git-worktree-manager 视图条件和收藏操作

- problem: P-2024-195
- type: manual
- location: N/A
- assertion: 视图条件判断正确，收藏相关操作正常
- method: manual

---

## R-2024-196 iterate 重复 applyFontVariables 函数

- problem: P-2024-196
- type: manual
- location: N/A
- assertion: 代码中无重复函数定义
- method: manual

---

## R-2024-197 iterate Windows 路径编码问题

- problem: P-2024-197
- type: manual
- location: N/A
- assertion: Windows 系统上 memory 功能路径编码正确
- method: manual

---

## R-2024-198 zhuyili 计时页面图标显示问题

- problem: P-2024-198
- type: manual
- location: N/A
- assertion: 计时页面图标正常显示
- method: manual

---

## R-2024-199 zhuyili 移动端标题被遮挡

- problem: P-2024-199
- type: manual
- location: N/A
- assertion: 移动端标题显示不被遮挡
- method: manual

---

## R-2024-200 久坐通知 Service Worker 缓存问题

- problem: P-2024-200
- type: manual
- location: N/A
- assertion: 应用可获取最新版本（网络优先策略）
- method: manual

---

## R-2024-201 tobooks 客户端书籍切割功能

- problem: P-2024-201
- type: manual
- location: N/A
- assertion: 客户端书籍切割功能与脚本要求匹配
- method: manual

---

## R-2024-202 播客 备份文件 Git 跟踪问题

- problem: P-2024-202
- type: manual
- location: N/A
- assertion: 备份文件不被 Git 跟踪
- method: manual

---

## R-2024-203 git-worktree-manager worktree 命令和刷新逻辑

- problem: P-2024-203
- type: manual
- location: N/A
- assertion: worktree 命令执行和刷新逻辑正常
- method: manual

---

## R-2024-204 tobooks multipart 解析和代码结构

- problem: P-2024-204
- type: manual
- location: N/A
- assertion: multipart 请求解析正常（使用 busboy）
- method: manual

---

## R-2024-205 tobooks Supabase 权限绕过

- problem: P-2024-205
- type: manual
- location: N/A
- assertion: 通过白名单绕过 Supabase 权限问题
- method: manual

---

## R-2024-206 久坐通知 iPhone 通知权限问题

- problem: P-2024-206
- type: manual
- location: N/A
- assertion: iPhone 上 PWA 通知权限正常工作
- method: manual

---

## R-2024-207 tobooks 支付 API 地址问题

- problem: P-2024-207
- type: manual
- location: N/A
- assertion: 手机端支付功能正常（使用阿里云 FC 公网地址）
- method: manual

---

## R-2024-208 zhuyili 注意力跳动问题

- problem: P-2024-208
- type: manual
- location: N/A
- assertion: 注意力页面使用视图切换，无跳动
- method: manual

---

## R-2024-209 insidebar-ai DeepSeek Enter 键行为

- problem: P-2024-209
- type: manual
- location: N/A
- assertion: DeepSeek 编辑旧消息时 Enter 键行为正确
- method: manual

---

## R-2024-210 insidebar-ai Perplexity Enter 键行为

- problem: P-2024-210
- type: manual
- location: N/A
- assertion: Perplexity 编辑旧消息时 Enter 键行为正确
- method: manual

---

## R-2024-211 insidebar-ai Gemini Update 按钮检测

- problem: P-2024-211
- type: manual
- location: N/A
- assertion: Gemini 的 Update 按钮可正确检测
- method: manual

---

## R-2024-212 Full-screen-prompt 多桌面/全屏 Space 窗口跳动

- problem: P-2024-212
- type: manual
- location: N/A
- assertion: 多桌面/全屏 Space 下窗口不跳回固定桌面
- method: manual

---

## R-2024-213 kexin-podcast 上传时 filename 为空

- problem: P-2024-213
- type: manual
- location: N/A
- assertion: 上传文件时 filename 不为空，无数据库约束错误
- method: manual

---

## R-2024-214 twscrape 媒体类型问题

- problem: P-2024-214
- type: manual
- location: N/A
- assertion: 媒体类型解析正确
- method: manual

---

## R-2024-215 tobooks 白名单 site 字段过滤不匹配

- problem: P-2024-215
- type: manual
- location: N/A
- assertion: 白名单检查时 site 字段过滤正确匹配
- method: manual

---

## R-2024-216 Full-screen-prompt 复制到剪贴板功能

- problem: P-2024-216
- type: manual
- location: N/A
- assertion: 点击提示词可正确复制到剪贴板
- method: manual

---

## R-2024-217 wechat-spider 微信改版搜索公众号失效

- problem: P-2024-217
- type: manual
- location: N/A
- assertion: 搜索公众号功能正常（适配微信改版）
- method: manual

---

## R-2024-218 RI 排序问题

- problem: P-2024-218
- type: manual
- location: N/A
- assertion: 最新保存的内容显示在列表顶部
- method: manual

---

## R-2024-219 RI 笔记保存功能迁移到 IndexedDB

- problem: P-2024-219
- type: manual
- location: N/A
- assertion: note-window.js 笔记保存功能使用 IndexedDB
- method: manual

---

## R-2024-220 insidebar-ai 性能和验证问题

- problem: P-2024-220
- type: manual
- location: N/A
- assertion: 代码审计发现的性能和验证问题已修复
- method: manual

---

## R-2024-221 git-worktree-manager URI 处理问题

- problem: P-2024-221
- type: manual
- location: N/A
- assertion: worktree 路径使用 Uri.parse 正确处理
- method: manual

---

## R-2024-222 tobooks Vercel 部署 ES6 模块格式

- problem: P-2024-222
- type: deploy
- location: N/A
- assertion: book-cutting.js 使用 ES6 模块格式，Vercel 部署成功
- method: deploy

---

## R-2024-223 tobooks Vercel serverless 函数导出和 CORS

- problem: P-2024-223
- type: deploy
- location: N/A
- assertion: Vercel serverless 函数导出格式和 CORS 设置正确
- method: deploy

---

## R-2024-224 zhuyili JSON 导入日期格式问题

- problem: P-2024-224
- type: manual
- location: N/A
- assertion: JSON 导入时日期格式解析正确
- method: manual

---

## R-2024-225 ClipBook 启动时崩溃

- problem: P-2024-225
- type: manual
- location: N/A
- assertion: 应用正常启动，不崩溃
- method: manual

---

## R-2024-226 git-worktree-manager worktree 进程移除

- problem: P-2024-226
- type: manual
- location: N/A
- assertion: worktree 进程移除正确
- method: manual

---

## R-2024-227 tobooks 高亮菜单遮挡内容

- problem: P-2024-227
- type: manual
- location: N/A
- assertion: 高亮菜单显示在选中文字下方，不遮挡内容
- method: manual

---

## R-2024-228 ClipBook bundle 提取应用名崩溃

- problem: P-2024-228
- type: manual
- location: N/A
- assertion: 从 bundle 提取应用名时不崩溃
- method: manual

---

## R-2024-229 iterate 只构建 CLI 避免打包问题

- problem: P-2024-229
- type: ci
- location: N/A
- assertion: 只构建 CLI 二进制文件，无打包问题
- method: ci

---

## R-2024-230 iterate Windows icon.ico 缺失

- problem: P-2024-230
- type: ci
- location: N/A
- assertion: Windows 构建成功，icon.ico 存在
- method: ci

---

## R-2024-231 背单词网页 Vite base path 问题

- problem: P-2024-231
- type: deploy
- location: N/A
- assertion: Netlify 根目录部署时资源路径正确
- method: deploy

---

## R-2024-232 Strong-Iterate script 标签缺少 type=module

- problem: P-2024-232
- type: deploy
- location: N/A
- assertion: Vite 打包后 JS 正常执行（有 type=module）
- method: deploy

---

## R-2024-233 ClipBook CSS 颜色值为空时崩溃

- problem: P-2024-233
- type: manual
- location: N/A
- assertion: CSS 颜色值为空时应用不崩溃
- method: manual

---

## R-2024-234 Strong-Iterate 刷新后样式重置

- problem: P-2024-234
- type: deploy
- location: N/A
- assertion: 页面刷新后样式保持不变
- method: deploy

---

## R-2024-235 tobooks CORS 预检请求问题

- problem: P-2024-235
- type: deploy
- location: N/A
- assertion: 跨域请求正常工作，预检请求正确处理
- method: deploy

---

## R-2024-236 tobooks CDN 加载 Turndown 库问题

- problem: P-2024-236
- type: deploy
- location: N/A
- assertion: 本地 Turndown 库正常加载
- method: deploy

---

## R-2024-237 tobooks 移动端双击手势兼容性

- problem: P-2024-237
- type: manual
- location: N/A
- assertion: 移动端双击触发翻译扩展，单击触发翻页
- method: manual

---

## R-2024-238 zhuyili 计时器继续/暂停时占位符闪烁

- problem: P-2024-238
- type: manual
- location: N/A
- assertion: 计时器继续/暂停时 UI 平滑无闪烁
- method: manual

---

## R-2024-239 insidebar-ai 语言切换需要重新加载

- problem: P-2024-239
- type: manual
- location: N/A
- assertion: 语言切换后立即生效，无需重新加载
- method: manual

---

## R-2024-240 kotadb Docker 构建 shared types 问题

- problem: P-2024-240
- type: ci
- location: N/A
- assertion: Docker 构建时 shared types 正确解析
- method: ci

---

## R-2024-241 视频侧边栏 视频与侧边栏实时联动

- problem: P-2024-241
- type: manual
- location: N/A
- assertion: 视频与侧边栏实时同步联动
- method: manual

---

## R-2024-242 insidebar-ai Google AI Mode 重复检测

- problem: P-2024-242
- type: manual
- location: N/A
- assertion: Google AI Mode 重复检测和消息提取正常
- method: manual

---

## R-2024-243 播客 数据持久化问题

- problem: P-2024-243
- type: manual
- location: N/A
- assertion: 数据正确持久化
- method: manual

---

## R-2024-244 Full-screen-prompt Perplexity Slate 编辑器插入

- problem: P-2024-244
- type: manual
- location: N/A
- assertion: Perplexity Slate 编辑器中 Enter/点击插入可靠，无重复菜单
- method: manual

---

## R-2024-245 tobooks 笔记关联到整个高亮

- problem: P-2024-245
- type: manual
- location: N/A
- assertion: 选中已高亮文本的局部部分时，笔记关联到整个高亮
- method: manual

---

## R-2024-246 zhuyili 活动记录云端同步失败

- problem: P-2024-246
- type: manual
- location: N/A
- assertion: 活动记录云端同步正常
- method: manual

---

## R-2024-247 kotadb 域名错误

- problem: P-2024-247
- type: manual
- location: N/A
- assertion: 域名正确使用 kotadb.io
- method: manual

---

## R-2024-248 tobooks vercel.json 缺失 /upload-url 路由

- problem: P-2024-248
- type: deploy
- location: N/A
- assertion: /upload-url 路由正常访问
- method: deploy

---

## R-2024-249 zhuyili Enter 键跳转问题

- problem: P-2024-249
- type: manual
- location: N/A
- assertion: Enter 键正确跳转到计时页面
- method: manual

---

## R-2024-250 zhuyili Google 登录重定向问题

- problem: P-2024-250
- type: manual
- location: N/A
- assertion: Google 登录后正确重定向
- method: manual

---

## R-2024-251 信息过滤器 App 导出 JSON 格式兼容

- problem: P-2024-251
- type: manual
- location: N/A
- assertion: 
  1. App 导出的纯数组 JSON 格式能正确导入
  2. 导入后数据完整显示
- method: manual

---

## R-2024-252 ClipBook 对话框透明度问题

- problem: P-2024-252
- type: manual
- location: N/A
- assertion: 对话框透明度显示正确
- method: manual

---

## R-2024-253 kexin-podcast DELETE 接口 ID 类型问题

- problem: P-2024-253
- type: integration
- location: N/A
- assertion: 
  1. DELETE /api/podcasts/:id 接受数字 ID
  2. API 幂等，不返回 404
- method: API 测试验证

---

## R-2024-254 播客 备份文件 Git 跟踪问题

- problem: P-2024-254
- type: manual
- location: N/A
- assertion: 备份文件不被 Git 跟踪，.gitignore 配置正确
- method: manual

---

## R-2024-255 ClipBook 搜索意外获取焦点

- problem: P-2024-255
- type: manual
- location: N/A
- assertion: 搜索框不会意外获取焦点，焦点管理正常
- method: manual

---

## R-2024-256 iterate 重复 applyFontVariables 函数

- problem: P-2024-256
- type: ci
- location: N/A
- assertion: 代码中无重复的 applyFontVariables 函数，编译正常
- method: 编译验证

---

## R-2024-257 zhuyili 微信支付购买按钮事件绑定

- problem: P-2024-257
- type: manual
- location: N/A
- assertion: 
  1. 购买按钮点击有响应
  2. 试用次数逻辑正常
- method: manual

---

## R-2024-258 久坐通知 Service Worker 缓存问题

- problem: P-2024-258
- type: manual
- location: N/A
- assertion: 
  1. 部署新版本应用
  2. 刷新页面后应获取最新版本
  3. 网络优先策略生效
- method: manual

---

## R-2024-259 RI 列表项编辑后保存问题

- problem: P-2024-259
- type: manual
- location: N/A
- assertion: 
  1. 编辑列表项内容
  2. 内容应正确保存（使用 updateWord）
  3. 刷新后编辑内容保留
- method: manual

---

## R-2024-260 insidebar-ai ES6 模块导入错误

- problem: P-2024-260
- type: manual
- location: N/A
- assertion: 
  1. 加载应用无模块导入错误
  2. 全局命名空间方式正常工作
- method: manual

---

## R-2024-261 ClipBook 辅助功能访问检查时粘贴为空

- problem: P-2024-261
- type: manual
- location: N/A
- assertion: 
  1. 检查辅助功能访问权限时
  2. 粘贴内容不为空
  3. 权限检查逻辑正常
- method: manual

---

## R-2024-262 zhuyili Supabase 客户端访问方式

- problem: P-2024-262
- type: manual
- location: N/A
- assertion: 
  1. Supabase 客户端正确初始化
  2. 数据访问正常
- method: manual

---

## R-2024-263 git-worktree-manager push/pull 未触发 git hook

- problem: P-2024-263
- type: manual
- location: N/A
- assertion: 
  1. 执行 push 操作时 git hook 被触发
  2. 执行 pull 操作时 git hook 被触发
- method: manual

---

## R-2024-264 RI 导入/清空后模式跳转问题

- problem: P-2024-264
- type: manual
- location: N/A
- assertion: 
  1. 导入数据后模式正确跳转
  2. 清空数据后模式正确跳转
  3. 状态更新后模式切换正常
- method: manual

---

## R-2024-265 RI 通知图标路径问题

- problem: P-2024-265
- type: manual
- location: N/A
- assertion: 通知图标正常显示，使用 RI.png 替代已删除的信息置换.png
- method: manual

---

## R-2024-266 ClipBook Actions 弹窗高度问题

- problem: P-2024-266
- type: manual
- location: N/A
- assertion: Actions 弹窗高度正确显示
- method: manual

---

## R-2024-267 ClipBook 滚动问题

- problem: P-2024-267
- type: manual
- location: N/A
- assertion: 列表滚动正常，无卡顿或异常
- method: manual

---

## R-2024-268 tobooks text-to-epub 页面高度问题

- problem: P-2024-268
- type: manual
- location: N/A
- assertion: text-to-epub.html 页面高度正确显示
- method: manual

---

## R-2024-269 zen-flow 页面跳动问题

- problem: P-2024-269
- type: manual
- location: N/A
- assertion: 调整 textarea 高度时页面不跳动，滚动位置保持稳定
- method: manual

---

## R-2024-270 视频侧边栏 视频与侧边栏自适应联动

- problem: P-2024-270
- type: manual
- location: N/A
- assertion: 视频与侧边栏实时自适应联动，尺寸变化时同步调整
- method: manual

---

## R-2024-004 窗口切换器点击第二行无法激活对应窗口

- problem: P-2024-004
- type: manual
- location: N/A
- assertion: 点击窗口切换器任意行时，正确激活对应窗口
- method: manual
- status: 待验证（问题 open）

---

## R-2024-006 Acemcp 无法获取 Augment API 凭证

- problem: P-2024-006
- type: network
- location: N/A
- assertion: `auggie login` 成功完成 hCaptcha 验证并获取凭证
- method: manual
- status: 待验证（问题 open）

---

## R-2024-271 ClipBook 深色/浅色模式滚动条

- problem: P-2024-271
- type: manual
- location: N/A
- assertion: 
  1. 深色模式下滚动条样式正确
  2. 浅色模式下滚动条样式正确
  3. 切换主题时滚动条样式跟随变化
- method: manual

---

## R-2024-272 zhuyili 统计图表颜色显示

- problem: P-2024-272
- type: manual
- location: N/A
- assertion: 
  1. 统计图表颜色显示正确
  2. combined.js 颜色算法与主应用同步
- method: manual

---

## R-2024-289 relax Netlify 构建错误

- problem: P-2024-273
- type: deploy
- location: N/A
- assertion: Netlify 构建成功，audioContext 依赖正确声明
- method: deploy

---

## R-2024-290 relax ESLint 错误

- problem: P-2024-274
- type: manual
- location: N/A
- assertion: ESLint 检查通过，无依赖数组警告
- method: `npm run lint`

---

## R-2024-291 relax 声音开关功能异常

- problem: P-2024-275
- type: manual
- location: N/A
- assertion: 声音开关功能正常，切换时音频响应正确
- method: manual

---

## R-2024-292 hack-airdrop Railway 端口配置错误

- problem: P-2024-276
- type: deploy
- location: N/A
- assertion: Railway 部署后应用可正常访问
- method: deploy

---

## R-2024-293 hack-airdrop Railway 部署配置问题

- problem: P-2024-277
- type: deploy
- location: N/A
- assertion: Railway 部署成功
- method: deploy

---

## R-2024-294 hack-airdrop Vercel 部署配置问题

- problem: P-2024-278
- type: deploy
- location: N/A
- assertion: Vercel 部署成功，Railway 支持正常
- method: deploy

---

## R-2024-295 hack-airdrop Vercel 部署配置问题 (第二次)

- problem: P-2024-279
- type: deploy
- location: N/A
- assertion: Vercel 部署完全正常
- method: deploy

---

## R-2024-296 program-lesson 中文引号语法错误

- problem: P-2024-280
- type: manual
- location: N/A
- assertion: 代码中无中文引号，语法正确
- method: 代码审查

---

## R-2024-297 PixelTunePhoto 移动端响应式布局问题

- problem: P-2024-281
- type: manual
- location: N/A
- assertion: 移动端布局正确，workspace 和 sidebar 垂直堆叠
- method: 移动端测试

---

## R-2024-298 memory-english YouTube 字幕获取失败

- problem: P-2024-282
- type: manual
- location: N/A
- assertion: 能正确获取 YouTube 字幕 WebVTT 格式
- method: manual

---

## R-2024-299 memory-english YouTube Transcript API 失效

- problem: P-2024-283
- type: manual
- location: N/A
- assertion: YouTube timedtext API 正常获取字幕
- method: manual

---

## R-2024-300 memory-english Netlify 部署路径问题

- problem: P-2024-284
- type: deploy
- location: N/A
- assertion: Netlify 部署后资源路径正确，页面正常显示
- method: deploy

---

## R-2024-301 me-h (DDK) HTML 语法错误

- problem: P-2024-285
- type: manual
- location: N/A
- assertion: HTML 语法正确，章节内容正常显示
- method: manual

---

## R-2024-302 me-h (DDK) 18 岁生日礼物 HTML 错误

- problem: P-2024-286
- type: manual
- location: N/A
- assertion: 18 岁生日礼物页面正常显示
- method: manual

---

## R-2024-303 me-h (DDK) Netlify 部署 PNG/JPEG 扩展名问题

- problem: P-2024-287
- type: deploy
- location: N/A
- assertion: Netlify 部署后 PNG/JPEG 图片正常显示
- method: deploy

---

## R-2024-304 me-h (DDK) 图片引用路径错误

- problem: P-2024-288
- type: manual
- location: N/A
- assertion: 图片使用 import 引用，打包后正常显示
- method: manual

---

## R-2024-321 me-h (DDK) JS 文件 404 问题

- problem: P-2024-289
- type: deploy
- location: N/A
- assertion: JS 文件正常加载，无 404 错误
- method: deploy

---

## R-2024-322 me-h (DDK) Vite 打包 script 问题

- problem: P-2024-290
- type: deploy
- location: N/A
- assertion: Vite 打包后脚本正常执行
- method: deploy

---

## R-2024-323 me-h (DDK) Netlify 部署白屏

- problem: P-2024-291
- type: deploy
- location: N/A
- assertion: Netlify 部署后页面正常显示，无白屏
- method: deploy

---

## R-2024-324 me-h (DDK) 跑步愿望图片路径错误

- problem: P-2024-292
- type: manual
- location: N/A
- assertion: 跑步愿望图片正常显示
- method: manual

---

## R-2024-325 me-h (DDK) 文字重叠问题

- problem: P-2024-293
- type: manual
- location: N/A
- assertion: 页面文字无重叠，布局正常
- method: manual

---

## R-2024-326 Note-taking-tool 标题被 CSS 污染

- problem: P-2024-294
- type: manual
- location: N/A
- assertion: 提取标题时跳过 style/script 标签，标题干净无 CSS 污染
- method: manual

---

## R-2024-273 flow-learning 下载书籍文件名问题

- problem: P-2024-273
- type: manual
- location: N/A
- assertion: 下载书籍时文件名为原始文件名
- method: manual

---

## R-2024-274 flow-learning 批量上传同步 Supabase

- problem: P-2024-274
- type: manual
- location: N/A
- assertion: 批量上传书籍时同步到 Supabase，fileUrl 正确保存
- method: manual

---

## R-2024-275 flow-learning Supabase InvalidKey 错误

- problem: P-2024-275
- type: manual
- location: N/A
- assertion: 上传含特殊字符文件名的文件时无 InvalidKey 错误
- method: manual

---

## R-2024-276 flow-learning 书籍点击使用云端链接

- problem: P-2024-276
- type: manual
- location: N/A
- assertion: 点击书籍时优先使用云端 fileUrl 链接
- method: manual

---

## R-2024-277 flow-learning 导入 App JSON 格式

- problem: P-2024-277
- type: manual
- location: N/A
- assertion: 能正确导入 App 导出的纯数组 JSON 格式文件
- method: manual

---

## R-2024-278 flow-learning 导入按钮可见

- problem: P-2024-278
- type: manual
- location: N/A
- assertion: 导入按钮正常显示可见
- method: manual

---

## R-2024-279 Full-screen-prompt 多桌面窗口跳回

- problem: P-2024-279
- type: manual
- location: N/A
- assertion: 在多桌面/全屏 Space 环境下窗口不跳回固定桌面
- method: manual

---

## R-2024-280 Full-screen-prompt 点击复制提示词

- problem: P-2024-280
- type: manual
- location: N/A
- assertion: 点击提示词能正确复制到剪切板
- method: manual

---

## R-2024-281 Full-screen-prompt Perplexity 编辑器插入

- problem: P-2024-281
- type: manual
- location: N/A
- assertion: 在 Perplexity Slate 编辑器中插入提示词可靠工作
- method: manual

---

## R-2024-282 if-compond 授权弹窗邮箱预填充

- problem: P-2024-282
- type: manual
- location: N/A
- assertion: 打开授权弹窗时邮箱自动预填充
- method: manual

---

## R-2024-283 if-compond 缓存数量检查

- problem: P-2024-283
- type: manual
- location: N/A
- assertion: 只有缓存数量足够时才使用缓存
- method: manual

---

## R-2024-284 if-compond 在线密钥验证

- problem: P-2024-284
- type: manual
- location: N/A
- assertion: 启用在线密钥验证，伪造密钥无法通过
- method: manual

---

## R-2024-285 if-compond 生产环境 User-Agent

- problem: P-2024-285
- type: manual
- location: N/A
- assertion: 生产环境请求包含 User-Agent header，不被拒绝
- method: manual

---

## R-2024-286 if-compond fetch 策略

- problem: P-2024-286
- type: manual
- location: N/A
- assertion: 生产环境使用直接 fetch，本地开发使用代理，两者均正常工作
- method: manual

---

## R-2024-319 me-h (DDK) Netlify 部署白屏及多项问题

- problem: P-2024-273
- type: deploy
- location: N/A
- assertion: 
  1. Netlify 部署后页面正常显示（非白屏）
  2. JS 文件加载成功（无 404）
  3. 图片正常显示
  4. HTML 章节内容完整渲染
- method: deploy

---

## R-2024-320 PixelTunePhoto 移动端响应式布局问题

- problem: P-2024-274
- type: manual
- location: N/A
- assertion: 
  1. 移动端访问时 workspace 和 sidebar 垂直堆叠
  2. 布局不拥挤，可正常操作
- method: manual（使用浏览器开发者工具模拟移动端）

---

## R-2024-305 crawl-Twitter 代理端口和账户锁定问题

- problem: P-2024-275
- type: manual
- location: N/A
- assertion: 
  1. 代理端口配置正确
  2. 账户登录后不被锁定
  3. 请求频率在合理范围内
- method: manual

---

## R-2024-306 flow-learning EPUB 封面提取失败

- problem: P-2024-276
- type: manual
- location: N/A
- assertion: 
  1. 导入多种格式的 EPUB 书籍
  2. 封面正确显示
  3. 覆盖 meta cover-image、manifest、文件名匹配三种提取方式
- method: manual

---

## R-2024-307 flow-learning localStorage 超限

- problem: P-2024-277
- type: manual
- location: N/A
- assertion: 
  1. 导入大量带封面的书籍
  2. 封面被压缩存储
  3. localStorage 不超限报错
- method: manual

---

## R-2024-308 flow-learning 下载书籍文件名问题

- problem: P-2024-278
- type: manual
- location: N/A
- assertion: 下载书籍时使用原始文件名
- method: manual

---

## R-2024-309 flow-learning 批量上传未同步到 Supabase

- problem: P-2024-279
- type: manual
- location: N/A
- assertion: 
  1. 批量上传书籍
  2. 数据同步到 Supabase
  3. fileUrl 正确保存
- method: manual

---

## R-2024-310 flow-learning Supabase InvalidKey 错误

- problem: P-2024-280
- type: manual
- location: N/A
- assertion: 上传包含特殊字符文件名的文件时无 InvalidKey 错误
- method: manual

---

## R-2024-311 flow-learning Supabase anon key 过期

- problem: P-2024-281
- type: manual
- location: N/A
- assertion: Supabase 连接正常，anon key 有效
- method: manual

---

## R-2024-312 flow-learning 书籍点击链接问题

- problem: P-2024-282
- type: manual
- location: N/A
- assertion: 
  1. 点击书籍时使用云端链接
  2. 拖拽状态基于 fileUrl 正确判断
- method: manual

---

## R-2024-313 flow-learning 导入 JSON 格式兼容问题

- problem: P-2024-283
- type: manual
- location: N/A
- assertion: 能成功导入 App 导出的纯数组 JSON 格式数据
- method: manual

---

## R-2024-314 flow-learning 行内编辑和全屏窗口跳动

- problem: P-2024-284
- type: manual
- location: N/A
- assertion: 
  1. 行内编辑功能正常
  2. 全屏应用前窗口不跳动
- method: manual

---

## R-2024-315 flow-learning 导入按钮不显示

- problem: P-2024-285
- type: manual
- location: N/A
- assertion: 导入按钮可见且可点击
- method: manual

---

## R-2024-316 flow-learning Web Dashboard JS 错误

- problem: P-2024-286
- type: manual
- location: N/A
- assertion: Web Dashboard 无 JS 错误，功能正常
- method: manual

---

## R-2024-317 Full-screen-prompt 全屏应用前窗口跳动

- problem: P-2024-287
- type: manual
- location: N/A
- assertion: 
  1. 打开 Full-screen-prompt 应用
  2. 在全屏应用（如视频播放器）前使用
  3. 窗口不应跳动
- method: manual

---

## R-2024-318 Book (epub.js) Node.js 版本兼容性和构建问题

- problem: P-2024-288
- type: deploy
- location: N/A
- assertion: 
  1. 使用 Node.js 18.x 构建成功
  2. 无 OpenSSL 或 crypto 相关错误
  3. 部署后应用正常运行
- method: deploy

---

## R-2024-327 Note-taking-tool 标题被CSS污染

- problem: P-2024-327
- type: manual
- location: N/A
- assertion: 提取标题时不包含CSS样式文本
- method: manual

---

## R-2024-328 Note-taking-tool 沉浸式翻译插件导致按钮重叠

- problem: P-2024-328
- type: manual
- location: N/A
- assertion: 安装沉浸式翻译插件后按钮不重叠
- method: manual

---

## R-2024-329 Note-taking-tool 按钮大小不一致

- problem: P-2024-329
- type: manual
- location: N/A
- assertion: 所有按钮大小一致
- method: manual

---

## R-2024-330 PixelTunePhoto 移动端响应式布局问题

- problem: P-2024-330
- type: manual
- location: N/A
- assertion: 移动端工作区和侧边栏垂直堆叠显示正常
- method: manual

---

## R-2024-331 program-lesson 中文引号语法错误

- problem: P-2024-331
- type: manual
- location: N/A
- assertion: 代码中无中文引号
- method: manual

---

## R-2024-332 relax Netlify构建错误

- problem: P-2024-332
- type: deploy
- location: N/A
- assertion: Netlify 构建成功，无 React hooks 依赖警告
- method: deploy

---

## R-2024-333 relax ESLint错误

- problem: P-2024-333
- type: manual
- location: N/A
- assertion: ESLint 检查通过，无缺少依赖警告
- method: manual

---

## R-2024-334 relax 声音开关功能异常

- problem: P-2024-334
- type: manual
- location: N/A
- assertion: 声音开关功能正常工作
- method: manual

---

## R-2024-335 RI 笔记功能多个关键问题

- problem: P-2024-335
- type: manual
- location: N/A
- assertion: 笔记功能正常工作
- method: manual

---

## R-2024-336 RI 列表项编辑后保存问题

- problem: P-2024-336
- type: manual
- location: N/A
- assertion: 列表项编辑后正确保存
- method: manual

---

## R-2024-337 RI 笔记导出按钮保存后主页未刷新

- problem: P-2024-337
- type: manual
- location: N/A
- assertion: 笔记导出保存后主页自动刷新
- method: manual

---

## R-2024-338 RI 笔记窗口置顶按钮状态不同步

- problem: P-2024-338
- type: manual
- location: N/A
- assertion: 置顶按钮状态与实际状态同步
- method: manual

---

## R-2024-339 RI 打包后应用 currentModeId 未迁移

- problem: P-2024-339
- type: manual
- location: N/A
- assertion: 打包后应用自动迁移 currentModeId
- method: manual

---

## R-2024-340 RI 笔记窗口关闭后无法再次打开

- problem: P-2024-340
- type: manual
- location: N/A
- assertion: 笔记窗口可重复打开关闭
- method: manual

---

## R-2024-341 RI 导入/清空后模式跳转问题

- problem: P-2024-341
- type: manual
- location: N/A
- assertion: 导入/清空后模式跳转正常
- method: manual

---

## R-2024-342 RI 访问已销毁的窗口对象

- problem: P-2024-342
- type: manual
- location: N/A
- assertion: 不会访问已销毁的窗口对象
- method: manual

---

## R-2024-343 RI 列表排序问题

- problem: P-2024-343
- type: manual
- location: N/A
- assertion: 最新保存的内容显示在列表顶部
- method: manual

---

## R-2024-344 RI note-window.js 笔记保存功能问题

- problem: P-2024-344
- type: manual
- location: N/A
- assertion: note-window.js 笔记保存功能正常
- method: manual

---

## R-2024-345 RI 全面保存功能问题

- problem: P-2024-345
- type: manual
- location: N/A
- assertion: 所有保存功能正常工作
- method: manual

---

## R-2024-346 RI 快速保存功能问题

- problem: P-2024-346
- type: manual
- location: N/A
- assertion: 快速保存功能正常
- method: manual

---

## R-2024-347 RI IndexedDB 集成问题

- problem: P-2024-347
- type: manual
- location: N/A
- assertion: IndexedDB 集成正常工作
- method: manual

---

## R-2024-348 RI IndexedDB 数据加载问题

- problem: P-2024-348
- type: manual
- location: N/A
- assertion: IndexedDB 数据正常加载
- method: manual

---

## R-2024-349 RI deleteMode 函数重复声明

- problem: P-2024-349
- type: manual
- location: N/A
- assertion: deleteMode 函数无重复声明
- method: manual

---

## R-2024-350 RI 笔记格式修改丢失

- problem: P-2024-350
- type: manual
- location: N/A
- assertion: 笔记格式修改正确保存
- method: manual

---

## R-2024-351 RI 笔记窗口关闭按钮不起作用

- problem: P-2024-351
- type: manual
- location: N/A
- assertion: 关闭按钮正常工作
- method: manual

---

## R-2024-352 RI 打包配置 electron-store 模块找不到

- problem: P-2024-352
- type: manual
- location: N/A
- assertion: 打包后 electron-store 模块正常加载
- method: manual

---

## R-2024-353 RI 通知图标路径错误

- problem: P-2024-353
- type: manual
- location: N/A
- assertion: 通知图标正常显示
- method: manual

---

## R-2024-400 iterate pnpm版本兼容性

- problem: P-2024-310
- type: manual
- location: N/A
- assertion: pnpm install 正常完成，无版本冲突
- method: manual

---

## R-2024-401 iterate GitHub Actions CI

- problem: P-2024-311
- type: manual
- location: N/A
- assertion: GitHub Actions 工作流正常触发并通过
- method: manual

---

## R-2024-402 iterate 发布脚本分支切换

- problem: P-2024-312
- type: manual
- location: N/A
- assertion: 发布脚本执行时分支切换正常，不受 Cargo.lock 影响
- method: manual

---

## R-2024-403 iterate 发布脚本分支合并

- problem: P-2024-313
- type: manual
- location: N/A
- assertion: 发布流程正确执行分支合并逻辑
- method: manual

---

## R-2024-404 iterate 取消发布退出

- problem: P-2024-314
- type: manual
- location: N/A
- assertion: 取消发布时脚本正确退出，不产生副作用
- method: manual

---

## R-2024-405 iterate 版本选择输出

- problem: P-2024-315
- type: manual
- location: N/A
- assertion: 版本选择函数输出正确重定向
- method: manual

---

## R-2024-406 iterate 发布脚本菜单

- problem: P-2024-316
- type: manual
- location: N/A
- assertion: 发布脚本菜单正常显示
- method: manual

---

## R-2024-407 iterate 错误信息输出

- problem: P-2024-317
- type: manual
- location: N/A
- assertion: 错误信息简洁明了，无冗余日志
- method: manual

---

## R-2024-354 if-compond 授权弹窗邮箱预填充

- problem: P-2024-354
- type: manual
- location: N/A
- assertion: 打开授权弹窗时邮箱自动预填充
- method: manual

---

## R-2024-355 if-compond 缓存数量检查

- problem: P-2024-355
- type: manual
- location: N/A
- assertion: 缓存数量不足时不使用缓存，改用实时请求
- method: manual

---

## R-2024-356 if-compond 置顶博主排序

- problem: P-2024-356
- type: manual
- location: N/A
- assertion: 置顶博主优先显示，Twitter抓取50条，回复转推限10条
- method: manual

---

## R-2024-357 if-compond Supabase URL配置

- problem: P-2024-357
- type: manual
- location: N/A
- assertion: Supabase 连接正常，URL配置正确
- method: manual

---

## R-2024-358 if-compond 密钥在线验证

- problem: P-2024-358
- type: manual
- location: N/A
- assertion: 密钥必须通过在线验证，伪造密钥无法使用
- method: manual

---

## R-2024-359 if-compond 生产环境User-Agent

- problem: P-2024-359
- type: manual
- location: N/A
- assertion: 生产环境HTTP请求包含User-Agent header
- method: manual

---

## R-2024-360 if-compond 本地开发缓存跳过

- problem: P-2024-360
- type: manual
- location: N/A
- assertion: 本地开发环境不使用Netlify Blobs缓存
- method: manual

---

## R-2024-361 if-compond 生产环境请求方式

- problem: P-2024-361
- type: manual
- location: N/A
- assertion: 生产环境使用直接fetch，本地开发使用proxy
- method: manual

---

## R-2024-457 iterate 移动窗口中文输入候选栏

- problem: P-2024-354
- type: manual
- location: N/A
- assertion: 移动窗口时中文输入法候选栏位置正确
- method: manual

---

## R-2024-458 iterate 首次启动主题

- problem: P-2024-355
- type: manual
- location: N/A
- assertion: 首次启动缺少 config.json 时主题正常显示
- method: manual

---

## R-2024-459 iterate 多开配置同步

- problem: P-2024-356
- type: manual
- location: N/A
- assertion: 多开应用时配置正确同步
- method: manual

---

## R-2024-460 iterate 增强快捷键默认值

- problem: P-2024-357
- type: manual
- location: N/A
- assertion: 增强快捷键默认值正确
- method: manual

---

## R-2024-461 iterate 状态同步白屏

- problem: P-2024-358
- type: manual
- location: N/A
- assertion: 状态同步时不出现白屏
- method: manual

---

## R-2024-449 iterate proc-macro 编译

- problem: P-2024-359
- type: manual
- location: N/A
- assertion: proc-macro 编译成功
- method: cargo build

---

## R-2024-450 iterate applyFontVariables 函数

- problem: P-2024-360
- type: manual
- location: N/A
- assertion: applyFontVariables 函数无重复声明
- method: 代码检查

---

## R-2024-451 zhuyili 活动记录秒级时长

- problem: P-2024-361
- type: manual
- location: N/A
- assertion: 活动记录显示秒级时长
- method: manual

---

## R-2024-362 zhuyili 计时器时间归零

- problem: P-2024-362
- type: manual
- location: N/A
- assertion: 计时器时间不会意外归零
- method: manual

---

## R-2024-363 zhuyili 活动记录实时刷新

- problem: P-2024-363
- type: manual
- location: N/A
- assertion: 活动记录实时刷新
- method: manual

---

## R-2024-364 zhuyili Supabase 客户端

- problem: P-2024-364
- type: manual
- location: N/A
- assertion: Supabase 客户端正常访问
- method: manual

---

## R-2024-365 zhuyili 微信支付

- problem: P-2024-365
- type: manual
- location: N/A
- assertion: 购买按钮点击有效，试用次数逻辑正确
- method: manual

---

## R-2024-366 zhuyili 二维码显示

- problem: P-2024-366
- type: manual
- location: N/A
- assertion: 二维码正常显示
- method: manual

---

## R-2024-367 zhuyili payment.js 函数

- problem: P-2024-367
- type: manual
- location: N/A
- assertion: 支付功能正常工作
- method: manual

---

## R-2024-368 zhuyili Google 登录回调

- problem: P-2024-368
- type: manual
- location: N/A
- assertion: Google 登录回调成功
- method: manual

---

## R-2024-369 zhuyili OAuth 回调域名

- problem: P-2024-369
- type: manual
- location: N/A
- assertion: 生产环境 OAuth 回调不跳回本地
- method: manual

---

## R-2024-370 zhuyili OAuth 重定向

- problem: P-2024-370
- type: manual
- location: N/A
- assertion: OAuth 重定向不导致 Netlify 404
- method: manual

---

## R-2024-371 zhuyili 计时器占位符闪烁

- problem: P-2024-371
- type: manual
- location: N/A
- assertion: 计时器继续/暂停时占位符不闪烁
- method: manual

---

## R-2024-372 zhuyili 重复记录

- problem: P-2024-372
- type: manual
- location: N/A
- assertion: 不产生重复记录
- method: manual

---

## R-2024-373 zhuyili 计时器暂停时间

- problem: P-2024-373
- type: manual
- location: N/A
- assertion: 计时器暂停时间计算正确
- method: manual

---

## R-2024-374 zhuyili 多计时器删除

- problem: P-2024-374
- type: manual
- location: N/A
- assertion: 多计时器删除功能正常
- method: manual

---

## R-2024-375 zhuyili JSON 导入日期

- problem: P-2024-375
- type: manual
- location: N/A
- assertion: JSON 导入时日期格式正确
- method: manual

---

## R-2024-376 zhuyili JSON 导入同步

- problem: P-2024-376
- type: manual
- location: N/A
- assertion: JSON 导入后数据正确同步
- method: manual

---

## R-2024-377 zhuyili 用户数据隔离

- problem: P-2024-377
- type: manual
- location: N/A
- assertion: 用户数据正确隔离，JSON 导入正确同步
- method: manual

---

## R-2024-378 zhuyili Google 登录重定向

- problem: P-2024-378
- type: manual
- location: N/A
- assertion: Google 登录重定向正确
- method: manual

---

## R-2024-379 AI- AI Studio URL

- problem: P-2024-379
- type: manual
- location: N/A
- assertion: AI Studio URL 路径正确为 /apps
- method: manual

---

## R-2024-380 AI-Sidebar History 同步

- problem: P-2024-380
- type: manual
- location: N/A
- assertion: History 同步正常工作
- method: manual

---

## R-2024-381 AI-Sidebar Star 按钮状态

- problem: P-2024-381
- type: manual
- location: N/A
- assertion: Star 按钮状态与收藏状态一致
- method: manual

---

## R-2024-382 AI-Sidebar message 监听器

- problem: P-2024-382
- type: manual
- location: N/A
- assertion: message 监听器无语法错误
- method: 代码检查

---

## R-2024-383 AI-Sidebar Starred 按钮图标

- problem: P-2024-383
- type: manual
- location: N/A
- assertion: Starred 按钮显示星号而非对号
- method: manual

---

## R-2024-384 AI-Sidebar History Remove

- problem: P-2024-384
- type: manual
- location: N/A
- assertion: History 面板 Remove 点击正常工作
- method: manual

---

## R-2024-385 AI-Sidebar URL 含特殊字符

- problem: P-2024-385
- type: manual
- location: N/A
- assertion: URL 含 & 时 Remove 正常工作
- method: manual

---

## R-2024-386 AI-Sidebar 嵌套框架 URL

- problem: P-2024-386
- type: manual
- location: N/A
- assertion: ChatGPT/Gemini 嵌套框架 URL 正确同步
- method: manual

---

## R-2024-387 if-compond 授权弹窗邮箱

- problem: P-2024-387
- type: manual
- location: N/A
- assertion: 授权弹窗打开时邮箱自动预填充
- method: manual

---

## R-2024-388 if-compond 缓存数量检查

- problem: P-2024-388
- type: manual
- location: N/A
- assertion: 缓存数量不足时不使用缓存
- method: manual

---

## R-2024-389 if-compond 置顶博主排序

- problem: P-2024-389
- type: manual
- location: N/A
- assertion: 置顶博主优先显示
- method: manual

---

## R-2024-390 if-compond Supabase URL

- problem: P-2024-390
- type: manual
- location: N/A
- assertion: Supabase 连接成功
- method: manual

---

## R-2024-391 if-compond 密钥验证

- problem: P-2024-391
- type: manual
- location: N/A
- assertion: 伪造密钥无法使用
- method: manual

---

## R-2024-392 if-compond User-Agent

- problem: P-2024-392
- type: manual
- location: N/A
- assertion: 生产环境请求正常
- method: manual

---

## R-2024-393 if-compond 本地开发缓存

- problem: P-2024-393
- type: manual
- location: N/A
- assertion: 本地开发不使用 Netlify Blobs 缓存
- method: manual

---

## R-2024-394 if-compond 生产环境代理

- problem: P-2024-394
- type: manual
- location: N/A
- assertion: 生产环境直接 fetch，本地使用代理
- method: manual

---

## R-2024-395 flow-learning EPUB 封面

- problem: P-2024-395
- type: manual
- location: N/A
- assertion: EPUB 封面正确提取
- method: manual

---

## R-2024-396 flow-learning localStorage

- problem: P-2024-396
- type: manual
- location: N/A
- assertion: 封面图片不导致 localStorage 超限
- method: manual

---

## R-2024-397 flow-learning 下载文件名

- problem: P-2024-397
- type: manual
- location: N/A
- assertion: 下载书籍使用原始文件名
- method: manual

---

## R-2024-398 flow-learning 批量上传

- problem: P-2024-398
- type: manual
- location: N/A
- assertion: 批量上传同步到 Supabase
- method: manual

---

## R-2024-399 flow-learning Supabase 文件名

- problem: P-2024-399
- type: manual
- location: N/A
- assertion: Supabase 不报 InvalidKey 错误
- method: manual

---

## R-2024-408 cunzhi-knowledge 验收流程子代理 commit

- problem: P-2024-318
- type: manual
- location: N/A
- assertion: 验收流程中子代理不单独 commit
- method: manual

---

## R-2024-409 cunzhi-knowledge 提示词格式

- problem: P-2024-319
- type: manual
- location: N/A
- assertion: 提示词格式正确，"你是子代理现在帮我做"在最后
- method: manual

---

## R-2024-410 iterate 移动窗口中文输入候选栏

- problem: P-2024-320
- type: manual
- location: N/A
- assertion: 移动窗口时中文输入法候选栏位置正确
- method: manual

---

## R-2024-411 iterate 首次启动主题

- problem: P-2024-321
- type: manual
- location: N/A
- assertion: 首次启动缺少 config.json 时主题正常显示
- method: manual

---

## R-2024-412 iterate 多开配置同步

- problem: P-2024-322
- type: manual
- location: N/A
- assertion: 多开应用时配置正确同步
- method: manual

---

## R-2024-413 zhuyili 活动记录秒级时长

- problem: P-2024-323
- type: manual
- location: N/A
- assertion: 活动记录显示秒级时长
- method: manual

---

## R-2024-414 zhuyili 计时器时间归零

- problem: P-2024-324
- type: manual
- location: N/A
- assertion: 计时器同步后时间不归零
- method: manual

---

## R-2024-415 zhuyili 实时活动刷新

- problem: P-2024-325
- type: manual
- location: N/A
- assertion: 活动记录实时刷新
- method: manual

---

## R-2024-416 zhuyili Supabase 客户端访问

- problem: P-2024-326
- type: manual
- location: N/A
- assertion: 白名单检查可访问 Supabase
- method: manual

---

## R-2024-417 zhuyili 微信支付购买按钮

- problem: P-2024-327
- type: manual
- location: N/A
- assertion: 购买按钮点击事件正确绑定
- method: manual

---

## R-2024-418 zhuyili 二维码显示

- problem: P-2024-328
- type: manual
- location: N/A
- assertion: 点击购买按钮后二维码正常显示
- method: manual

---

## R-2024-419 zhuyili payment.js 函数

- problem: P-2024-329
- type: manual
- location: N/A
- assertion: 支付功能正常工作，无 ReferenceError
- method: manual

---

## R-2024-420 zhuyili Google 登录回调

- problem: P-2024-330
- type: manual
- location: N/A
- assertion: 登录后正确重定向到 Netlify 域名
- method: manual

---

## R-2024-421 zhuyili 生产环境 OAuth 回调

- problem: P-2024-331
- type: manual
- location: N/A
- assertion: 生产环境 OAuth 回调不跳回本地
- method: manual

---

## R-2024-422 zhuyili OAuth 重定向适配

- problem: P-2024-332
- type: manual
- location: N/A
- assertion: OAuth 重定向 URL 自动适配当前域
- method: manual

---

## R-2024-423 zhuyili 端口冲突

- problem: P-2024-333
- type: manual
- location: N/A
- assertion: 服务器端口 8888 正常启动
- method: manual

---

## R-2024-424 AI- AI Studio URL

- problem: P-2024-334
- type: manual
- location: N/A
- assertion: AI Studio URL 路径正确为 /apps
- method: manual

---

## R-2024-425 AI- 图标路径

- problem: P-2024-335
- type: manual
- location: N/A
- assertion: 图标正常显示
- method: manual

---

## R-2024-426 AI-Sidebar message 监听器

- problem: P-2024-336
- type: manual
- location: N/A
- assertion: message 监听器无 await 语法错误
- method: manual

---

## R-2024-427 AI-Sidebar Starred 按钮

- problem: P-2024-337
- type: manual
- location: N/A
- assertion: Starred 按钮显示星号而非对号
- method: manual

---

## R-2024-428 AI-Sidebar History Remove

- problem: P-2024-338
- type: manual
- location: N/A
- assertion: History 中 Remove 按钮点击有效
- method: manual

---

## R-2024-429 AI-Sidebar URL & 符号

- problem: P-2024-339
- type: manual
- location: N/A
- assertion: URL 包含 & 符号时 Remove 功能正常
- method: manual

---

## R-2024-430 AI-Sidebar 嵌套框架 URL 同步

- problem: P-2024-340
- type: manual
- location: N/A
- assertion: ChatGPT/Gemini 嵌套框架 URL 正确同步
- method: manual

---

## R-2024-431 program-lesson 中文引号

- problem: P-2024-341
- type: manual
- location: N/A
- assertion: 代码中无中文引号
- method: manual

---

## R-2024-432 if-compond 授权弹窗邮箱预填充

- problem: P-2024-342
- type: manual
- location: N/A
- assertion: 授权弹窗打开时邮箱自动预填充
- method: manual

---

## R-2024-433 if-compond 缓存数量检查

- problem: P-2024-343
- type: manual
- location: N/A
- assertion: 缓存数量不足时不使用缓存
- method: manual

---

## R-2024-434 if-compond 置顶博主排序

- problem: P-2024-344
- type: manual
- location: N/A
- assertion: 置顶博主优先显示
- method: manual

---

## R-2024-435 if-compond Supabase URL

- problem: P-2024-345
- type: manual
- location: N/A
- assertion: Supabase 连接正常
- method: manual

---

## R-2024-436 if-compond 在线密钥验证

- problem: P-2024-346
- type: manual
- location: N/A
- assertion: 伪造密钥无法通过验证
- method: manual

---

## R-2024-437 if-compond User-Agent

- problem: P-2024-347
- type: manual
- location: N/A
- assertion: 生产环境请求包含 User-Agent
- method: manual

---

## R-2024-438 if-compond 本地开发缓存

- problem: P-2024-348
- type: manual
- location: N/A
- assertion: 本地开发不使用 Netlify Blobs 缓存
- method: manual

---

## R-2024-439 if-compond 生产环境 fetch

- problem: P-2024-349
- type: manual
- location: N/A
- assertion: 生产环境直接 fetch，本地使用代理
- method: manual

---

## R-2024-440 flow-learning EPUB 封面

- problem: P-2024-350
- type: manual
- location: N/A
- assertion: EPUB 封面正确提取
- method: manual

---

## R-2024-441 flow-learning localStorage 超限

- problem: P-2024-351
- type: manual
- location: N/A
- assertion: 封面图片不导致 localStorage 超限
- method: manual

---

## R-2024-442 flow-learning 下载文件名

- problem: P-2024-352
- type: manual
- location: N/A
- assertion: 下载书籍使用原始文件名
- method: manual

---

## R-2024-443 flow-learning 批量上传 Supabase

- problem: P-2024-353
- type: manual
- location: N/A
- assertion: 批量上传同步到 Supabase
- method: manual

---

## R-2024-444 flow-learning Supabase InvalidKey

- problem: P-2024-354
- type: manual
- location: N/A
- assertion: Supabase 不报 InvalidKey 错误
- method: manual

---

## R-2024-445 flow-learning Supabase anon key

- problem: P-2024-355
- type: manual
- location: N/A
- assertion: Supabase 连接正常
- method: manual

---

## R-2024-446 flow-learning 书籍云端链接

- problem: P-2024-356
- type: manual
- location: N/A
- assertion: 书籍点击使用云端链接
- method: manual

---

## R-2024-447 flow-learning JSON 导入

- problem: P-2024-357
- type: manual
- location: N/A
- assertion: 支持 App 导出的纯数组 JSON 格式
- method: manual

---

## R-2024-448 flow-learning 行内编辑和窗口跳动

- problem: P-2024-358
- type: manual
- location: N/A
- assertion: 行内编辑正常，全屏应用前窗口不跳动
- method: manual

---

## R-2024-462 pai 工具输出到寸止窗口

- problem: P-2024-462
- type: manual
- location: cunzhi/src/rust/mcp/tools/dispatch/mcp.rs
- assertion: 
  1. 调用 `pai` 后，子代理提示词显示在寸止窗口（iterate GUI）
  2. 提示词模板包含"完成后必须调用 `zhi` 汇报"指令
  3. 寸止窗口不可用时，降级到 Cascade Output 显示
- method: manual
- status: 待更新应用后验证

---
