import os
import json
import urllib.request

icons = [
    "moon", "sun", "menu", "x", "check-circle", "clock",
    "book", "book-open", "list", "gamepad-2", "settings",
    "search", "play-circle", "chevron-left", "chevron-right",
    "check", "file-text", "star", "volume-2", "help-circle",
    "upload-cloud", "minus", "plus", "list-checks",
    "more-horizontal", "zap", "sparkles"
]

assets_dir = "Sources/ChineseStudyApp/Resources/Assets.xcassets"
os.makedirs(assets_dir, exist_ok=True)

# Add master Contents.json for xcassets
with open(os.path.join(assets_dir, "Contents.json"), "w") as f:
    json.dump({"info": {"author": "xcode", "version": 1}}, f)

for icon in icons:
    imageset_dir = os.path.join(assets_dir, f"{icon}.imageset")
    os.makedirs(imageset_dir, exist_ok=True)
    
    # Download SVG
    url = f"https://unpkg.com/lucide-static@0.424.0/icons/{icon}.svg"
    svg_path = os.path.join(imageset_dir, f"{icon}.svg")
    try:
        urllib.request.urlretrieve(url, svg_path)
    except Exception as e:
        print(f"Failed to download {icon}: {e}")
        continue
        
    # Create Contents.json
    contents = {
        "images": [
            {
                "filename": f"{icon}.svg",
                "idiom": "universal"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        },
        "properties": {
            "preserves-vector-representation": True
        }
    }
    with open(os.path.join(imageset_dir, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)

print("Downloaded all icons.")
