import SwiftUI

/// A customizable circular progress ring used to display lesson mastery percentages.
public struct CircularProgressView: View {
    public var progress: Double // Range 0.0 to 1.0
    public var tintColor: Color
    public var lineWidth: CGFloat = 8.0

    public init(progress: Double, tintColor: Color = AppTheme.statusLearned, lineWidth: CGFloat = 8.0) {
        self.progress = progress
        self.tintColor = tintColor
        self.lineWidth = lineWidth
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.cardBorder, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(tintColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
        }
    }
}
