# Telegram to Image Skill

Convert multiple Telegram messages into a shareable image.

## Capability

This skill creates beautiful images from Telegram messages:
- Extract text from forwarded messages
- Generate styled image with message bubbles
- Support multiple messages in one image
- Auto-send generated image back to chat

## When to Use

- User forwards multiple messages and asks to generate image
- User wants to share chat history as image
- Create visual summary of conversations

---

## Requirements

- Python 3 with Pillow library
- `EUE_TELEGRAM_TOKEN` environment variable

## Installation

```bash
pip3 install Pillow
```

---

## How It Works

1. User forwards messages to bot
2. Bot extracts text content from forwarded messages
3. Python script generates styled image:
   - Message bubbles with rounded corners
   - Sender names and timestamps
   - Dark/light theme support
4. Bot sends image back to chat

---

## Implementation

### Step 1: Get Forwarded Messages

When user forwards messages, extract content:

```bash
curl -s "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/getUpdates?limit=10" | jq '.result[] | select(.message.forward_from or .message.forward_from_chat) | {text: .message.text, from: .message.forward_from, from_chat: .message.forward_from_chat, date: .message.forward_date}'
```

### Step 2: Generate Image

Create Python script at `~/.eue/scripts/telegram_to_image.py`:

```python
#!/usr/bin/env python3
"""Generate shareable image from Telegram messages."""

import sys
import json
from PIL import Image, ImageDraw, ImageFont

# Configuration
WIDTH = 800
PADDING = 40
BUBBLE_PADDING = 20
MAX_BUBBLE_WIDTH = WIDTH - 2 * PADDING

# Colors (Dark theme)
BG_COLOR = "#1a1a2e"
BUBBLE_COLOR = "#16213e"
TEXT_COLOR = "#eaeaea"
ACCENT_COLOR = "#0f3460"

def create_bubble(draw, x, y, width, height, radius=15):
    """Draw rounded rectangle bubble."""
    draw.rounded_rectangle(
        [x, y, x + width, y + height],
        radius=radius,
        fill=BUBBLE_COLOR,
        outline=ACCENT_COLOR,
        width=2
    )

def wrap_text(text, font, max_width):
    """Wrap text to fit within max_width."""
    lines = []
    words = text.split()
    current_line = ""
    
    for word in words:
        test_line = current_line + " " + word if current_line else word
        bbox = font.getbbox(test_line)
        if bbox[2] - bbox[0] <= max_width:
            current_line = test_line
        else:
            if current_line:
                lines.append(current_line)
            current_line = word
    
    if current_line:
        lines.append(current_line)
    
    return lines

def generate_image(messages, output_path):
    """Generate image from messages list."""
    # Load font (fallback to default if not found)
    try:
        font = ImageFont.truetype("/System/Library/Fonts/STHeiti Light.ttc", 24)
        font_small = ImageFont.truetype("/System/Library/Fonts/STHeiti Light.ttc", 18)
    except:
        font = ImageFont.load_default()
        font_small = font
    
    # Calculate total height needed
    total_height = PADDING
    message_heights = []
    
    for msg in messages:
        text = msg.get('text', '')
        sender = msg.get('sender', 'Unknown')
        
        # Calculate text height
        lines = wrap_text(f"{sender}: {text}", font, MAX_BUBBLE_WIDTH - 2 * BUBBLE_PADDING)
        text_height = len(lines) * 32 + 2 * BUBBLE_PADDING
        message_heights.append(text_height)
        total_height += text_height + 20
    
    total_height += PADDING
    
    # Create image
    img = Image.new('RGB', (WIDTH, total_height), BG_COLOR)
    draw = ImageDraw.Draw(img)
    
    # Draw messages
    y = PADDING
    for i, msg in enumerate(messages):
        text = msg.get('text', '')
        sender = msg.get('sender', 'Unknown')
        
        height = message_heights[i]
        
        # Draw bubble
        create_bubble(draw, PADDING, y, MAX_BUBBLE_WIDTH, height)
        
        # Draw text
        lines = wrap_text(f"{sender}: {text}", font, MAX_BUBBLE_WIDTH - 2 * BUBBLE_PADDING)
        text_y = y + BUBBLE_PADDING
        for line in lines:
            draw.text((PADDING + BUBBLE_PADDING, text_y), line, fill=TEXT_COLOR, font=font)
            text_y += 32
        
        y += height + 20
    
    # Save image
    img.save(output_path, 'PNG')
    return output_path

if __name__ == '__main__':
    # Read messages from stdin as JSON
    messages = json.load(sys.stdin)
    output = sys.argv[1] if len(sys.argv) > 1 else '/tmp/telegram_messages.png'
    
    generate_image(messages, output)
    print(output)
```

### Step 3: Execute Flow

```bash
# 1. Get recent forwarded messages
MESSAGES=$(curl -s "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/getUpdates?limit=10" | jq '[.result[] | select(.message.forward_from or .message.forward_from_chat or .message.text) | {text: .message.text, sender: (.message.forward_from.first_name // .message.from.first_name // "Unknown")}] | .[-5:]')

# 2. Generate image
echo "$MESSAGES" | python3 ~/.eue/scripts/telegram_to_image.py /tmp/telegram_messages.png

# 3. Send image
curl -s -X POST "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/sendPhoto" \
  -F "chat_id=-1002246024089" \
  -F "photo=@/tmp/telegram_messages.png" \
  -F "caption=Generated from your messages 📸"
```

---

## Usage Examples

### User forwards 3 messages and says:

> @amami_euebot 生成图片

### Bot response:

1. Extract the 3 forwarded messages
2. Generate styled image
3. Send image back: "生成完成！📸"

---

## Advanced Features (Future)

- Theme selection (dark/light/custom)
- Custom colors and fonts
- Add timestamp to each message
- Support for emoji and special characters
- Multiple layout options (chat style, list style)

---

## Execution Policy

1. **Detect forwarded messages** - Check `forward_from` or `forward_from_chat` fields
2. **Extract text content** - Get message text and sender info
3. **Generate image** - Use Python Pillow to create styled image
4. **Send result** - Use `sendPhoto` API to send image
5. **Clean up** - Remove temporary image file after sending

---

## Environment Variables

- `EUE_TELEGRAM_TOKEN` - Bot token (required)
- `EUE_TELEGRAM_CHAT_ID` - Default chat ID (optional)
