import os

for root, _, files in os.walk("Sources/ChineseStudyApp"):
    for file in files:
        if file.endswith(".swift"):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            
            # Replace .resizable().scaledToFit().renderingMode(.template)
            # with .resizable().renderingMode(.template).scaledToFit()
            
            new_content = content.replace(
                '.resizable().scaledToFit().renderingMode(.template)',
                '.resizable().renderingMode(.template).scaledToFit()'
            )
            
            # Just in case we have some other combinations
            new_content = new_content.replace(
                '.renderingMode(.template).resizable().scaledToFit()',
                '.resizable().renderingMode(.template).scaledToFit()'
            )
            
            if new_content != content:
                with open(filepath, 'w') as f:
                    f.write(new_content)
                print(f"Fixed {filepath}")

