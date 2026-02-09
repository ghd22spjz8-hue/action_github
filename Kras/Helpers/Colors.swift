import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct AppTheme {
    static let primary = Color(hex: "6366F1")
    static let primaryLight = Color(hex: "818CF8")
    static let primaryDark = Color(hex: "4F46E5")
    
    static let accent = Color(hex: "F59E0B")
    static let accentLight = Color(hex: "FBBF24")
    
    static let success = Color(hex: "22C55E")
    static let warning = Color(hex: "F59E0B")
    static let error = Color(hex: "EF4444")
    static let info = Color(hex: "3B82F6")
    
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warmGradient = LinearGradient(
        colors: [Color(hex: "F59E0B"), Color(hex: "F97316")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let coolGradient = LinearGradient(
        colors: [Color(hex: "06B6D4"), Color(hex: "3B82F6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        colors: [Color(hex: "22C55E"), Color(hex: "16A34A")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let sunsetGradient = LinearGradient(
        colors: [Color(hex: "F43F5E"), Color(hex: "F97316"), Color(hex: "FBBF24")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let nightGradient = LinearGradient(
        colors: [Color(hex: "1E1B4B"), Color(hex: "312E81"), Color(hex: "4C1D95")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cornerRadius: CGFloat = 16
    static let cornerRadiusSmall: CGFloat = 10
    static let cornerRadiusLarge: CGFloat = 24
    
    static let shadowRadius: CGFloat = 20
    static let shadowOpacity: Double = 0.1
    
    static let spacing: CGFloat = 16
    static let spacingSmall: CGFloat = 8
    static let spacingLarge: CGFloat = 24
}

extension Color {
    static var adaptiveBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1)
                : UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1)
        })
    }
    
    static var adaptiveSecondaryBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.11, green: 0.11, blue: 0.14, alpha: 1)
                : UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        })
    }
    
    static var adaptiveCardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.14, green: 0.14, blue: 0.18, alpha: 1)
                : UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        })
    }
    
    static var adaptivePrimaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white
                : UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1)
        })
    }
    
    static var adaptiveSecondaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.65, green: 0.65, blue: 0.7, alpha: 1)
                : UIColor(red: 0.4, green: 0.4, blue: 0.45, alpha: 1)
        })
    }
    
    static var adaptiveTertiaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.45, green: 0.45, blue: 0.5, alpha: 1)
                : UIColor(red: 0.6, green: 0.6, blue: 0.65, alpha: 1)
        })
    }
    
    static var adaptiveDivider: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1)
                : UIColor(red: 0.9, green: 0.9, blue: 0.92, alpha: 1)
        })
    }
}

struct CardShadow: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: colorScheme == .dark
                    ? Color.black.opacity(0.3)
                    : Color.black.opacity(0.08),
                radius: colorScheme == .dark ? 10 : 20,
                x: 0,
                y: colorScheme == .dark ? 4 : 8
            )
    }
}

extension View {
    func cardShadow() -> some View {
        modifier(CardShadow())
    }
}

struct GlassBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(colorScheme == .dark
                        ? Color.white.opacity(0.05)
                        : Color.white.opacity(0.8)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .fill(.ultraThinMaterial)
                    )
            )
    }
}

extension View {
    func glassBackground() -> some View {
        modifier(GlassBackground())
    }
}
