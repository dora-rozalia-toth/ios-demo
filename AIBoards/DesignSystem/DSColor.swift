import SwiftUI

extension Color {
    init(hex: String) {
        let s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        let r, g, b, a: Double
        switch s.count {
        case 8: // RRGGBBAA
            r = Double((v >> 24) & 0xFF) / 255
            g = Double((v >> 16) & 0xFF) / 255
            b = Double((v >> 8) & 0xFF) / 255
            a = Double(v & 0xFF) / 255
        default: // RRGGBB
            r = Double((v >> 16) & 0xFF) / 255
            g = Double((v >> 8) & 0xFF) / 255
            b = Double(v & 0xFF) / 255
            a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

/// Atlas Foundation Lens — **light theme** semantic colors, resolved from the
/// Atlas MCP token set. One name = one role, mirroring the design system.
enum DS {
    enum ColorToken {
        // Surfaces / backgrounds
        static let background = Color(hex: "#FFFFFF")          // Semantic/Color/Background/Base
        static let surfaceHero = Color(hex: "#F9F9FC")         // hero container fill
        static let surfaceMuted = Color(hex: "#EEEFF5")        // Status/Neutral background variant
        static let surfaceSubtle = Color(hex: "#F4F5F9")       // table header / subtle row fill
        static let pageTop = Color(hex: "#F3F4FD")             // radial page gradient inner
        static let pageBottom = Color(hex: "#FFFFFF")          // radial page gradient outer

        // Text
        static let textPrimary = Color(hex: "#232429")        // Type/Default
        static let textMuted = Color(hex: "#575A67")          // Type/Muted
        static let textDisabled = Color(hex: "#A5A7B3")       // Type/Disabled
        static let textOnAccent = Color(hex: "#FFFFFF")

        // Action / brand
        static let link = Color(hex: "#1C4EE4")               // Action/Link/Default
        static let primary = Color(hex: "#1C4EE4")            // primary button fill
        static let primaryStrong = Color(hex: "#0040D5")      // selected / highlighted
        static let accentTint = Color(hex: "#E9EDFD")         // sidebar selected / soft brand tint
        static let accentTintStrong = Color(hex: "#DDE1FF")

        // Borders / dividers
        static let border = Color(hex: "#DEE0E9")             // hairline divider / field outline
        static let borderStrong = Color(hex: "#C3C4CC")

        // Status (chip background + content)
        static let successBg = Color(hex: "#E6F5F1")
        static let successFg = Color(hex: "#16695B")
        static let errorBg = Color(hex: "#F7E1DF")
        static let errorFg = Color(hex: "#87222F")
        static let warningBg = Color(hex: "#FCEFC5")
        static let warningFg = Color(hex: "#715109")
        static let neutralBg = Color(hex: "#EEEFF5")
        static let neutralFg = Color(hex: "#4C4E5A")
        static let infoBg = Color(hex: "#E4F3FF")             // "Published"/"In progress" chip
        static let infoFg = Color(hex: "#004C6C")
    }
}
