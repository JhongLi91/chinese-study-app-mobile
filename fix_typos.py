import os
import re

for root, _, files in os.walk("Sources/ChineseStudyApp"):
    for file in files:
        if file.endswith(".swift"):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            
            new_content = re.sub(r'\.frame\(width: ([0-9\.]+), height: ([0-9\.]+)\)\)', r'.frame(width: \1, height: \2)', content)
            
            if new_content != content:
                with open(filepath, 'w') as f:
                    f.write(new_content)
                print(f"Fixed {filepath}")
