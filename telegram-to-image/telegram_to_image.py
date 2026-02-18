#!/usr/bin/env python3
"""Generate shareable image from Telegram messages with chat-style layout."""

import sys
import json
import hashlib
from PIL import Image, ImageDraw, ImageFont

# Configuration
WIDTH = 720
PADDING = 30
BUBBLE_PADDING = 16
MAX_BUBBLE_WIDTH = 480
AVATAR_SIZE = 50
AVATAR_MARGIN = 12
LINE_HEIGHT = 28

# High contrast colors (Light theme for better readability)
BG_COLOR = "#F5F5F5"
BUBBLE_SELF_COLOR = "#DCF8C6"  # WhatsApp green for self
BUBBLE_OTHER_COLOR = "#FFFFFF"  # White for others
TEXT_COLOR = "#000000"
TEXT_LIGHT_COLOR = "#333333"
SHADOW_COLOR = "#E0E0E0"

# Avatar colors (pastel palette)
AVATAR_COLORS = [
    "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", 
    "#FFEAA7", "#DDA0DD", "#98D8C8", "#F7DC6F",
    "#BB8FCE", "#85C1E9", "#F8B500", "#00CED1"
]


def get_avatar_color(name):
    """Get consistent avatar color based on name hash."""
    hash_val = int(hashlib.md5(name.encode()).hexdigest(), 16)
    return AVATAR_COLORS[hash_val % len(AVATAR_COLORS)]


def draw_avatar(draw, x, y, name, size=AVATAR_SIZE):
    """Draw circular avatar with initials."""
    # Draw circle
    color = get_avatar_color(name)
    draw.ellipse([x, y, x + size, y + size], fill=color)
    
    # Draw initials
    initials = ""
    words = name.split()
    for word in words[:2]:
        if word:
            initials += word[0].upper()
    if not initials:
        initials = "?"
    
    # Center text in avatar
    try:
        font = ImageFont.truetype("/System/Library/Fonts/STHeiti Light.ttc", int(size * 0.4))
    except:
        font = ImageFont.load_default()
    
    bbox = font.getbbox(initials)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    text_x = x + (size - text_width) // 2
    text_y = y + (size - text_height) // 2 - 2
    
    draw.text((text_x, text_y), initials, fill="#FFFFFF", font=font)


def wrap_text(text, font, max_width):
    """Wrap text to fit within max_width."""
    lines = []
    # Handle Chinese characters - wrap by character
    current_line = ""
    
    for char in text:
        test_line = current_line + char
        bbox = font.getbbox(test_line)
        if bbox[2] - bbox[0] <= max_width:
            current_line = test_line
        else:
            if current_line:
                lines.append(current_line)
            current_line = char
    
    if current_line:
        lines.append(current_line)
    
    return lines if lines else [""]


def draw_bubble(draw, x, y, width, height, is_self, radius=18):
    """Draw chat bubble with tail."""
    # Shadow
    shadow_offset = 2
    draw.rounded_rectangle(
        [x + shadow_offset, y + shadow_offset, x + width + shadow_offset, y + height + shadow_offset],
        radius=radius,
        fill=SHADOW_COLOR
    )
    
    # Main bubble
    bubble_color = BUBBLE_SELF_COLOR if is_self else BUBBLE_OTHER_COLOR
    draw.rounded_rectangle(
        [x, y, x + width, y + height],
        radius=radius,
        fill=bubble_color,
        outline="#E0E0E0",
        width=1
    )
    
    # Tail (small triangle)
    tail_size = 8
    if is_self:
        # Tail on right
        tail_points = [
            (x + width - 5, y + 15),
            (x + width + tail_size, y + 15 + tail_size),
            (x + width - 5, y + 15 + tail_size * 2)
        ]
    else:
        # Tail on left
        tail_points = [
            (x + 5, y + 15),
            (x - tail_size, y + 15 + tail_size),
            (x + 5, y + 15 + tail_size * 2)
        ]
    
    draw.polygon(tail_points, fill=bubble_color)


