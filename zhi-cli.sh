#!/bin/bash
# zhi-cli: 命令行版寸止交互工具（支持 iterate + windsurf-cunzhi fallback）
# 用法: zhi-cli.sh "消息" ["选项1,选项2,选项3"] [project_path]

MESSAGE="${1:-请确认是否继续？}"
OPTIONS="${2:-}"
PROJECT_PATH="${3:-$(pwd)}"

# 弹窗引擎路径
ITERATE_APP="/Applications/iterate.app/Contents/MacOS/iterate"
# windsurf-cunzhi 路径（优先知识库内，其次全局）
if [[ -x "$(dirname "$0")/bin/windsurf-cunzhi" ]]; then
    WINDSURF_CUNZHI="$(dirname "$0")/bin/windsurf-cunzhi"
else
    WINDSURF_CUNZHI="$HOME/bin/windsurf-cunzhi"
fi

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

# 尝试使用 iterate 弹窗（不稳定，仅作备用）
use_iterate() {
    export ITERATE_IPC_FORWARD=0
    pkill -9 -x iterate 2>/dev/null || true
    sleep 0.5
    "$ITERATE_APP" --mcp-request "$REQUEST_FILE" 2>&1
}

# 尝试使用 windsurf-cunzhi 弹窗（fallback）
use_windsurf_cunzhi() {
    "$WINDSURF_CUNZHI" --ui --message "$MESSAGE" --options "$OPTIONS" 2>&1
}

# 主逻辑：只用 windsurf-cunzhi（iterate 弹窗不稳定）
if [[ -x "$WINDSURF_CUNZHI" ]]; then
    use_windsurf_cunzhi
elif [[ -x "$ITERATE_APP" ]]; then
    use_iterate
else
    echo '{"error": "No popup engine available"}' >&2
    exit 1
fi

# 清理临时文件
rm -f "$REQUEST_FILE"
