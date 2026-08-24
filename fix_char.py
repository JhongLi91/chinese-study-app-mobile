with open("Sources/ChineseStudyApp/Features/Stories/CharacterInspectorSheet.swift", "r") as f:
    content = f.read()

content = content.replace(
    'Image(icon, bundle: .module)\n                    .renderingMode(.template)\n                    .font(.title2)',
    'Image(icon, bundle: .module).resizable().scaledToFit().renderingMode(.template)\n                    .frame(width: 22, height: 22)'
)

with open("Sources/ChineseStudyApp/Features/Stories/CharacterInspectorSheet.swift", "w") as f:
    f.write(content)
