# Telegram Message Feed Skill

Forward Telegram messages to Message Queue (MQ) systems using cURL.

---

## Capability

This skill enables EUE to forward incoming Telegram messages to MQ:
- Forward Telegram messages to RabbitMQ, Kafka, Redis, SQS
- No code integration needed - uses cURL for HTTP API
- Configurable message format (JSON schema)
- Automatic configuration management

## When to Use

- Build event-driven Telegram bot pipelines
- Decouple message processing from bot logic
- Integrate Telegram with external systems
- Enable multiple consumers for Telegram events

---

## Quick Start

### 1. Configure MQ

Tell the agent your MQ configuration:
```
设置 MQ 为 RabbitMQ，地址是 amqp://guest:guest@localhost:5672
```

Agent will create config file: `.eue/config/tg-message-feed.json`

### 2. Forward Message

```bash
echo '{
  "event": "telegram.new_message",
  "chat_id": -1002246024089,
  "message_id": 42,
  "text": "Hello"
}' | .eue/skills/tg-message-feed/forward_message.sh
```

---

## Supported MQ Backends

### 1. RabbitMQ (Recommended)

**Requirements:** Management Plugin enabled
```bash
rabbitmq-plugins enable rabbitmq_management
```

**Config:**
```json
{
  "mq_type": "rabbitmq",
  "url": "amqp://guest:guest@localhost:5672/",
  "management_url": "http://localhost:15672",
  "exchange": "telegram.messages",
  "enabled": true
}
```

**Publish via cURL:**
```bash
curl -u guest:guest -X POST \
  "http://localhost:15672/api/exchanges/%2F/telegram.messages/publish" \
  -H "Content-Type: application/json" \
  -d '{
    "properties": {},
    "routing_key": "chat.-1001234567890",
    "payload": "{\"event\":\"telegram.new_message\",\"text\":\"hello\"}",
    "payload_encoding": "string"
  }'
```

### 2. Kafka

**Requirements:** kcat (formerly kafkacat)
```bash
brew install kcat
```

**Config:**
```json
{
  "mq_type": "kafka",
  "url": "localhost:9092",
  "topic": "telegram-messages",
  "enabled": true
}
```

**Publish via kcat:**
```bash
echo '{"event":"telegram.new_message","text":"hello"}' | \
  kcat -P -b localhost:9092 -t telegram-messages
```

### 3. Redis Streams

**Requirements:** redis-cli

**Config:**
```json
{
  "mq_type": "redis",
  "url": "redis://localhost:6379",
  "stream": "telegram:messages",
  "enabled": true
}
```

**Publish via redis-cli:**
```bash
redis-cli XADD telegram:messages '*' \
  event telegram.new_message \
  text "hello"
```

### 4. AWS SQS

**Requirements:** AWS CLI configured

**Config:**
```json
{
  "mq_type": "sqs",
  "url": "https://sqs.region.amazonaws.com/account/queue",
  "enabled": true
}
```

**Publish via AWS CLI:**
```bash
aws sqs send-message \
  --queue-url "$MQ_URL" \
  --message-body '{"event":"telegram.new_message","text":"hello"}'
```

---

## Message Schema

Standard JSON format:

```json
{
  "service": "eue-telegram-bridge",
  "event": "telegram.new_message",
  "chat_id": -1002246024089,
  "message_id": 42,
  "sender_id": 940788576,
  "is_bot": false,
  "sender_username": "thaddeusjiang",
  "sender_fullname": "Thaddeus Jiang",
  "text": "Hello from Telegram",
  "date": "2026-02-20T12:00:00+00:00",
  "is_reply": false,
  "reply_to": null,
  "has_media": false,
  "media": null
}
```

---

## Configuration Commands

Agent supports natural language commands:

```
用户: 设置 MQ 为 RabbitMQ，地址是 amqp://localhost:5672
Bot: ✅ 已配置 RabbitMQ

用户: 显示当前 MQ 配置
Bot: 📋 当前配置：
     - 类型: RabbitMQ
     - URL: amqp://guest:guest@localhost:5672/
     - Management: http://localhost:15672
     - Exchange: telegram.messages
     - 状态: ✅ 已启用

用户: 测试 MQ 连接
Bot: ✅ 连接成功，已发送测试消息
```

---

## Files

```
.eue/skills/tg-message-feed/
├── SKILL.md              # This documentation
└── forward_message.sh    # Message forwarding script

.eue/config/
└── tg-message-feed.json  # MQ configuration
```

---

## Integration with EUE

### Option 1: Manual Forwarding

After receiving a message, run:
```bash
.eue/skills/tg-message-feed/forward_message.sh "$MESSAGE_JSON"
```

### Option 2: Automatic Forwarding (Future)

Can be integrated into EUE's message handler:

```elixir
# lib/eue/telegram/poller.ex
def handle_message(message) do
  # Forward to MQ
  if mq_enabled?() do
    forward_to_mq(message)
  end
  
  # Normal processing...
end
```

---

## Troubleshooting

### RabbitMQ connection failed

```bash
# Check if RabbitMQ is running
docker ps | grep rabbitmq

# Check Management API
curl -u guest:guest http://localhost:15672/api/overview

# Enable Management Plugin
rabbitmq-plugins enable rabbitmq_management
```

### Exchange not found

```bash
# Create exchange
curl -u guest:guest -X PUT \
  "http://localhost:15672/api/exchanges/%2F/telegram.messages" \
  -H "Content-Type: application/json" \
  -d '{"type":"topic","durable":true}'
```

### Message not routed

```bash
# Create and bind queue
curl -u guest:guest -X PUT \
  "http://localhost:15672/api/queues/%2F/test.messages" \
  -H "Content-Type: application/json" \
  -d '{"durable":true}'

curl -u guest:guest -X POST \
  "http://localhost:15672/api/bindings/%2F/e/telegram.messages/q/test.messages" \
  -H "Content-Type: application/json" \
  -d '{"routing_key":"chat.#"}'
```

---

## Reference

Inspired by: https://github.com/frostming/tg-message-feed
