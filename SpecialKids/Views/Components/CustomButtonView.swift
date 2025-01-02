import SwiftUI

struct CustomButtonView: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    let disabled: Bool
    let type: ButtonType
    
    init(
        title: String,
        isLoading: Bool = false,
        disabled: Bool = false,
        type: ButtonType = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.disabled = disabled
        self.type = type
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: type.tintColor))
                } else {
                    Text(title)
                        .foregroundColor(type.textColor)
                        .font(.custom(type.fontName, size: type.fontSize))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: type.height)
        .background(
            Group {
                if disabled {
                    Color.gray.opacity(0.3)
                } else {
                    type.gradient
                }
            }
        )
        .cornerRadius(type.cornerRadius)
        .shadow(
            color: disabled ? .clear : type.shadowColor,
            radius: 8,
            x: 0,
            y: 4
        )
        .disabled(disabled || isLoading)
    }
}

enum ButtonType {
    case primary
    case secondary
    case small
    case link
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return .clear
        case .secondary:
            return Color("SoftBlue")
        case .small:
            return .clear
        case .link:
            return Color("SoftBlue")
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .primary, .small:
            return LinearGradient(
                colors: [
                    Color("Plum"),
                    Color("FantasyPink")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary, .link:
            return LinearGradient(
                colors: [Color("SoftBlue")],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary, .small: return .white
        case .secondary: return .black
        case .link: return .blue
        }
    }
    
    var height: CGFloat {
        switch self {
        case .primary: return 50
        case .secondary: return 44
        case .small: return 36
        case .link: return 30
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .primary, .secondary: return 16
        case .small, .link: return 14
        }
    }
    
    var fontName: String {
        switch self {
        case .primary: return "Outfit-Medium"
        case .secondary: return "Outfit-Regular"
        case .small: return "Outfit-Medium"
        case .link: return "Outfit-Regular"
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .primary, .secondary: return 10
        case .small: return 8
        case .link: return 0
        }
    }
    
    var tintColor: Color {
        switch self {
        case .primary, .small: return .white
        case .secondary, .link: return .blue
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .primary, .small:
            return Color("Plum").opacity(0.3)
        case .secondary, .link:
            return Color("SoftBlue").opacity(0.3)
        }
    }
}
