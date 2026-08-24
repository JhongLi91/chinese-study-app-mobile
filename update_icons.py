import os
from PIL import Image

src_img_path = "/Users/jhli/.gemini/antigravity-cli/brain/e19b5f26-1801-4be3-9d06-324f63d62153/chinese_study_app_icon_1787536308151.jpg"
img = Image.open(src_img_path).convert("RGBA")

# iOS App Icon sizes
ios_dir = "Darwin/Assets.xcassets/AppIcon.appiconset"
if not os.path.exists(ios_dir):
    os.makedirs(ios_dir)

ios_sizes = {
    "1024.png": 1024,
    "120.png": 120,
    "128.png": 128,
    "152.png": 152,
    "167.png": 167,
    "16.png": 16,
    "180.png": 180,
    "20.png": 20,
    "256.png": 256,
    "29.png": 29,
    "32.png": 32,
    "40.png": 40,
    "512.png": 512,
    "58.png": 58,
    "60.png": 60,
    "64.png": 64,
    "76.png": 76,
    "80.png": 80,
    "87.png": 87
}

for name, size in ios_sizes.items():
    resized = img.resize((size, size), Image.Resampling.LANCZOS)
    resized.save(os.path.join(ios_dir, name))

print("iOS icons updated.")

# Android Mipmap sizes
android_res_dir = "Android/app/src/main/res"
android_sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192
}

for folder, size in android_sizes.items():
    folder_path = os.path.join(android_res_dir, folder)
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
    
    resized = img.resize((size, size), Image.Resampling.LANCZOS)
    
    # Save as ic_launcher.png and ic_launcher_foreground.png
    resized.save(os.path.join(folder_path, "ic_launcher.png"))
    resized.save(os.path.join(folder_path, "ic_launcher_foreground.png"))
    resized.save(os.path.join(folder_path, "ic_launcher_round.png"))

print("Android icons updated.")
