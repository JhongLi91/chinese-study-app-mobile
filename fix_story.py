with open("Sources/ChineseStudyApp/Features/Stories/StoryQuizView.swift", "r") as f:
    content = f.read()

content = content.replace(
    'Image(systemName: storyViewModel.quizScore == story.questions.count ? "star.fill" : "star.fill")\n                            .font(.system(size: 64))',
    'Image("star", bundle: .module).resizable().scaledToFit().renderingMode(.template)\n                            .frame(width: 64, height: 64)'
)

content = content.replace(
    'Image(systemName: getIcon(questionIndex: index, optionIndex: optIndex, question: question))',
    'Image(getIcon(questionIndex: index, optionIndex: optIndex, question: question), bundle: .module).resizable().scaledToFit().renderingMode(.template)\n                                        .frame(width: 20, height: 20)'
)

content = content.replace('"largecircle.fill.circle"', '"check-circle"')
content = content.replace('"checkmark.circle.fill"', '"check-circle"')
content = content.replace('"xmark.circle.fill"', '"x"')

with open("Sources/ChineseStudyApp/Features/Stories/StoryQuizView.swift", "w") as f:
    f.write(content)
