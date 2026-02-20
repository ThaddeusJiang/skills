#!/bin/bash
# Forward Telegram message to RabbitMQ
# Usage: ./forward_message.sh <message_json>

set -e

CONFIG_FILE=".eue/config/tg-message-feed.json"

# Check if config exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found: $CONFIG_FILE"
    echo "Please run: eue and ask to configure MQ"
    exit 1
fi

# Read config
MQ_TYPE=$(jq -r '.mq_type' "$CONFIG_FILE")
MQ_MANAGEMENT_URL=$(jq -r '.management_url' "$CONFIG_FILE")
MQ_EXCHANGE=$(jq -r '.exchange' "$CONFIG_FILE")
MQ_ENABLED=$(jq -r '.enabled' "$CONFIG_FILE")

if [ "$MQ_ENABLED" != "true" ]; then
    echo "MQ forwarding is disabled"
    exit 0
fi

# Parse message JSON from argument or stdin
if [ -z "$1" ]; then
    MESSAGE=$(cat)
else
    MESSAGE="$1"
fi

# Extract fields for routing key
CHAT_ID=$(echo "$MESSAGE" | jq -r '.chat_id // 0')

# Build routing key
ROUTING_KEY="chat.${CHAT_ID}"

# Escape payload for JSON
PAYLOAD=$(echo "$MESSAGE" | jq -c .)

case "$MQ_TYPE" in
    rabbitmq)
        # Extract credentials from URL
        # URL format: amqp://user:pass@host:port/
        MQ_URL=$(jq -r '.url' "$CONFIG_FILE")
        USER=$(echo "$MQ_URL" | sed -n 's|.*://\([^:]*\):.*|\1|p')
        PASS=$(echo "$MQ_URL" | sed -n 's|.*://[^:]*:\([^@]*\)@.*|\1|p')
        
        # Publish to RabbitMQ via HTTP API
        RESPONSE=$(curl -s -u "${USER}:${PASS}" \
            -X POST "${MQ_MANAGEMENT_URL}/api/exchanges/%2F/${MQ_EXCHANGE}/publish" \
            -H "Content-Type: application/json" \
            -d "{
                \"properties\": {},
                \"routing_key\": \"${ROUTING_KEY}\",
                \"payload\": $(echo "$PAYLOAD" | jq -Rs .),
                \"payload_encoding\": \"string\"
            }")
        
        ROUTED=$(echo "$RESPONSE" | jq -r '.routed // false')
        if [ "$ROUTED" = "true" ]; then
            echo "✅ Message forwarded to RabbitMQ (routing_key: ${ROUTING_KEY})"
        else
            echo "❌ Failed to forward message: $RESPONSE"
            exit 1
        fi
        ;;
    
    kafka)
        MQ_TOPIC=$(jq -r '.topic // "telegram-messages"' "$CONFIG_FILE")
        MQ_URL=$(jq -r '.url' "$CONFIG_FILE")
        
        echo "$PAYLOAD" | kcat -P -b "$MQ_URL" -t "$MQ_TOPIC"
        echo "✅ Message forwarded to Kafka (topic: ${MQ_TOPIC})"
        ;;
    
    redis)
        MQ_STREAM=$(jq -r '.stream // "telegram:messages"' "$CONFIG_FILE")
        MQ_URL=$(jq -r '.url' "$CONFIG_FILE")
        
        redis-cli -u "$MQ_URL" XADD "$MQ_STREAM" '*' \
            event telegram.new_message \
            chat_id "$CHAT_ID" \
            payload "$PAYLOAD"
        echo "✅ Message forwarded to Redis (stream: ${MQ_STREAM})"
        ;;
    
    *)
        echo "Error: Unsupported MQ type: $MQ_TYPE"
        exit 1
        ;;
esac
