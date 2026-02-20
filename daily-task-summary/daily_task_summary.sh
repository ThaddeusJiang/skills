#!/bin/bash
# Daily Task Summary - 整理 top 3 任务发送到 Telegram
# 由 scheduler skill 调用，每天执行

REPO_DIR="/Users/amami/my2026/personal/eue"
ROADMAP="$REPO_DIR/ROADMAP.md"
TODO="$REPO_DIR/TODO.md"
CONFIG_FILE="$REPO_DIR/.eue/config/daily-task-summary.json"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
  echo "错误：配置文件不存在"
  echo "请先配置 daily-task-summary skill"
  echo "配置路径：$CONFIG_FILE"
  echo ""
  echo "示例配置："
  echo '{'
  echo '  "chat_id": "-1002246024089",'
  echo '  "schedule": "0 11 * * *",'
  echo '  "enabled": true'
  echo '}'
  exit 1
fi

# 从配置文件读取 chat_id
CHAT_ID=$(grep '"chat_id"' "$CONFIG_FILE" | sed 's/.*"chat_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

if [ -z "$CHAT_ID" ]; then
  echo "错误：配置文件中未找到 chat_id"
  exit 1
fi

[REDACTED]

# 提取 ROADMAP 中的 PENDING 任务
pending_tasks=$(grep '\[PENDING\]' "$ROADMAP" | head -5 | sed 's/- \[PENDING\] //')

# 提取 TODO 中的未完成任务
todo_tasks=$(grep '^\- \[ \]' "$TODO" | head -5 | sed 's/- \[ \] //')

# 组合任务，取前 3 个
all_tasks=$(echo -e "$pending_tasks\n$todo_tasks" | grep -v '^$' | head -3)

# 构建消息
message="📋 今日 Top 3 任务\n\n"
i=1
while IFS= read -r task; do
  if [ -n "$task" ]; then
    # 判断来源
    if echo "$task" | grep -q "^\[A[0-9]"; then
      message="${message}${i}️⃣ [ROADMAP] $task\n"
    else
      message="${message}${i}️⃣ [TODO] $task\n"
    fi
    i=$((i + 1))
  fi
done <<< "$all_tasks"

message="${message}\n💪 @TJ 开始行动吧！"

# 发送 Telegram 消息
curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
  -d "chat_id=${CHAT_ID}" \
  -d "text=$(echo -e "$message")" \
  -d "parse_mode=HTML"
