with open("Sources/ChineseStudyApp/Features/Dictionary/DictionarySearchView.swift", "r") as f:
    content = f.read()

content = content.replace(
    'Image(character.status.systemImage, bundle: .module)\n                        .renderingMode(.template)',
    'Image(character.status.systemImage, bundle: .module).resizable().scaledToFit().renderingMode(.template)\n                        .frame(width: 17, height: 17)'
)

with open("Sources/ChineseStudyApp/Features/Dictionary/DictionarySearchView.swift", "w") as f:
    f.write(content)
