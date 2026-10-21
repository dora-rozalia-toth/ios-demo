import SwiftUI

extension DS {
    /// Atlas type ramp mapped to Plus Jakarta Sans. `font` carries the typeface +
    /// size; `lineHeight` is exposed so views can set matching line spacing.
    enum Typeface {
        static let family = "Plus Jakarta Sans"
        static let regular = "PlusJakartaSans-Regular"
        static let medium = "PlusJakartaSans-Medium"
        static let semibold = "PlusJakartaSans-SemiBold"
        static let bold = "PlusJakartaSans-Bold"
        static let serif = "Merriweather"
    }

    struct TextStyle {
        let name: String
        let size: CGFloat
        let lineHeight: CGFloat
        var font: Font { .custom(name, size: size) }
        /// Extra spacing between lines to approximate the token's line-height.
        var lineSpacing: CGFloat { max(0, lineHeight - size) }
    }

    // Type ramp is scaled up ~2pt from the Figma spec for on-device legibility on
    // the 13" iPad (Figma points map 1:1 to SwiftUI points, which read small at
    // this physical size). Display titles are lifted a little more.
    enum Text {
        // Titles (SemiBold)
        static let hero = TextStyle(name: Typeface.bold, size: 40, lineHeight: 44)
        static let h1 = TextStyle(name: Typeface.bold, size: 34, lineHeight: 42)        // H1 Billboard
        static let h2 = TextStyle(name: Typeface.semibold, size: 30, lineHeight: 38)    // H2 Display
        static let h3 = TextStyle(name: Typeface.semibold, size: 26, lineHeight: 32)    // H3 Lg
        static let h4 = TextStyle(name: Typeface.semibold, size: 20, lineHeight: 30)    // H4 Md
        static let h5 = TextStyle(name: Typeface.semibold, size: 18, lineHeight: 26)    // H5 Sm
        static let h6 = TextStyle(name: Typeface.semibold, size: 16, lineHeight: 22)    // H6 Xs

        // Body (Regular) + emphasis (SemiBold)
        static let bodyLg = TextStyle(name: Typeface.regular, size: 18, lineHeight: 26)
        static let bodyLgEmph = TextStyle(name: Typeface.semibold, size: 18, lineHeight: 26)
        static let bodyMd = TextStyle(name: Typeface.regular, size: 16, lineHeight: 22)
        static let bodyMdEmph = TextStyle(name: Typeface.semibold, size: 16, lineHeight: 22)
        static let bodySm = TextStyle(name: Typeface.regular, size: 14, lineHeight: 20)
        static let bodySmEmph = TextStyle(name: Typeface.semibold, size: 14, lineHeight: 20)

        // Labels (Medium)
        static let labelXl = TextStyle(name: Typeface.medium, size: 18, lineHeight: 26)
        static let labelLg = TextStyle(name: Typeface.medium, size: 16, lineHeight: 22)
        static let labelSm = TextStyle(name: Typeface.medium, size: 14, lineHeight: 20)
        static let labelXs = TextStyle(name: Typeface.medium, size: 13, lineHeight: 18)

        // Welcome serif
        static let welcome = TextStyle(name: Typeface.serif, size: 32, lineHeight: 42)
    }
}

extension View {
    /// Apply an Atlas text style: typeface+size and matching line spacing.
    func dsText(_ style: DS.TextStyle, color: Color = DS.ColorToken.textPrimary) -> some View {
        self.font(style.font)
            .lineSpacing(style.lineSpacing)
            .foregroundStyle(color)
    }
}
