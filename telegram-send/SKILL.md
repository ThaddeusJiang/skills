# Telegram Send Skill

Send messages to Telegram chats via Bot API.

## Capability

This skill provides Telegram message sending:
- Send text messages to users, groups, channels
- Support @mentions and formatting
- Reply to specific messages

## When to Use

- Send notifications to Telegram
- Remind users via Telegram
- Bot responses in groups

---

## Requirements

- `EUE_TELEGRAM_TOKEN` environment variable must be set (bot token from @BotFather)
- Target `chat_id` (user, group, or channel)

---

## Basic Send Message

```bash
curl -s -X POST "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/sendMessage" \
  -d "chat_id=CHAT_ID" \
  -d "text=YOUR_MESSAGE"
```

### Example

```bash
# Send to user
curl -s -X POST "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/sendMessage" \
  -d "chat_id=940788576" \
  -d "text=Hello from EUE!"
```

---

## Send to Group

```bash
# Group chat_id is negative
curl -s -X POST "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/sendMessage" \
  -d "chat_id=-1002246024089" \
  -d "text=Group message!"
```

---

## @Mention Users

### Method 1: Using username

```bash
curl -s -X POST "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/sendMessage" \
  -d "chat_id=-1002246024089" \
  -d "text=@username 该睡觉了！ ⏰"
```

### Method 2: Using HTML mention (works without username)

```bash
curl -s -X POST "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/sendMessage" \
  -d "chat_id=-1002246024089" \
  -d "text=<a href=\"tg://user?id=940788576\">Amami</a> 该睡觉了！ ⏰" \
  -d "parse_mode=HTML"
```

---

## Reply to Message

```bash
curl -s -X POST "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/sendMessage" \
  -d "chat_id=-1002246024089" \
  -d "text=Replying to your message" \
  -d "reply_to_message_id=123"
```

---

## Formatting Options

### HTML Mode

```bash
curl -s -X POST "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/sendMessage" \
  -d "chat_id=CHAT_ID" \
  -d "text=<b>Bold</b> <i>Italic</i> <code>code</code>" \
  -d "parse_mode=HTML"
```

### Markdown Mode

```bash
curl -s -X POST "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/sendMessage" \
  -d "chat_id=CHAT_ID" \
  -d "text=*Bold* _Italic_ `code`" \
  -d "parse_mode=MarkdownV2"
```

---

## Check Result

```bash
# Response will contain message_id on success
{"ok":true,"result":{"message_id":123,"chat":{"id":...},"text":"..."}}
```

### Verify send

```bash
response=$(curl -s -X POST "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/sendMessage" \
  -d "chat_id=CHAT_ID" \
  -d "text=Test message")

echo "$response" | jq -r '.ok'
# Should output: true
```

---

## Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| 404 Not Found | Bot not in chat | Add bot to group/chat |
| 403 Forbidden | Bot blocked by user | User needs to start bot |
| 400 Bad Request | Invalid chat_id | Verify chat_id format |

---

## Execution Policy

1. **MUST check response** - Verify `ok: true` in response
2. **MUST handle errors** - Report error if send fails
3. **MUST use correct env var** - Use `EUE_TELEGRAM_TOKEN`
4. **MUST URL-encode message** - For special characters

---

## Environment Variables

- `EUE_TELEGRAM_TOKEN` - Bot token (required)
- `EUE_TELEGRAM_CHAT_ID` - Default chat ID (optional)
- `EUE_TELEGRAM_USER_ID` - Default user ID for mentions (optional)
