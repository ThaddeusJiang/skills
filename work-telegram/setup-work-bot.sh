#!/bin/bash
# Work Telegram 快速设置脚本
# 用法: ./setup-work-bot.sh

set -e

echo "======================================"
echo "Work Telegram Bot 设置向导"
echo "======================================"
echo ""

# 检查是否已配置
if [ -n "$EUE_WORK_TELEGRAM_TOKEN" ]; then
    echo "✅ EUE_WORK_TELEGRAM_TOKEN 已配置"
else
    echo "⚠️  EUE_WORK_TELEGRAM_TOKEN 未配置"
    echo ""
    echo "请按以下步骤操作："
    echo "1. 打开 Telegram"
    echo "2. 搜索 @BotFather"
    echo "3. 发送 /newbot"
    echo "4. 设置名称: Amami Work Bot"
    echo "5. 设置用户名: amami_work_bot"
    echo "6. 复制返回的 token"
    echo ""
    echo "然后运行："
    echo "  export EUE_WORK_TELEGRAM_TOKEN='your_token'"
    echo "  并添加到 ~/.zshrc 或 ~/.bashrc"
    exit 1
fi

# 测试连接
echo ""
echo "🔍 测试 Work Bot 连接..."
RESPONSE=$(curl -s "https://api.telegram.org/bot${EUE_WORK_TELEGRAM_TOKEN}/getMe")
BOT_USERNAME=$(echo "$RESPONSE" | jq -r '.result.username // empty')

if [ -n "$BOT_USERNAME" ]; then
    echo "✅ Bot 连接成功: @$BOT_USERNAME"
else
    echo "❌ Bot 连接失败"
    echo "响应: $RESPONSE"
    exit 1
fi

# 获取 chat_id
echo ""
echo "📱 请向你的 Work Bot 发送一条消息，然后按回车继续..."
read -r

CHAT_ID=$(curl -s "https://api.telegram.org/bot${EUE_WORK_TELEGRAM_TOKEN}/getUpdates?limit=1&offset=-1" | jq -r '.result[0].message.chat.id // empty')

if [ -n "$CHAT_ID" ]; then
    echo "✅ Chat ID: $CHAT_ID"
    echo ""
    echo "添加到你的配置文件："
    echo "  export EUE_WORK_CHAT_ID='$CHAT_ID'"
else
    echo "⚠️  无法获取 Chat ID，请确保已向 bot 发送消息"
fi

echo ""
echo "======================================"
echo "设置完成！"
echo "======================================"
echo ""
echo "使用方法："
echo "  发消息给 @$BOT_USERNAME"
echo "  或运行: mix eue.telegram EUE_TELEGRAM_TOKEN=\$EUE_WORK_TELEGRAM_TOKEN"
