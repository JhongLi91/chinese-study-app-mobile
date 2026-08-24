import SwiftUI

public enum ModernButtonVariant {
    case `default`
    case outline
    case ghost
    case destructive
}

public enum ModernButtonSize {
    case `default`
    case sm
    case lg
    case icon
}

public struct ModernButton: View {
    public let title: String
    public let systemImage: String?
    public let variant: ModernButtonVariant
    public let size: ModernButtonSize
    public let action: () -> Void
    
    public init(
        title: String,
        systemImage: String? = nil,
        variant: ModernButtonVariant = .default,
        size: ModernButtonSize = .default,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.variant = variant
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = systemImage {
                    Image(icon, bundle: .module)
                        .resizable().renderingMode(.template).scaledToFit()
                        .frame(width: 17, height: 17)
                }
                Text(title)
            }
            .font(.system(size: fontSize, weight: .medium))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, paddingHorizontal)
            .padding(.vertical, paddingVertical)
            .background(backgroundView)
            .foregroundColor(foregroundColor)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain) // Let iOS apply default opacity/Android apply ripple
    }
    
    private var fontSize: CGFloat {
        switch size {
        case .sm: return 12
        case .default: return 14
        case .lg: return 16
        case .icon: return 14
        }
    }
    
    private var backgroundView: Color {
        switch variant {
        case .default: return AppTheme.primary
        case .destructive: return AppTheme.tone1
        case .outline, .ghost: return Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch variant {
        case .default, .destructive: return AppTheme.primaryForeground
        case .outline, .ghost: return AppTheme.foreground
        }
    }
    
    private var borderColor: Color {
        switch variant {
        case .outline: return AppTheme.border
        case .default, .ghost, .destructive: return Color.clear
        }
    }
    
    private var paddingHorizontal: CGFloat {
        switch size {
        case .sm: return 12
        case .default: return 16
        case .lg: return 32
        case .icon: return 8
        }
    }
    
    private var paddingVertical: CGFloat {
        switch size {
        case .sm: return 8
        case .default: return 10
        case .lg: return 12
        case .icon: return 8
        }
    }
}
