# tg-message-feed

Forward Telegram messages to Message Queue (MQ) systems using cURL.

## Overview

This skill forwards Telegram messages to RabbitMQ (or other MQ systems) via HTTP API. It enables event-driven Telegram bot pipelines and integration with external systems.

## Requirements

- RabbitMQ with Management Plugin enabled (port 15672)
- EUE Chat ID configured

## Quick Start

### 1. Enable RabbitMQ Management Plugin

```bash
rabbitmq-plugins enable rabbitmq_management
```

### 2. Create Configuration File

Create `.eue/config/tg-message-feed.json`:

```json
{
  "mq_type": "rabbitmq",
  "url": "http://localhost:15672",
  "username": "guest",
  "password": "guest",
  "exchange": "telegram.messages",
  "enabled": true
}
```

### 3. Test Forwarding

```bash
./tg-message-feed/forward_message.sh '{"chat_id": -1002246024089, "text": "Hello World"}'
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mq_type` | MQ type (rabbitmq, kafka, redis, sqs) | `rabbitmq` |
| `url` | Management API URL | `http://localhost:15672` |
| `username` | RabbitMQ username | `guest` |
| `password` | RabbitMQ password | `guest` |
| `exchange` | Exchange name | `telegram.messages` |
| `enabled` | Enable forwarding | `true` |

## Message Format

Messages are forwarded in JSON format:

```json
{
  "event": "telegram.new_message",
  "chat_id": -1002246024089,
  "message_id": 123,
  "sender_id": 940788576,
  "sender_username": "thaddeusjiang",
  "text": "Message content",
  "timestamp": "2026-02-20T06:30:00Z"
}
```

## For AI Agents

To install this skill:

1. Clone this repository or copy the `tg-message-feed` directory
2. Place it in `.eue/skills/tg-message-feed/`
3. Create configuration file at `.eue/config/tg-message-feed.json`
4. The Agent will automatically forward messages when the skill is loaded

## Troubleshooting

### Check RabbitMQ Connection

```bash
curl -s -u guest:guest http://localhost:15672/api/overview | jq '.rabbitmq_version'
```

### Check Queue Status

```bash
curl -s -u guest:guest http://localhost:15672/api/queues | jq '.[].name'
```

### Read Messages from Queue

```bash
curl -s -u guest:guest "http://localhost:15672/api/queues/%2F/telegram.inbox/get" \
  -H "Content-Type: application/json" \
  -d '{"count":5,"ackmode":"ack_requeue_true","encoding":"auto"}' | jq '.[].payload'
```

## License

MIT
