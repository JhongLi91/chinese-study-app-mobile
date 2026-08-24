import os

for root, _, files in os.walk("Sources/ChineseStudyApp"):
    for file in files:
        if file.endswith(".swift"):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                lines = f.readlines()
                
            for i, line in enumerate(lines):
                if 'bundle: .module)' in line:
                    has_frame = False
                    for j in range(i, min(i+4, len(lines))):
                        if '.frame(width:' in lines[j] or '.frame(maxWidth:' in lines[j]:
                            has_frame = True
                            break
                        if 'Text(' in lines[j] and j > i:
                            break
                    if not has_frame:
                        print(f"Missing frame: {filepath}:{i+1}")
                        print(line.strip())

