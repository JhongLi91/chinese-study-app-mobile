import os

for root, _, files in os.walk("Sources/ChineseStudyApp"):
    for file in files:
        if file.endswith(".swift"):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                lines = f.readlines()
            
            changed = False
            for i, line in enumerate(lines):
                if '.frame(width:' in line and line.rstrip().endswith('))'):
                    lines[i] = line.replace('))', ')')
                    changed = True
                
            if changed:
                with open(filepath, 'w') as f:
                    f.writelines(lines)
                print(f"Fixed {filepath}")
