# Problems

## P-2026-001: 导出 AI 聊天记录为 Markdown 的 Chrome 插件
- **现象**: 用户需要将网页版 AI（ChatGPT/Claude/DeepSeek）的对话导出为 Markdown 文件。用户曾反馈无法抓取“用户消息”且标题识别不准。
- **根因**: 原生网页 DOM 结构复杂且动态变化，简单的类名匹配容易失效。
- **状态**: fixed
- **解决总结**: 
    1. 借鉴了 `insidebar-ai` 的成熟方案，实现了基于 `Node.TEXT_NODE` 和 `Node.ELEMENT_NODE` 递归的稳健 Markdown 提取算法。
    2. 针对 DeepSeek 引入了“奇偶校验 + 视觉特征”双重角色识别。
    3. 针对 ChatGPT 结合了 `data-message-author-role` 和 `conversation-turn` 结构化抓取。
    4. 实现了多层级标题探测（URL ID 匹配、侧边栏激活态、页面 Header），解决了标题不准的问题。
- **影响范围**: 全平台（ChatGPT, Claude, DeepSeek）

## P-2026-002: 插件 UI 风格缺乏辨识度
- **现象**: 初始 UI 使用了通用的 Bootstrap 风格配色（蓝色/绿色/灰色），视觉上较为普通，不符合极简主义审美。
- **根因**: UI 设计未经过深度定制，缺乏独特的品牌感。
- **状态**: fixed
- **解决总结**: 
    1. 重新设计为黑白极简风（B&W Minimalist），移除所有彩色和渐变。
    2. 采用直角设计（Border-radius: 0）和硬阴影（Hard Shadow），增加视觉冲击力。
    3. 优化交互逻辑：按钮默认白底黑字，悬停反转为黑底白字，提升反馈感。
    4. 引入 Monospace 字体处理数值和状态信息，增强专业感。
- **影响范围**: Popup 页面、History 历史记录页面

## P-2026-003: AI 聊天插件缺少持久化存储和历史管理
- **现象**: v1.0 版本只能即时导出当前对话，无法保存历史记录、批量管理、去重检测，也不支持导入功能。
- **根因**: 
    1. 初版设计追求"即用即走"理念，未考虑长期使用场景
    2. 缺少参考成熟产品（如 insidebar-ai）的数据架构设计
    3. 未提取 conversationId 导致无法实现去重
- **状态**: verified
- **解决总结**:
    1. **数据层**: 引入 chrome.storage.local 作为持久化存储（5MB容量，适合 100-200 条对话）
    2. **元数据提取**: 实现 conversationId 提取逻辑（支持 ChatGPT/Claude/Gemini/DeepSeek 四大平台）
    3. **去重机制**: 基于 conversationId 的查重，保存前自动检测重复并提示用户
    4. **双格式导出**: 支持 Markdown（可读）+ JSON（结构化）双格式
    5. **历史管理**: 完整的 CRUD 界面（搜索、筛选、排序、收藏、标签）
    6. **导入导出**: 支持全量数据备份与恢复（含去重策略选择）
    7. **统计分析**: 提供存储用量、对话数量、消息统计
    8. **存储优化**: 自动清理（容量超90%时删除最旧的10%非收藏对话）
- **技术方案**:
    - 数据结构: 包含 id, title, content, provider, conversationId, timestamp, url, tags, isFavorite, notes, messageCount
    - conversationId 正则匹配:
        - ChatGPT: `/chatgpt\.com\/c\/([a-z0-9-]+)/i`
        - Claude: `/claude\.ai\/chat\/([a-z0-9-]+)/i`
        - Gemini: `window.location.hash`
        - DeepSeek: `/deepseek\.com\/chat\/([a-z0-9-]+)/i`
    - 存储 API: chrome.storage.local（与 IndexedDB 相比更简单但有容量限制）
- **对比参考**: insidebar-ai 使用 IndexedDB 无容量限制，但实现复杂度高；我们选择轻量级方案更适合插件场景
- **影响范围**: 全功能重构（v1.0 → v2.0）
