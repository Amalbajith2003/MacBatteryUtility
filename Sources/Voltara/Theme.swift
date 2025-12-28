import SwiftUI

struct Theme {
    static let primary = Color(hex: "135bec")
    static let backgroundLight = Color(hex: "f6f6f8")
    static let backgroundDark = Color(hex: "101622")
    static let surfaceDark = Color(hex: "1c2536")
    static let surfaceLight = Color.white
    static let textSecondaryLight = Color(hex: "92a4c9")
    static let textSecondaryDark = Color(hex: "94a3b8")
    static let success = Color(hex: "10b981")
    static let warning = Color(hex: "f59e0b")
    
    static func background(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? backgroundDark : backgroundLight
    }
    
    static func surface(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? surfaceDark : surfaceLight
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
