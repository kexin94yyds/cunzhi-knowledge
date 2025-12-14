# 回归检查索引 (Regressions Registry)

> 记录所有回归检查，确保已修复的问题不会再次发生。

---

## 条目格式说明

每个回归检查应包含：
- **ID**: R-YYYY-NNN 格式
- **关联问题**: P-ID
- **类型**: unit / e2e / integration / 手工检查
- **位置**: 测试文件路径
- **关键断言**: 检查的核心逻辑
- **运行方式**: 执行命令

---

## 回归检查清单

<!-- 新回归检查追加在此处 -->

## R-2024-002 WindowSwitcher 上下箭头切换窗口置顶

- 关联问题：P-2024-002
- 类型：手工检查
- 位置：`src/frontend/components/common/WindowSwitcher.vue`
- 关键断言：
  1. 打开多个 iterate 窗口并列显示
  2. 按 Tab 键打开窗口选择器
  3. 使用上下箭头切换选中行
  4. 每次切换时，对应窗口应实时置顶显示
- 运行方式：手工测试验证
- 代码检查点：确保 `handleKeydown` 中 ArrowUp/ArrowDown 分支调用了 `activateWindowAtIndex(selectedIndex.value)`

