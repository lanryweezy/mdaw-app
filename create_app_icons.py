#!/usr/bin/env python3
"""
Studio Wiz App Icon Generator
Creates app icons for all platforms from a base design
"""

import os
import sys
from PIL import Image, ImageDraw, ImageFont
import math

def create_base_icon(size=1024):
    """Create a base Studio Wiz icon"""
    # Create a new image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Define colors
    primary_color = (30, 144, 255)  # Dodger Blue
    secondary_color = (255, 255, 255)  # White
    accent_color = (255, 165, 0)  # Orange
    
    # Draw background circle with gradient effect
    margin = size // 20
    circle_size = size - (margin * 2)
    
    # Create gradient effect by drawing multiple circles
    for i in range(20):
        alpha = 255 - (i * 10)
        if alpha < 0:
            alpha = 0
        color = (*primary_color, alpha)
        radius = circle_size // 2 - i
        if radius > 0:
            draw.ellipse([
                size//2 - radius, size//2 - radius,
                size//2 + radius, size//2 + radius
            ], fill=color)
    
    # Draw music note symbol
    note_size = size // 3
    note_x = size // 2
    note_y = size // 2
    
    # Draw note head (circle)
    head_radius = note_size // 6
    draw.ellipse([
        note_x - head_radius, note_y - head_radius,
        note_x + head_radius, note_y + head_radius
    ], fill=secondary_color)
    
    # Draw note stem
    stem_width = note_size // 20
    stem_height = note_size // 2
    draw.rectangle([
        note_x + head_radius - stem_width//2, note_y - head_radius,
        note_x + head_radius + stem_width//2, note_y - head_radius - stem_height
    ], fill=secondary_color)
    
    # Draw flag
    flag_points = [
        (note_x + head_radius + stem_width//2, note_y - head_radius - stem_height),
        (note_x + head_radius + stem_width//2 + note_size//4, note_y - head_radius - stem_height - note_size//8),
        (note_x + head_radius + stem_width//2, note_y - head_radius - stem_height + note_size//8)
    ]
    draw.polygon(flag_points, fill=secondary_color)
    
    # Add "W" for Studio Wiz
    try:
        font_size = size // 8
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        font = ImageFont.load_default()
    
    text = "W"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    text_x = note_x - text_width // 2
    text_y = note_y + head_radius + size // 20
    
    # Draw text with outline
    outline_width = 2
    for dx in range(-outline_width, outline_width + 1):
        for dy in range(-outline_width, outline_width + 1):
            if dx*dx + dy*dy <= outline_width*outline_width:
                draw.text((text_x + dx, text_y + dy), text, font=font, fill=accent_color)
    
    draw.text((text_x, text_y), text, font=font, fill=secondary_color)
    
    return img

def create_android_icons():
    """Create Android app icons"""
    android_sizes = [
        (48, "mipmap-mdpi"),
        (72, "mipmap-hdpi"),
        (96, "mipmap-xhdpi"),
        (144, "mipmap-xxhdpi"),
        (192, "mipmap-xxxhdpi")
    ]
    
    base_icon = create_base_icon(512)
    
    for size, folder in android_sizes:
        # Create directory if it doesn't exist
        dir_path = f"android/app/src/main/res/{folder}"
        os.makedirs(dir_path, exist_ok=True)
        
        # Resize and save
        resized = base_icon.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(f"{dir_path}/ic_launcher.png")
        print(f"Created Android icon: {size}x{size} in {folder}")

def create_ios_icons():
    """Create iOS app icons"""
    ios_sizes = [
        (20, "20x20"),
        (29, "29x29"),
        (40, "40x40"),
        (58, "58x58"),
        (60, "60x60"),
        (76, "76x76"),
        (80, "80x80"),
        (87, "87x87"),
        (114, "114x114"),
        (120, "120x120"),
        (152, "152x152"),
        (167, "167x167"),
        (180, "180x180"),
        (1024, "1024x1024")
    ]
    
    base_icon = create_base_icon(1024)
    
    for size, name in ios_sizes:
        # Create directory if it doesn't exist
        dir_path = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
        os.makedirs(dir_path, exist_ok=True)
        
        # Resize and save
        resized = base_icon.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(f"{dir_path}/icon-{name}.png")
        print(f"Created iOS icon: {size}x{size}")

def create_windows_icons():
    """Create Windows app icons"""
    base_icon = create_base_icon(256)
    
    # Save as ICO file for Windows
    base_icon.save("windows/runner/resources/app_icon.ico", format='ICO', sizes=[(16,16), (32,32), (48,48), (64,64), (128,128), (256,256)])
    print("Created Windows icon: app_icon.ico")

def create_web_icons():
    """Create web app icons"""
    web_sizes = [16, 32, 48, 64, 128, 256, 512]
    
    base_icon = create_base_icon(512)
    
    for size in web_sizes:
        resized = base_icon.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(f"web/icons/icon-{size}.png")
        print(f"Created web icon: {size}x{size}")

def main():
    """Main function to create all app icons"""
    print("🎵 Creating Studio Wiz app icons...")
    
    try:
        # Create directories
        os.makedirs("web/icons", exist_ok=True)
        
        # Create icons for all platforms
        create_android_icons()
        create_ios_icons()
        create_windows_icons()
        create_web_icons()
        
        print("✅ All app icons created successfully!")
        print("\n📱 Icons created for:")
        print("   • Android (5 sizes)")
        print("   • iOS (14 sizes)")
        print("   • Windows (ICO format)")
        print("   • Web (7 sizes)")
        
    except Exception as e:
        print(f"❌ Error creating icons: {e}")
        print("Make sure you have Pillow installed: pip install Pillow")
        sys.exit(1)

if __name__ == "__main__":
    main()
