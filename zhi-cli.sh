#!/bin/bash
# zhi-cli: 命令行版寸止交互工具（支持 iterate + windsurf-cunzhi fallback）
# 用法: zhi-cli.sh "消息" ["选项1,选项2,选项3"] [project_path]

MESSAGE="${1:-请确认是否继续？}"
OPTIONS="${2:-}"
PROJECT_PATH="${3:-$(pwd)}"

# 弹窗引擎路径
ITERATE_APP="/Applications/iterate.app/Contents/MacOS/iterate"
WINDSURF_CUNZHI="$HOME/bin/windsurf-cunzhi"

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

# 尝试使用 iterate 弹窗
use_iterate() {
    export ITERATE_IPC_FORWARD=0
    
    # 杀死所有现有 iterate 进程（避免主页干扰弹窗）
    pkill -9 -x iterate 2>/dev/null || true
    
    # 等待进程完全退出
    for i in $(seq 1 10); do
        if ! pgrep -x iterate > /dev/null 2>&1; then
            break
        fi
        sleep 0.2
    done
    sleep 0.5
    
    # 启动弹窗
    "$ITERATE_APP" --mcp-request "$REQUEST_FILE" 2>&1
}

# 尝试使用 windsurf-cunzhi 弹窗（fallback）
use_windsurf_cunzhi() {
    "$WINDSURF_CUNZHI" --ui --message "$MESSAGE" --options "$OPTIONS" 2>&1
}

# 主逻辑：只用 iterate（windsurf-cunzhi 作为备用，需手动启用）
# 设置 USE_WINDSURF_CUNZHI=1 可强制使用 windsurf-cunzhi
if [[ "${USE_WINDSURF_CUNZHI:-0}" == "1" ]] && [[ -x "$WINDSURF_CUNZHI" ]]; then
    use_windsurf_cunzhi
elif [[ -x "$ITERATE_APP" ]]; then
    use_iterate
elif [[ -x "$WINDSURF_CUNZHI" ]]; then
    use_windsurf_cunzhi
else
    echo '{"error": "No popup engine available"}' >&2
    exit 1
fi

# 清理临时文件
rm -f "$REQUEST_FILE"
