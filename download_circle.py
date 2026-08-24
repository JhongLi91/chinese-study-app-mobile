import os
import json
import urllib.request

assets_dir = "Sources/ChineseStudyApp/Resources/Assets.xcassets"
imageset_dir = os.path.join(assets_dir, "circle.imageset")
os.makedirs(imageset_dir, exist_ok=True)

url = f"https://unpkg.com/lucide-static@0.424.0/icons/circle.svg"
svg_path = os.path.join(imageset_dir, "circle.svg")
urllib.request.urlretrieve(url, svg_path)

contents = {
    "images": [{"filename": "circle.svg", "idiom": "universal"}],
    "info": {"author": "xcode", "version": 1},
    "properties": {"preserves-vector-representation": True}
}
with open(os.path.join(imageset_dir, "Contents.json"), "w") as f:
    json.dump(contents, f, indent=2)

print("Downloaded circle icon.")
