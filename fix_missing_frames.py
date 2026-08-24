import os

sizes = {
    'check-circle': 16,
    'clock': 16,
    'zap': 16,
    'chevron-right': 16,
    'minus': 20,
    'plus': 20,
    'upload-cloud': 20,
    'list-checks': 20,
    'more-horizontal': 24,
    'search': 18,
    'x': 18,
    'play-circle': 24,
    'volume-2': 24,
}

for root, _, files in os.walk("Sources/ChineseStudyApp"):
    for file in files:
        if file.endswith(".swift"):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                lines = f.readlines()
                
            changed = False
            for i, line in enumerate(lines):
                if 'bundle: .module).resizable().renderingMode(.template).scaledToFit()' in line:
                    has_frame = False
                    for j in range(i, min(i+6, len(lines))):
                        if '.frame(width:' in lines[j] or '.frame(maxWidth:' in lines[j]:
                            has_frame = True
                            break
                        if 'Text(' in lines[j] and j > i:
                            break
                    if not has_frame:
                        # Extract the image name
                        import re
                        m = re.search(r'Image\("([^"]+)"', line)
                        size = 20
                        if m:
                            icon_name = m.group(1)
                            size = sizes.get(icon_name, 20)
                        
                        lines[i] = line.replace('.scaledToFit()', f'.scaledToFit()\n{" " * (len(line) - len(line.lstrip()))}.frame(width: {size}, height: {size})')
                        changed = True
                
            if changed:
                with open(filepath, 'w') as f:
                    f.writelines(lines)
                print(f"Fixed {filepath}")

