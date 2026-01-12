#!/bin/bash
# zhi-cli: 命令行版寸止交互工具 (同步阻塞版本)
# 实现原理参考: https://github.com/hjw-plango/AIFeedbackToolBlocking

MESSAGE="${1:-请确认是否继续？}"
OPTIONS="${2:-}"
PROJECT_PATH="${3:-$(pwd)}"

# 弹窗引擎路径
ITERATE_APP="/Applications/iterate.app/Contents/MacOS/iterate"

# 创建临时请求文件
REQUEST_FILE="/tmp/zhi_request_$$_$(date +%s).json"

# 构建预定义选项 JSON
if [[ -n "$OPTIONS" ]]; then
    IFS=',' read -ra OPT_ARRAY <<< "$OPTIONS"
    OPTIONS_JSON=$(printf '%s\n' "${OPT_ARRAY[@]}" | jq -R . | jq -s .)
else
    OPTIONS_JSON="[]"
fi

# 使用 jq -Rs 正确处理多行文本，确保 JSON 格式严谨
MESSAGE_JSON=$(printf '%s' "$MESSAGE" | jq -Rs .)
PROJECT_JSON=$(printf '%s' "$PROJECT_PATH" | jq -Rs .)

cat > "$REQUEST_FILE" << EOF
{
  "id": "zhi-cli-$(date +%s)-$$",
  "message": $MESSAGE_JSON,
  "predefined_options": $OPTIONS_JSON,
  "is_markdown": true,
  "project_path": $PROJECT_JSON
}
