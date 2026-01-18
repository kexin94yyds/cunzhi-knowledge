# RI 应用更新工作流

> 快速将代码修改部署到本地 macOS 应用

## 触发条件
- 用户说"更新应用"、"部署到本地"、"打包更新"
- 完成功能开发后需要测试正式版

## 工作流步骤

### 1. 停止开发服务器
```bash
pkill -f "electron" || true
```

### 2. Git 保存（可选）
```bash
cd /Users/apple/信息置换起/RI
git add -A && git commit -m "feat: 功能描述"
```

### 3. 执行更新脚本
```bash
cd /Users/apple/信息置换起/RI
bash update-local.sh
```

脚本会自动执行：
1. `npm run build:mac` - 打包应用
2. 停止旧版本并清理锁文件
3. 备份并替换 `/Applications/Replace-Information.app/Contents`
4. 清理 Gatekeeper 隔离属性
5. 启动新版本

### 4. 验证
- 使用快捷键 `Shift+Cmd+U` 唤出应用
- 测试新功能是否正常工作

## 注意事项
- 打包过程约需 1-2 分钟
- 如果打包失败，检查 `package.json` 中的版本号和配置
- 更新后首次启动可能需要几秒钟初始化

## 相关文件
- `update-local.sh` - 更新脚本
- `package.json` - 应用配置
- `electron-main.js` - 主进程
- `electron-preload.js` - 预加载脚本
