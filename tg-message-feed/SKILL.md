# Message Queue Skill

Forward Telegram messages to Message Queue (MQ) systems like RabbitMQ, Kafka, Redis, etc.

---

## Capability

This skill enables EUE to act as a Telegram-to-MQ bridge:
- Forward incoming Telegram messages to MQ
- Support multiple MQ backends (RabbitMQ, Kafka, Redis, SQS, etc.)
- Configurable message format (JSON schema)
- Optional message filtering and routing

## When to Use

- Build event-driven Telegram bot pipelines
- Decouple message processing from bot logic
- Integrate Telegram with external systems
- Enable multiple consumers for Telegram events

---

## ⚠️ Prerequisites

Before using this skill, you need:

1. **MQ URL and credentials** - Agent will prompt user if not configured
2. **MQ type selection** - RabbitMQ, Kafka, Redis, SQS, etc.

Agent will automatically ask for these when needed:
```
Bot: 请提供 MQ 配置信息：
     - MQ 类型: (rabbitmq / kafka / redis / sqs)
     - URL: (例如: amqp://user:pass@host:5672)
     - Token/密码: (如果需要)
```

---

## Supported MQ Backends

### 1. RabbitMQ

```bash
# Environment variables
MQ_TYPE=rabbitmq
MQ_URL=amqp://user:password@localhost:5672
MQ_EXCHANGE=telegram.messages
MQ_ROUTING_KEY=chat:{chat_id}
```

**Publish command:**
```bash
curl -s -u guest:guest -X POST "http://localhost:15672/api/exchanges/%2F/telegram.messages/publish" \
  -H "Content-Type: application/json" \
  -d '{
    "properties": {},
    "routing_key": "chat:-1001234567890",
    "payload": "{\"event\":\"telegram.new_message\",\"chat_id\":-1001234567890,\"text\":\"hello\"}",
    "payload_encoding": "string"
  }'
```

### 2. Kafka

```bash
# Environment variables
MQ_TYPE=kafka
MQ_URL=localhost:9092
MQ_TOPIC=telegram-messages
MQ_API_KEY=optional_api_key
MQ_API_SECRET=optional_api_secret
```

**Publish command (using kafkacat/kcat):**
```bash
echo '{
  "event": "telegram.new_message",
  "chat_id": -1001234567890,
  "message_id": 42,
  "text": "hello",
  "date": "2026-02-20T12:00:00Z"
}' | kcat -P -b localhost:9092 -t telegram-messages
```

### 3. Redis (Streams)

```bash
# Environment variables
MQ_TYPE=redis
MQ_URL=redis://localhost:6379
MQ_STREAM=telegram:messages
```

**Publish command:**
```bash
redis-cli XADD telegram:messages '*' \
  event telegram.new_message \
  chat_id -1001234567890 \
  text "hello"
```

### 4. AWS SQS

```bash
# Environment variables
MQ_TYPE=sqs
MQ_URL=https://sqs.region.amazonaws.com/account/queue
MQ_AWS_ACCESS_KEY=AKIA...
MQ_AWS_SECRET_KEY=...
MQ_AWS_REGION=ap-northeast-1
```

**Publish command:**
```bash
aws sqs send-message \
  --queue-url "$MQ_URL" \
  --message-body '{"event":"telegram.new_message","chat_id":-1001234567890,"text":"hello"}'
```

---

## Message Schema

Standard message format (JSON):

```json
{
  "service": "eue-telegram-bridge",
  "event": "telegram.new_message",
  "chat_id": -1001234567890,
  "message_id": 42,
  "sender_id": 10001,
  "is_bot": false,
  "sender_username": "alice",
  "sender_fullname": "Alice Chen",
  "text": "hello",
  "date": "2026-02-20T12:00:00+00:00",
  "is_reply": false,
  "reply_to": null,
  "has_media": false,
  "media": null,
  "out": false
}
```

---

## Configuration Commands

Agent supports these natural language commands:

```
用户: 设置 MQ 为 RabbitMQ，地址是 amqp://localhost:5672
Bot: ✅ 已配置 RabbitMQ
     URL: amqp://localhost:5672
     Exchange: telegram.messages

用户: 显示当前 MQ 配置
Bot: 📋 当前配置：
     - 类型: RabbitMQ
     - URL: amqp://localhost:5672
     - Exchange: telegram.messages
     - 状态: 已连接

用户: 测试 MQ 连接
Bot: ✅ 连接成功，已发送测试消息
```

