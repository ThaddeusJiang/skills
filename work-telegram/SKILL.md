# Work Telegram Skill

Manage a separate Work Telegram bot for professional use during work hours.

---

## Capability

This skill enables:
- **Separate Work Bot** - Independent bot for work-related tasks
- **Work Context** - Dedicated workspace, memory, and reminders
- **Work Hours** - Scheduled availability during work hours
- **Privacy** - Keep work and personal messages separate

---

## When to Use

- Working from office and need Telegram assistant
- Want to separate work tasks from personal tasks
- Need work-specific reminders and notes
- Managing work-life balance

---

## Requirements

1. **Create Work Bot** (one-time setup):
   - Open Telegram and search `@BotFather`
   - Send `/newbot`
   - Name it `Amami Work Bot` (or your preference)
   - Username: `amami_work_bot` (or available name)
   - Copy the bot token

2. **Environment Variables**:
   ```bash
   export EUE_WORK_TELEGRAM_TOKEN="your_work_bot_token"
   export EUE_WORK_CHAT_ID="your_work_chat_id"
   ```

---

## Setup Instructions

### Step 1: Create Bot

```bash
# Via BotFather (manual step)
# 1. Open @BotFather in Telegram
# 2. Send /newbot
# 3. Follow prompts to create work bot
# 4. Copy token
```

### Step 2: Get Chat ID

```bash
# Start your work bot, send a message, then:
curl -s "https://api.telegram.org/bot${EUE_WORK_TELEGRAM_TOKEN}/getUpdates?limit=1&offset=-1" | jq -r '.result[0].message.chat.id'
```

### Step 3: Configure Environment

Add to `~/.zshrc` or `~/.bashrc`:
```bash
export EUE_WORK_TELEGRAM_TOKEN="your_token_here"
export EUE_WORK_CHAT_ID="your_chat_id_here"
```

---

## Usage

### Send Work Message

```bash
# Always get chat_id dynamically first
CHAT_ID=$(curl -s "https://api.telegram.org/bot${EUE_WORK_TELEGRAM_TOKEN}/getUpdates?limit=1&offset=-1" | jq -r '.result[0].message.chat.id')

curl -s -X POST "https://api.telegram.org/bot${EUE_WORK_TELEGRAM_TOKEN}/sendMessage" \
  -d "chat_id=$CHAT_ID" \
  -d "text=Work reminder: Meeting in 10 minutes 📅"
```

### Work Reminder

```bash
# 30 minutes work reminder
CHAT_ID=$(curl -s "https://api.telegram.org/bot${EUE_WORK_TELEGRAM_TOKEN}/getUpdates?limit=1&offset=-1" | jq -r '.result[0].message.chat.id')

nohup sh -c 'sleep 1800 && curl -s -X POST "https://api.telegram.org/bot${EUE_WORK_TELEGRAM_TOKEN}/sendMessage" -d "chat_id='$CHAT_ID'" -d "text=🔔 Work reminder: Task due!"' > /tmp/work_reminder_$$.log 2>&1 &
PID=$!

# Verify
ps -p $PID && echo "✅ Work reminder set (PID: $PID)"
```

---

## Work Hours Mode

### Enable Work Hours

```bash
# Set work hours (e.g., 9:00-18:00)
export EUE_WORK_START_HOUR=9
export EUE_WORK_END_HOUR=18
```

### Check Work Hours

```bash
current_hour=$(date +%H)
if [ $current_hour -ge $EUE_WORK_START_HOUR ] && [ $current_hour -lt $EUE_WORK_END_HOUR ]; then
  echo "Currently in work hours"
else
  echo "Outside work hours"
fi
```

---

## Execution Policy

1. **MUST use `EUE_WORK_TELEGRAM_TOKEN`** - Not personal bot token
2. **MUST get chat_id dynamically** - Call getUpdates before sendMessage
3. **MUST verify process** - Check PID after starting reminder
4. **MUST keep work/personal separate** - Different workspaces
5. **MUST respect work hours** - Only send during configured hours (optional)

---

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `EUE_WORK_TELEGRAM_TOKEN` | Work bot token | Yes |
| `EUE_WORK_CHAT_ID` | Work chat ID | Optional (can get dynamically) |
| `EUE_WORK_START_HOUR` | Work start hour (0-23) | Optional |
| `EUE_WORK_END_HOUR` | Work end hour (0-23) | Optional |

---

## Notes

- Keep work bot and personal bot separate for privacy
- Use different workspaces for work and personal tasks
- Consider timezone when setting work hours
- Can be combined with `nowledge-mem` for work-specific memory
