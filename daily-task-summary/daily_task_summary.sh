#!/bin/bash
# Daily Task Summary - 整理 top 3 任务发送到 Telegram
# 由 scheduler skill 调用，每天 11:00 执行

REPO_DIR="/Users/amami/my2026/personal/eue"
ROADMAP="$REPO_DIR/ROADMAP.md"
TODO="$REPO_DIR/TODO.md"
CHAT_ID="-1002246024089"
TOKEN="${EUE_TELEGRAM_TOKEN}"

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