---

## Workflow

### 1. On Message Received

When agent receives a Telegram message:

```elixir
# Pseudocode for integration
def handle_message(message) do
  # Step 1: Process message normally
  process_with_ai(message)
  
  # Step 2: Forward to MQ (if configured)
  if mq_enabled?() do
    forward_to_mq(message)
  end
end
```

### 2. Forward Logic

```bash
# 1. Build JSON payload
PAYLOAD=$(cat <<EOF
{
  "event": "telegram.new_message",
  "chat_id": $CHAT_ID,
  "message_id": $MESSAGE_ID,
  "sender_id": $SENDER_ID,
  "text": "$TEXT",
  "date": "$(date -Iseconds)"
}
EOF
)

# 2. Publish to MQ based on type
case $MQ_TYPE in
  rabbitmq) publish_to_rabbitmq "$PAYLOAD" ;;
  kafka)    publish_to_kafka "$PAYLOAD" ;;
  redis)    publish_to_redis "$PAYLOAD" ;;
  sqs)      publish_to_sqs "$PAYLOAD" ;;
esac
```

---

## Feature Flags

Control MQ behavior per chat:

```bash
# Enable/disable MQ forwarding
用户: 开启消息转发到 MQ
用户: 关闭消息转发到 MQ

# Filter messages
用户: 只转发包含"告警"的消息
用户: 转发所有消息
```

---

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `MQ_TYPE` | MQ backend type (rabbitmq/kafka/redis/sqs) | Yes |
| `MQ_URL` | Connection URL | Yes |
| `MQ_TOKEN` | API token/key (if needed) | Optional |
| `MQ_EXCHANGE` | Exchange name (RabbitMQ) | Optional |
| `MQ_TOPIC` | Topic name (Kafka) | Optional |
| `MQ_STREAM` | Stream name (Redis) | Optional |
| `MQ_ENABLED` | Enable/disable forwarding | Optional (default: true) |

---

## Execution Policy

1. **MUST prompt user** for MQ URL and credentials if not configured
2. **MUST validate connection** before forwarding messages
3. **MUST handle errors gracefully** - Don't block message processing if MQ fails
4. **MUST log all forwarded messages** for debugging
5. **MUST support multiple MQ types** - Don't hardcode to one backend
6. **MAY compress large messages** - If text > 1MB, compress before sending

---

## Error Handling

```bash
# Retry logic
for i in 1 2 3; do
  if publish_to_mq "$PAYLOAD"; then
    echo "✅ Message forwarded to MQ"
    break
  else
    echo "⚠️ Attempt $i failed, retrying..."
    sleep $((i * 2))
  fi
done

# Fallback: Save to local queue if MQ unavailable
if [ $? -ne 0 ]; then
  echo "$PAYLOAD" >> /tmp/mq_failed_queue.jsonl
  echo "❌ MQ unavailable, saved to local queue"
fi
```

---

## Example Usage

### Scenario: Forward all messages to RabbitMQ

```
用户: 设置 MQ 为 RabbitMQ，地址是 amqp://admin:pass@192.168.1.100:5672

Bot: ✅ 已配置 RabbitMQ
     URL: amqp://admin:***@192.168.1.100:5672
     Exchange: telegram.messages
     
     是否开启消息转发？
     
用户: 是

Bot: ✅ 消息转发已开启
     之后收到的所有消息都会转发到 RabbitMQ
```

### Scenario: Kafka with authentication

```
用户: 设置 MQ 为 Kafka
     地址: pkc-xxxx.us-east-1.aws.confluent.cloud:9092
     API Key: ABC123
     API Secret: XYZ789

Bot: ✅ 已配置 Kafka (Confluent Cloud)
     Topic: telegram-messages
     认证: SASL/PLAIN
     
     连接测试中...
     ✅ 连接成功
```

---

## Notes

- MQ forwarding is **asynchronous** - Won't block message processing
- **Idempotent** - Duplicate messages have same message_id
- **Ordered** - Messages from same chat maintain order (Kafka partition key = chat_id)
- **Secure** - Credentials stored in environment, not in code

---

## Reference

Inspired by: https://github.com/frostming/tg-message-feed

Key differences:
- Bot API instead of Userbot (no session string needed)
- Multiple MQ backends support
- Natural language configuration
- Optional message forwarding (not mandatory)
