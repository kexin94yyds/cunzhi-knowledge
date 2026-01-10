#!/bin/bash
# zhi-cli: 命令行版寸止交互工具（调用完整 Tauri 输入框）
# 用法: zhi-cli.sh "消息" ["选项1,选项2,选项3"] [project_path]

set -e

MESSAGE="${1:-请确认是否继续？}"
OPTIONS="${2:-}"
PROJECT_PATH="${3:-$(pwd)}"

# iterate 应用路径
ITERATE_APP="/Applications/iterate.app/Contents/MacOS/iterate"

# 创建临时请求文件（使用 PID 和时间戳确保唯一）
REQUEST_FILE="/tmp/zhi_request_$$_$(date +%s).json"

# 构建预定义选项数组
if [[ -n "$OPTIONS" ]]; then
    IFS=',' read -ra OPT_ARRAY <<< "$OPTIONS"
    OPTIONS_JSON=$(printf '%s\n' "${OPT_ARRAY[@]}" | jq -R . | jq -s .)
else
    OPTIONS_JSON="[]"
fi

# 生成唯一ID
REQUEST_ID="zhi-cli-$(date +%s)-$$"

# 生成请求 JSON（PopupRequest 格式）
cat > "$REQUEST_FILE" << EOF
{
  "id": "$REQUEST_ID",
  "message": $(echo "$MESSAGE" | jq -R .),
  "predefined_options": $OPTIONS_JSON,
  "is_markdown": true,
  "project_path": $(echo "$PROJECT_PATH" | jq -R .)
}
EOF

# 强制杀死所有 iterate 进程
killall -9 iterate 2>/dev/null || true
sleep 1

# 确认进程已完全退出
for i in {1..10}; do
    if ! pgrep -x iterate > /dev/null 2>&1; then
        break
    fi
    killall -9 iterate 2>/dev/null || true
    sleep 0.3
done

# 直接调用二进制（阻塞等待响应）
"$ITERATE_APP" --mcp-request "$REQUEST_FILE"

# 清理临时文件
rm -f "$REQUEST_FILE"
