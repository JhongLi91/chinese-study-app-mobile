import os
import json
import urllib.request

mappings = {
    "circle-check": "check-circle",
    "circle-play": "play-circle",
    "circle-help": "help-circle",
    "cloud-upload": "upload-cloud",
    "ellipsis": "more-horizontal"
}

assets_dir = "Sources/ChineseStudyApp/Resources/Assets.xcassets"

for new_name, old_name in mappings.items():
    imageset_dir = os.path.join(assets_dir, f"{old_name}.imageset")
    os.makedirs(imageset_dir, exist_ok=True)
    
    url = f"https://unpkg.com/lucide-static@0.424.0/icons/{new_name}.svg"
    svg_path = os.path.join(imageset_dir, f"{old_name}.svg")
    try:
        urllib.request.urlretrieve(url, svg_path)
    except Exception as e:
        print(f"Failed to download {new_name}: {e}")
        continue
        
    contents = {
        "images": [{"filename": f"{old_name}.svg", "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
        "properties": {"preserves-vector-representation": True}
    }
    with open(os.path.join(imageset_dir, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)

print("Downloaded missing icons.")
