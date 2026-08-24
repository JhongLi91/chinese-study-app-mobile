import os
import re

mapping = {
    "line.3.horizontal": "menu",
    "checkmark.circle.fill": "check-circle",
    "clock.fill": "clock",
    "xmark": "x",
    "book": "book",
    "list.bullet": "list",
    "book.closed.fill": "book",
    "gamecontroller.fill": "gamepad-2",
    "gear": "settings",
    "moon.fill": "moon",
    "sun.max.fill": "sun",
    "speaker.fill": "volume-2",
    "magnifyingglass": "search",
    "play.circle.fill": "play-circle",
    "xmark.circle.fill": "x",
    "chevron.left.circle.fill": "chevron-left",
    "chevron.right.circle.fill": "chevron-right",
    "checkmark": "check",
    "doc.text": "file-text",
    "star.fill": "star",
    "star": "star",
    "speaker.wave.2.fill": "volume-2",
    "chevron.right": "chevron-right",
    "questionmark.circle": "help-circle",
    "arrow.up.doc": "upload-cloud",
    "minus": "minus",
    "plus": "plus",
    "checklist": "list-checks",
    "ellipsis.circle": "more-horizontal",
    "bolt.fill": "zap",
    "sparkles": "sparkles"
}

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    original = content
    for sysname, lucide in mapping.items():
        # Replace explicit strings
        content = re.sub(rf'Image\(\s*systemName\s*:\s*"{sysname}"\s*\)', f'Image("{lucide}", bundle: .module).renderingMode(.template)', content)
    
    if original != content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, _, files in os.walk("Sources/ChineseStudyApp"):
    for file in files:
        if file.endswith(".swift"):
            process_file(os.path.join(root, file))

