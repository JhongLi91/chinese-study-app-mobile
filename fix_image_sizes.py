import os
import re

font_sizes = {
    r'\.largeTitle': 34,
    r'\.title\b': 28,
    r'\.title2': 22,
    r'\.title3': 20,
    r'\.headline': 17,
    r'\.subheadline': 15,
    r'\.body': 17,
    r'\.caption\b': 12,
    r'\.caption2': 11,
}

def replace_font_with_frame(content):
    # Regex to find Image(..., bundle: .module).renderingMode(.template) 
    # optionally followed by modifiers like .foregroundColor(...)
    # and eventually a .font(...) modifier.
    
    # Actually, it's easier to find Image("...", bundle: .module) and insert .resizable()
    # Then find .font(...) applied to it and replace with .frame(width: size, height: size)
    
    # First, let's just make ALL Image("...", bundle: .module) resizable and scaledToFit.
    content = re.sub(
        r'(Image\("[^"]+", bundle: \.module\))(\s*\.renderingMode\(\.template\))?',
        r'\1.resizable().scaledToFit()\2',
        content
    )
    
    # Now, we need to convert .font(...) to .frame(...)
    # Since .font(...) might be applied to Text as well, we only want to replace it 
    # if it immediately follows an Image block.
    # A better approach: search for the whole block.
    
    pattern = r'(Image\("[^"]+", bundle: \.module\)\.resizable\(\)\.scaledToFit\(\)(?:\.renderingMode\(\.template\))?(?:\s*\.[a-zA-Z0-9_\(,\)\.\s:]+)*?\s*)\.font\(\s*\.system\(size:\s*([0-9\.]+)(?:,\s*weight:\s*\.[a-zA-Z]+)?\)\s*\)'
    content = re.sub(pattern, r'\1.frame(width: \2, height: \2)', content)

    for font_name, size in font_sizes.items():
        pattern = r'(Image\("[^"]+", bundle: \.module\)\.resizable\(\)\.scaledToFit\(\)(?:\.renderingMode\(\.template\))?(?:\s*\.[a-zA-Z0-9_\(,\)\.\s:]+)*?\s*)\.font\(\s*' + font_name + r'\s*\)'
        content = re.sub(pattern, rf'\1.frame(width: {size}, height: {size})', content)
        
    return content

for root, _, files in os.walk("Sources/ChineseStudyApp"):
    for file in files:
        if file.endswith(".swift"):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            
            new_content = replace_font_with_frame(content)
            
            if new_content != content:
                with open(filepath, 'w') as f:
                    f.write(new_content)
                print(f"Updated {filepath}")

