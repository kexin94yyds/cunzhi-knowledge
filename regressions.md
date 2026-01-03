# Regression Checks

## R-2026-001: 验证 AI 聊天记录导出功能
- **关联问题**: P-2026-001
- **测试类型**: 手工检查 / 冒烟测试
- **检查步骤**:
    1. 加载 `ai-chat-exporter` 文件夹作为已解解压的 Chrome 扩展。
    2. 打开 [ChatGPT](https://chatgpt.com) 开启一段对话。
    3. 点击插件图标，观察 Popup 显示的 "Captured X messages" 数量是否正确。
    4. 点击 "Export as Markdown"，检查下载的文件名是否与侧边栏标题一致（包含日期）。
    5. 打开 `.md` 文件，验证内容是否包含 `### User` 和 `### Assistant` 交替出现，且代码块语法高亮标签（如 python, javascript）是否正确。
    6. 在 [DeepSeek](https://chat.deepseek.com)、[Claude](https://claude.ai) 和 [Gemini](https://gemini.google.com) 重复上述步骤。
- **预期结果**:
    - 成功生成并下载文件。
    - 用户和 AI 的消息按原始对话顺序交替排列（Gemini 特别验证：通过 `message-content` 标签捕获）。
    - 列表、代码块、加粗等 Markdown 格式完美保留。
- **状态**: verified

## R-2026-002: 验证黑白极简 UI 风格
- **关联问题**: P-2026-002
- **测试类型**: 视觉回归测试 / 交互检查
- **检查步骤**:
    1. 点击插件图标打开 Popup。
    2. 验证：
        - 整体背景为纯白，文字为纯黑。
        - 所有按钮是否有圆角（应为直角）。
        - 标题是否为大写且加粗。
    3. 交互验证：
        - 鼠标悬停在按钮上，背景色应变为黑色，文字变为白色。
        - 点击 "View History" 进入历史记录页面。
    4. 历史记录页面验证：
        - 验证顶部 Header 是否为黑底白字。
        - 验证列表项是否有硬阴影（Hard Shadow）。
        - 验证按钮悬停反色效果是否一致。
- **预期结果**:
    - 全局无彩色、无渐变、无圆角。
    - 按钮悬停反色反馈灵敏。
    - 页面布局保持整洁且信息层级清晰。
- **状态**: verified

## R-2026-003: 验证持久化存储和历史管理功能
- **关联问题**: P-2026-003
- **测试类型**: 手工检查 / 功能测试
- **检查步骤**:
    1. **conversationId 提取测试**:
        - 在 ChatGPT 创建新对话，URL 应包含 `/c/[id]`
        - 点击"Save & Export"，控制台应显示提取到的 conversationId
        - 在 Claude/Gemini/DeepSeek 重复验证
    2. **去重机制测试**:
        - 在同一对话页面连续点击两次"Save & Export"
        - 第二次应弹出确认框提示"已存在，是否更新？"
        - 选择取消，验证未创建重复记录
    3. **双格式导出测试**:
        - 点击"Export Markdown"，下载 `.md` 文件
        - 点击"Export JSON"，下载 `.json` 文件
        - 验证 JSON 包含 version, provider, conversationId, messages 字段
    4. **历史管理界面测试**:
        - 点击"View History"，打开历史管理页面
        - 验证显示对话列表，包含平台徽章、时间、消息数
        - 测试搜索功能（输入标题关键词）
        - 测试筛选功能（按 provider 筛选）
        - 测试排序功能（最新/最旧/标题）
    5. **CRUD 操作测试**:
        - 点击"⭐"，验证收藏状态切换
        - 点击"👁️ View"，验证弹窗显示完整对话
        - 点击"✏️ Edit"，修改标题，验证保存成功
        - 点击"📝 Export MD"，验证单个导出
        - 点击"🗑️ Delete"，验证删除（需二次确认）
    6. **导入导出测试**:
        - 点击"Export All"，下载完整备份 JSON
        - 点击"Clear All"清空所有记录（需三次确认）
        - 点击"Import Data"，选择刚才的备份文件
        - 验证导入统计（imported/skipped/updated）
        - 验证数据完整恢复
    7. **存储容量测试**:
        - 保存 10+ 条对话
        - 验证统计面板显示正确的存储用量
        - 验证 popup 显示正确的历史记录数量
- **预期结果**:
    - conversationId 正确提取（所有平台）
    - 重复对话正确识别并提示
    - 双格式导出功能正常
    - 搜索/筛选/排序功能正常
    - 所有 CRUD 操作成功执行
    - 导入导出数据完整无丢失
    - 统计数据准确
- **状态**: pending
