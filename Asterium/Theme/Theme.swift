//
//  Theme.swift
//  Seery
//

import SwiftUI

// MARK: - Color Tokens

enum LColors {
    // Base
    static let bg = Color(seeryHex: "#07070a")
    static let bgSoft = Color(seeryHex: "#020304")
    
    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color(seeryHex: "#888888")
    
    // Accent
    static let accent = Color(seeryHex: "#bca64d")
    static let accentHover = Color(seeryHex: "#ad640a")
    static let accentGradient = LinearGradient(
        colors: [
            Color(seeryHex: "#bca64d"),
            Color(seeryHex: "#ad640a")
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // Status
    static let success = Color(seeryHex: "#e2ed8a")
    static let danger = Color(seeryHex: "#ad640a")
    static let warning = Color(seeryHex: "#bca64d")
    
    // Glass surfaces
    static let glassSurface = Color.white.opacity(0.06)
    static let glassSurface2 = Color.white.opacity(0.09)
    static let glassBorder = Color.white.opacity(0.14)
    static let glassBorderStrong = Color.white.opacity(0.22)
    
    // Gradient colors
    static let gradientPurple = Color(seeryHex: "#bca64d")
    static let gradientBlue = Color(seeryHex: "#ad640a")
    static let gradientPink = Color(seeryHex: "#bca64d")
    static let gradientCyan = Color(seeryHex: "#bca64d")
    static let gradientYellow = Color(seeryHex: "#f6f684")
    static let gradientDeepPurple = Color(seeryHex: "#ad640a")
    
    // Badge colors
    static let badgeOnce = Color(seeryHex: "#bca64d")
    static let badgeDaily = Color(seeryHex: "#ad640a")
    static let badgeWeekly = Color.white
    static let badgeMonthly = Color(seeryHex: "#ad640a")
    static let badgeInterval = Color(seeryHex: "#bca64d")
}

// MARK: - Gradients

enum LGradients {
    static let blue = LinearGradient(
        colors: [LColors.gradientBlue, LColors.gradientPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let header = LinearGradient(
        colors: [
            Color(seeryHex: "#bca64d"),
            Color(seeryHex: "#ad640a")
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let tag = LinearGradient(
        colors: [LColors.gradientPurple, LColors.gradientBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Background ambient glow
    static let bgPurple = RadialGradient(
        colors: [Color(seeryHex: "#bca64d").opacity(0.22), .clear],
        center: UnitPoint(x: 0.28, y: 0.18),
        startRadius: 0,
        endRadius: 450
    )
    
    static let bgCyan = RadialGradient(
        colors: [Color(seeryHex: "#ad640a").opacity(0.18), .clear],
        center: UnitPoint(x: 0.76, y: 0.78),
        startRadius: 0,
        endRadius: 475
    )
    
    static let bgYellow = RadialGradient(
        colors: [Color(seeryHex: "#f6f684").opacity(0.22), .clear],
        center: UnitPoint(x: 0.58, y: 0.26),
        startRadius: 0,
        endRadius: 260
    )
    
    static let bgPink = RadialGradient(
        colors: [Color(seeryHex: "#ad640a").opacity(0.10), .clear],
        center: UnitPoint(x: 0.42, y: 0.74),
        startRadius: 0,
        endRadius: 260
    )

    static let reward = LinearGradient(
        colors: [Color(seeryHex: "#bca64d"), Color(seeryHex: "#ad640a")],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Spacing & Radius

enum LSpacing {
    static let cardPadding: CGFloat = 20
    static let cardRadius: CGFloat = 16
    static let buttonRadius: CGFloat = 12
    static let inputRadius: CGFloat = 12
    static let pillRadius: CGFloat = 999
    static let pageHorizontal: CGFloat = 16
    static let sectionGap: CGFloat = 24
}

// MARK: - Color Extension

extension Color {
    init(seeryHex hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        
        switch hex.count {
        case 6:
            (a, r, g, b) = (
                255,
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        case 8:
            (a, r, g, b) = (
                int >> 24,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )
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

    func toHex() -> String? {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    var isLightColor: Bool {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let luminance = (0.299 * red) + (0.587 * green) + (0.114 * blue)

        return luminance > 0.62
    }
}