def generate_image(messages, output_path):
    """Generate image from messages list with chat layout."""
    # Load fonts
    try:
        font = ImageFont.truetype("/System/Library/Fonts/STHeiti Light.ttc", 20)
        font_name = ImageFont.truetype("/System/Library/Fonts/STHeiti Light.ttc", 14)
    except:
        font = ImageFont.load_default()
        font_name = font
    
    # Detect unique senders and assign self/other
    senders = list(dict.fromkeys(msg.get('sender', 'Unknown') for msg in messages))
    # Assume first sender is "self" (the user forwarding messages)
    self_sender = senders[0] if senders else "Me"
    
    # Calculate total height needed
    total_height = PADDING
    message_data = []
    
    for msg in messages:
        text = msg.get('text', '')
        sender = msg.get('sender', 'Unknown')
        is_self = (sender == self_sender)
        
        # Calculate bubble dimensions
        lines = wrap_text(text, font, MAX_BUBBLE_WIDTH - 2 * BUBBLE_PADDING)
        bubble_width = max(100, min(MAX_BUBBLE_WIDTH, 
                           max(font.getbbox(line)[2] - font.getbbox(line)[0] for line in lines) + 2 * BUBBLE_PADDING))
        bubble_height = len(lines) * LINE_HEIGHT + 2 * BUBBLE_PADDING
        
        message_data.append({
            'text': text,
            'sender': sender,
            'is_self': is_self,
            'lines': lines,
            'bubble_width': bubble_width,
            'bubble_height': bubble_height
        })
        
        total_height += bubble_height + 20
    
    total_height += PADDING
    
    # Create image
    img = Image.new('RGB', (WIDTH, total_height), BG_COLOR)
    draw = ImageDraw.Draw(img)
    
    # Draw header
    try:
        font_header = ImageFont.truetype("/System/Library/Fonts/STHeiti Light.ttc", 16)
    except:
        font_header = font
    header_text = f"💬 Telegram Chat ({len(messages)} messages)"
    draw.text((PADDING, 12), header_text, fill="#666666", font=font_header)
    
    # Draw messages
    y = PADDING + 10
    
    for data in message_data:
        is_self = data['is_self']
        bubble_width = data['bubble_width']
        bubble_height = data['bubble_height']
        lines = data['lines']
        sender = data['sender']
        
        if is_self:
            # Right side for self
            avatar_x = WIDTH - PADDING - AVATAR_SIZE
            bubble_x = WIDTH - PADDING - AVATAR_SIZE - AVATAR_MARGIN - bubble_width
        else:
            # Left side for others
            avatar_x = PADDING
            bubble_x = PADDING + AVATAR_SIZE + AVATAR_MARGIN
        
        # Draw avatar
        draw_avatar(draw, avatar_x, y + (bubble_height - AVATAR_SIZE) // 2, sender)
        
        # Draw bubble
        draw_bubble(draw, bubble_x, y, bubble_width, bubble_height, is_self)
        
        # Draw sender name (only for others)
        if not is_self:
            draw.text((bubble_x + BUBBLE_PADDING, y + 4), sender, 
                     fill="#666666", font=font_name)
        
        # Draw text
        text_y = y + BUBBLE_PADDING + (16 if not is_self else 0)
        for line in lines:
            draw.text((bubble_x + BUBBLE_PADDING, text_y), line, 
                     fill=TEXT_COLOR, font=font)
            text_y += LINE_HEIGHT
        
        y += bubble_height + 20
    
    # Save image
    img.save(output_path, 'PNG', quality=95)
    return output_path


if __name__ == '__main__':
    # Read messages from stdin as JSON
    messages = json.load(sys.stdin)
    output = sys.argv[1] if len(sys.argv) > 1 else '/tmp/telegram_messages.png'
    
    generate_image(messages, output)
    print(output)
