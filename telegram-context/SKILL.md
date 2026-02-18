# Telegram Context Skill

Extract sender and chat information from Telegram messages for bot responses.

## Capability

This skill explains how to get:
- **user_id** - The Telegram user ID of the message sender
- **chat_id** - The chat/conversation ID
- **group_id** - The group/supergroup ID (same as chat_id for groups)
- **username** - The sender's Telegram username (if set)
- **message_id** - For replying to specific messages

## When to Use

- Bot needs to reply with @mention to the sender
- Need to track who sent a command
- Store user preferences by user_id
- Send targeted messages to specific users

---

## Telegram Update Structure

Every message sent to a bot contains this structure:

```json
{
  "update_id": 12345,
  "message": {
    "message_id": 1,
    "from": {
      "id": 940788576,
      "is_bot": false,
      "first_name": "Amami",
      "last_name": "EUE",
      "username": "amami_eue",
      "language_code": "en"
    },
    "chat": {
      "id": -1002246024089,
      "title": "Eue 成长记录",
      "type": "supergroup"
    },
    "date": 1234567890,
    "text": "hello"
  }
}
```

### Key Fields

| Field | Path | Description |
|-------|------|-------------|
| user_id | `message.from.id` | Sender's unique Telegram ID |
| username | `message.from.username` | Sender's @username (may be null) |
| first_name | `message.from.first_name` | Sender's first name |
| chat_id | `message.chat.id` | Chat/conversation ID |
| chat_type | `message.chat.type` | "private", "group", "supergroup", "channel" |
| group_title | `message.chat.title` | Group name (only for groups) |
| message_id | `message.message_id` | For reply_to_message_id |

---

## How Bot Receives Updates

### 1. Webhook (Recommended for Production)

Bot receives POST requests to your server:

```bash
# Set webhook
curl -X POST "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/setWebhook" \
  -d "url=https://your-server.com/webhook"
```

### 2. getUpdates (For Development/Testing)

Poll for new messages:

```bash
curl -s "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/getUpdates" | jq
```

Example output:
```json
{
  "ok": true,
  "result": [
    {
      "update_id": 12345,
      "message": {
        "from": {"id": 940788576, "username": "amami_eue"},
        "chat": {"id": -1002246024089, "type": "supergroup"},
        "text": "@amami_euebot 5分钟后提醒我"
      }
    }
  ]
}
```

---

## Replying with @Mention

To mention a user in a message:

### Method 1: Using username (if available)

```bash
curl -X POST "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/sendMessage" \
  -d "chat_id=-1002246024089" \
  -d "text=@amami_eue 5分钟后提醒你睡觉！ ⏰" \
  -d "parse_mode=HTML"
```

### Method 2: Using HTML mention (works even without username)

```bash
# Use user_id with HTML formatting
curl -X POST "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/sendMessage" \
  -d "chat_id=-1002246024089" \
  -d "text=<a href=\"tg://user?id=940788576\">Amami</a> 5分钟后提醒你睡觉！ ⏰" \
  -d "parse_mode=HTML"
```

### Method 3: Reply to message (creates thread)

```bash
curl -X POST "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/sendMessage" \
  -d "chat_id=-1002246024089" \
  -d "text=5分钟后提醒你睡觉！ ⏰" \
  -d "reply_to_message_id=123"
```

---

## Quick Commands

### Get latest messages

```bash
curl -s "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/getUpdates?limit=5&offset=-5" | jq '.result[].message | {from: .from, chat: .chat, text: .text}'
```

### Extract user_id from latest message

```bash
curl -s "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/getUpdates?limit=1&offset=-1" | jq -r '.result[0].message.from.id'
```

### Extract chat_id from latest message

```bash
curl -s "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/getUpdates?limit=1&offset=-1" | jq -r '.result[0].message.chat.id'
```

### Get all recent senders

```bash
curl -s "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/getUpdates" | jq '.result[].message.from | {id, username, first_name}' | uniq
```

---

## For EUE Bot Implementation

When receiving a command like `@amami_euebot 5分钟后提醒我`:

1. **Parse the update** to extract:
   - `user_id = message.from.id` (e.g., 940788576)
   - `chat_id = message.chat.id` (e.g., -1002246024089)
   - `username = message.from.username` (e.g., amami_eue)
   - `first_name = message.from.first_name` (e.g., Amami)

2. **Store in context** for the session:
   ```
   telegram_user_id: 940788576
   telegram_chat_id: -1002246024089
   telegram_username: amami_eue
   ```

3. **Send reminder with mention**:
   ```bash
   text="<a href=\"tg://user?id=${telegram_user_id}\">${first_name}</a> 该睡觉了！😴"
   curl -X POST "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/sendMessage" \
     -d "chat_id=${telegram_chat_id}" \
     -d "text=${text}" \
     -d "parse_mode=HTML"
   ```

---

## Execution Policy

1. **Poll getUpdates** to get recent message context when needed
2. **Extract sender info** using jq from the API response
3. **Use HTML mentions** for reliable @mentions (works without username)
4. **Cache user info** when possible to reduce API calls
5. **Handle missing username** - fall back to first_name or user_id

---

## Environment Variables

- `EUE_TELEGRAM_TOKEN` - Bot token from @BotFather
- `EUE_TELEGRAM_USER_ID` - (Optional) Cached default user ID
- `EUE_TELEGRAM_CHAT_ID` - (Optional) Cached default chat ID

---

## Notes

- Private chats: `chat_id` = `user_id` (same value)
- Groups: `chat_id` is negative (e.g., -1002246024089)
- Supergroups: `chat_id` starts with -100
- Channels: Bot must be admin to read messages
- Username may be `null` if user hasn't set one
