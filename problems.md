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

