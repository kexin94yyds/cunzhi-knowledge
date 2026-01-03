# Patterns

## PAT-2026-001: 鲁棒的 AI 聊天记录抓取模式
- **适用场景**: 抓取包含高度混淆类名的 AI 网页（如 ChatGPT, DeepSeek）。
- **核心模式**:
    1. **层级探测**: 优先寻找带有特定属性（如 `data-testid`）或已知组件类名（如 `ds-markdown`）的元素。
    2. **递归 Markdown 提取**: 通过 `Node.TEXT_NODE` 和 `Node.ELEMENT_NODE` 递归，精准保留列表、代码块（带语言）、加粗、链接等格式。
    3. **多层级标题探测**: 优先从 URL 匹配的侧边栏项、页面 Header 或当前激活态组件中提取标题，而非仅依赖 `document.title`。
    4. **DeepSeek 角色识别**: 结合 `.ds-message` 容器的奇偶索引（DeepSeek 常用模式）和 `.ds-message-bubble--user` 类名进行双重校验。
    5. **UI 杂质过滤**: 提取前自动过滤复制按钮、反馈按钮、SVG 图标等 UI 干扰项。
- **关联 P-ID**: P-2026-001

## PAT-2026-002: 开发者工具的黑白极简（B&W Minimalist）UI 模式
- **适用场景**: 需要高辨识度、专业感且审美前卫的浏览器扩展或开发者工具。
- **核心模式**:
    1. **色彩压缩**: 严格限制色彩空间为 #000 (Black), #fff (White), 和极少量的 #666 (Gray) 用于次要信息。
    2. **形态重塑**: 全局移除圆角（Border-radius: 0），使用硬朗的直线边框（1px or 2px solid #000）。
    3. **排版张力**: 
        - 标题使用 Uppercase (大写) + Bold (加粗) + Letter-spacing (字间距)。
        - 数据展示使用 Monospace (等宽) 字体，强调工具属性。
    4. **负空间交互**: 按钮采用反色交互（默认白底黑字 -> 悬停黑底白字），不使用阴影或渐变来模拟深度，而是通过色彩反转体现状态切换。
    5. **硬阴影 (Brutalist Shadow)**: 列表项悬停时使用非模糊的位移阴影（如 `box-shadow: 10px 10px 0 #000`）。
- **关联 P-ID**: P-2026-002

## PAT-2026-002: Chrome 插件的混合模式数据管理架构
- **适用场景**: 需要同时支持"即用即走"和"持久化管理"的浏览器插件。
- **核心模式**:
    1. **双模式设计**: 
        - 快速模式：点击即导出，无需存储
        - 保存模式：持久化到本地，支持历史管理
    2. **轻量级存储选择**: 
        - 优先 chrome.storage.local（5MB，简单 API）
        - 避免 IndexedDB（复杂但容量大）
        - 适用于中小规模数据（100-200 条记录）
    3. **conversationId 去重机制**:
        - URL 正则提取平台原始 ID
        - 保存前自动查重并提示用户
        - 支持更新策略（update/skip）
    4. **数据结构设计**:
        - 核心字段：id, title, content, provider, conversationId
        - 元数据：timestamp, url, tags, isFavorite, notes
        - 统计字段：messageCount, modifiedAt
    5. **存储容量管理**:
        - 实时监控使用率
        - 超 90% 自动清理（删除最旧的 10% 非收藏项）
        - 提示用户导出备份
    6. **导入导出策略**:
        - JSON 格式包含 version 字段（版本兼容）
        - 导入前验证数据结构
        - 支持 skip/update 两种合并策略
- **技术实现**:
    ```javascript
    // conversationId 提取模式
    function extractConversationId(url, provider) {
      const patterns = {
        chatgpt: /chatgpt\.com\/c\/([a-z0-9-]+)/i,
        claude: /claude\.ai\/chat\/([a-z0-9-]+)/i,
        gemini: () => window.location.hash.substring(1),
        deepseek: /deepseek\.com\/chat\/([a-z0-9-]+)/i
      };
      return patterns[provider]?.exec(url)?.[1] || '';
    }
    
    // 存储容量检查
    async function checkStorageQuota() {
      const data = await chrome.storage.local.get(null);
      const size = JSON.stringify(data).length;
      const usagePercent = (size / (5 * 1024 * 1024)) * 100;
      if (usagePercent > 90) autoCleanup();
    }
    ```
- **对比参考**: insidebar-ai（IndexedDB 无限容量）vs 我们的方案（chrome.storage 适度容量）
- **关联 P-ID**: P-2026-003

## PAT-2026-003: 对标学习的系统化方法
- **适用场景**: 需要快速提升产品功能完整性，参考成熟竞品。
- **核心模式**:
    1. **克隆分析法**:
        - `git clone` 目标项目到独立目录
        - 不直接修改，仅作为参考
    2. **结构化对比**:
        - 列表对比功能模块（导出/导入/搜索/统计等）
        - 标注差距等级（Critical/High/Medium/Low）
        - 优先补齐 Critical 和 High 级别功能
    3. **取舍原则**:
        - 保留自身核心优势（如即时抓取）
        - 引入对方优势功能（如历史管理）
        - 简化不必要的复杂度（如 IndexedDB → chrome.storage）
    4. **分阶段实施**:
        - Phase 1: 基础存储（CRUD）
        - Phase 2: 双格式导出
        - Phase 3: 历史管理 UI
        - Phase 4: 导入导出
    5. **代码复用度评估**:
        - 数据结构：80% 参考，20% 调整
        - UI 设计：50% 参考，50% 自定义
        - 核心算法：100% 自主实现
- **成功案例**: 本次 AI Chat Exporter v2.0 开发，通过对标 insidebar-ai 完成全功能升级
- **关联 P-ID**: P-2026-003
