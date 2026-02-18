# Reminder Skill

Combine scheduler and telegram-send for timed reminders.

## Capability

This skill combines:
- **scheduler** - Time delay execution
- **telegram-send** - Send Telegram messages

For sending macOS notifications, use scheduler + osascript directly.

## When to Use

- User asks to be reminded at a specific time
- User wants a timer or countdown reminder
- Need to send delayed Telegram messages

---

## Dependencies

This skill uses:
- `scheduler` skill for time delays
- `telegram-send` skill for sending messages
- `telegram-context` skill for extracting sender info

---

## Telegram Reminder

### Basic reminder (send after delay)

```bash
# Send message after N seconds
nohup sh -c 'sleep $SECONDS && curl -s -X POST "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/sendMessage" -d "chat_id=CHAT_ID" -d "text=MESSAGE"' > /tmp/reminder_$$.log 2>&1 &
echo "Reminder PID: $!"
```

### Reminder with @mention

```bash
# Use telegram-context skill to get user info first
USER_ID=940788576
FIRST_NAME="Amami"
CHAT_ID=-1002246024089
DELAY_SECONDS=300

nohup sh -c "sleep ${DELAY_SECONDS} && curl -s -X POST \"https://api.telegram.org/bot\${EUE_TELEGRAM_TOKEN}/sendMessage\" -d \"chat_id=${CHAT_ID}\" -d \"text=<a href=\\\"tg://user?id=${USER_ID}\\\">${FIRST_NAME}</a> ⏰ 时间到了！\" -d \"parse_mode=HTML\"" > /tmp/reminder_$$.log 2>&1 &
echo "Reminder PID: $!"
```

---

## macOS Notification Reminder

```bash
# Send macOS notification after delay
DELAY_MINUTES=5
MESSAGE="该睡觉了！😴"

nohup sh -c "sleep $((DELAY_MINUTES * 60)) && osascript -e 'display notification \"${MESSAGE}\" with title \"EUE Reminder\" sound name \"Glass\"'" > /dev/null 2>&1 &
echo "Reminder PID: $!"
```

---

## Check Running Reminders

```bash
# Telegram reminders
ps aux | grep -E 'sleep.*telegram' | grep -v grep

# macOS notifications
ps aux | grep -E 'sleep.*osascript' | grep -v grep

# All reminders
ps aux | grep 'sleep' | grep -v grep
```

---

## Cancel Reminders

```bash
# Cancel specific reminder
kill $PID

# Cancel all Telegram reminders
pkill -f 'sleep.*telegram'

# Cancel all macOS reminders
pkill -f 'sleep.*osascript'
```

---

## Execution Policy

1. **Extract sender info** - Use telegram-context to get user_id for @mention
2. **Verify Telegram works** - Check response for `ok: true`
3. **Report PID** - Tell user the process ID for cancellation
4. **Use nohup** - Ensure process survives shell exit

---

## Example Workflow

User: `@bot 5分钟后提醒我睡觉`

1. Parse message for delay (5分钟 = 300秒)
2. Use telegram-context to get sender info (user_id, chat_id, first_name)
3. Schedule reminder with @mention:
   ```bash
   nohup sh -c "sleep 300 && curl -s -X POST \"https://api.telegram.org/bot\${EUE_TELEGRAM_TOKEN}/sendMessage\" -d \"chat_id=${CHAT_ID}\" -d \"text=<a href=\\\"tg://user?id=${USER_ID}\\\">${FIRST_NAME}</a> 该睡觉了！😴\" -d \"parse_mode=HTML\"" > /tmp/reminder_$$.log 2>&1 &
   ```
4. Report PID to user
