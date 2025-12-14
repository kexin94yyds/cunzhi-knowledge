# 可复用模式 (Patterns Registry)

> 记录跨项目可复用的解决方案和最佳实践。

---

## 模式清单

<!-- 新模式追加在此处 -->

## PAT-2024-001 提示词行为导向原则

- 来源：Claude / Windsurf 官方最佳实践
- 日期：2024-12-14

**核心原则：**
- 规则要告诉 AI **做什么**，而不是描述概念
- 避免定义导向（"X 是唯一来源"），改用行为导向（"必须写入 X"）

**示例：**
| 定义导向（差） | 行为导向（好） |
|----------------|----------------|
| "寸止授权是唯一事实来源" | "寸止返回后，根据用户响应继续执行" |
| "X 是唯一合法来源" | "所有记录必须写入 X" |
| "仅 verified 状态视为已完成" | "只有 verified 状态才能标记为已完成" |

---

## PAT-2024-002 Memory vs Knowledge 分层设计

- 来源：imhuso/cunzhi 项目分析
- 日期：2024-12-14

**分层原则：**
- `.cunzhi-memory/` = L1 缓存（项目级、快速、临时）
- `.cunzhi-knowledge/` = L2 持久化（全局级、规范、长期）

**分工：**
| 目录 | 内容 | 同步方式 |
|------|------|----------|
| .cunzhi-memory/ | context/preferences/patterns/rules | 跟项目 git |
| .cunzhi-knowledge/ | problems/regressions/patterns | 独立仓库 push |

**关键约束：**
- `.cunzhi-memory/` 禁止存放 `problems.md`，避免重叠

---

## PAT-2024-003 XML 标签分组规则

- 来源：Windsurf 官方推荐
- 日期：2024-12-14

**用法：**
```xml
<section_name>
## 标题
- 规则内容
</section_name>
```

**好处：**
- 结构清晰，便于 AI 解析
- 支持条件性加载
- 易于维护和扩展

