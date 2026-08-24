import os
import re

font_sizes = {
    '.largeTitle': '34',
    '.title': '28',
    '.title2': '22',
    '.title3': '20',
    '.headline': '17',
    '.subheadline': '15',
    '.body': '17',
    '.caption': '12',
    '.caption2': '11',
}

for root, _, files in os.walk("Sources/ChineseStudyApp"):
    for file in files:
        if file.endswith(".swift"):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                lines = f.readlines()
                
            changed = False
            i = 0
            while i < len(lines):
                line = lines[i]
                if 'Image("' in line and 'bundle: .module' in line:
                    # Insert .resizable().scaledToFit() if not there
                    if '.resizable()' not in line:
                        lines[i] = line.replace(', bundle: .module)', ', bundle: .module).resizable().scaledToFit()')
                        changed = True
                    
                    # Look ahead up to 3 lines for .font()
                    for j in range(i, min(i+4, len(lines))):
                        if '.font(' in lines[j] and 'Text(' not in lines[j] and 'Button' not in lines[j]:
                            # Check system size
                            m = re.search(r'\.font\(\s*\.system\(size:\s*([0-9\.]+)', lines[j])
                            if m:
                                size = m.group(1)
                                lines[j] = re.sub(r'\.font\([^)]+\)', f'.frame(width: {size}, height: {size})', lines[j])
                                changed = True
                                break
                            
                            # Check named fonts
                            matched = False
                            for fname, size in font_sizes.items():
                                if fname in lines[j]:
                                    lines[j] = re.sub(r'\.font\([^)]+\)', f'.frame(width: {size}, height: {size})', lines[j])
                                    changed = True
                                    matched = True
                                    break
                            if matched:
                                break
                i += 1
                
            if changed:
                with open(filepath, 'w') as f:
                    f.writelines(lines)
                print(f"Updated {filepath}")

