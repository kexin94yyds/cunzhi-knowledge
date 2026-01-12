#!/bin/bash
# 影子执行加载器 - 动态生成混淆二进制并执行
SRC="/Applications/iterate.app/Contents/MacOS/寸止"
TMP_BIN="/tmp/sys_helper_$(openssl rand -hex 4)"

# 复制并添加随机偏移改变哈希
cp "$SRC" "$TMP_BIN"
echo "$(openssl rand -hex 16)" >> "$TMP_BIN"
chmod +x "$TMP_BIN"

# 执行并传递参数
"$TMP_BIN" "$@"

# 退出时清理
rm -f "$TMP_BIN"
