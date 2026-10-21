import SwiftUI

// MARK: - Liquid Glass surface

extension View {
    /// Atlas "Liquid Glass" floating surfaces (sidebar, top-bar pills). Uses the
    /// iOS 26 glass material; the deployment target guarantees availability.
    @ViewBuilder
    func glassSurface(_ shape: some Shape) -> some View {
        self.glassEffect(.regular, in: shape)
    }
}

// MARK: - Status chip (Atlas "Basic status indicator")

struct StatusChip: View {
    let text: String
    var bg: Color
    var fg: Color

    var body: some View {
        Text(text)
            .dsText(DS.Text.labelSm, color: fg)
            .padding(.horizontal, DS.Space.sm)
            .frame(height: 24)
            .background(bg, in: Capsule())
    }
}

extension StatusChip {
    static func book(_ status: BookStatus) -> StatusChip {
        switch status {
        case .archived: return StatusChip(text: status.rawValue, bg: DS.ColorToken.neutralBg, fg: DS.ColorToken.neutralFg)
        case .published: return StatusChip(text: status.rawValue, bg: DS.ColorToken.infoBg, fg: DS.ColorToken.infoFg)
        }
    }
    static func info(_ text: String) -> StatusChip { StatusChip(text: text, bg: DS.ColorToken.infoBg, fg: DS.ColorToken.infoFg) }
    static func neutral(_ text: String) -> StatusChip { StatusChip(text: text, bg: DS.ColorToken.neutralBg, fg: DS.ColorToken.neutralFg) }
    static func success(_ text: String) -> StatusChip { StatusChip(text: text, bg: DS.ColorToken.successBg, fg: DS.ColorToken.successFg) }
    static func warning(_ text: String) -> StatusChip { StatusChip(text: text, bg: DS.ColorToken.warningBg, fg: DS.ColorToken.warningFg) }
    static func error(_ text: String) -> StatusChip { StatusChip(text: text, bg: DS.ColorToken.errorBg, fg: DS.ColorToken.errorFg) }
}

// MARK: - Count badge ("+2")

struct CountBadge: View {
    let count: Int
    var body: some View {
        Text("+\(count)")
            .dsText(DS.Text.labelSm, color: DS.ColorToken.neutralFg)
            .padding(.horizontal, DS.Space.xs)
            .frame(height: 16)
            .background(DS.ColorToken.neutralBg, in: RoundedRectangle(cornerRadius: DS.Radius.lg))
    }
}

// MARK: - Icon button (rounded square, subtle fill)

struct IconTile: View {
    var symbol: String = ""
    var asset: String? = nil          // bundled template asset (takes precedence)
    var size: CGFloat = 40
    var tileFill: Color = DS.ColorToken.surfaceHero
    var tint: Color = DS.ColorToken.textPrimary
    var glyph: CGFloat = 18

    var body: some View {
        RoundedRectangle(cornerRadius: DS.Radius.md)
            .fill(tileFill)
            .frame(width: size, height: size)
            .overlay(glyphView)
    }

    @ViewBuilder private var glyphView: some View {
        if let asset {
            Image(asset).renderingMode(.template).resizable().scaledToFit()
                .frame(width: glyph + 4, height: glyph + 4)
                .foregroundStyle(tint)
        } else {
            Image(systemName: symbol)
                .font(.system(size: glyph, weight: .regular))
                .foregroundStyle(tint)
        }
    }
}

/// Transparent icon button used for toolbar actions (ellipsis, filter…).
struct PlainIconButton: View {
    var symbol: String = ""
    var asset: String? = nil          // bundled template asset (takes precedence)
    var size: CGFloat = 32
    var glyph: CGFloat = 18
    var tint: Color = DS.ColorToken.textPrimary
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Group {
                if let asset {
                    Image(asset).renderingMode(.template).resizable().scaledToFit()
                        .frame(width: glyph, height: glyph)
                } else {
                    Image(systemName: symbol)
                        .font(.system(size: glyph, weight: .regular))
                }
            }
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - "Go to X ›" quiet link button

struct LinkButton: View {
    let title: String
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Space.xs) {
                Text(title).dsText(DS.Text.labelSm, color: DS.ColorToken.textPrimary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DS.ColorToken.textPrimary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Section header (title + optional trailing link)

struct SectionHeader<Trailing: View>: View {
    let title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(alignment: .center) {
            Text(title).dsText(DS.Text.h4)
            Spacer(minLength: DS.Space.md)
            trailing
        }
    }
}

extension SectionHeader where Trailing == EmptyView {
    init(_ title: String) { self.init(title: title) { EmptyView() } }
}

// MARK: - Search field (Atlas form field)

struct SearchField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: DS.Space.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(DS.ColorToken.textMuted)
            TextField(placeholder, text: $text)
                .font(DS.Text.bodyMd.font)
                .foregroundStyle(DS.ColorToken.textPrimary)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(DS.ColorToken.textDisabled)
                }.buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DS.Space.md)
        .frame(height: 44)
        .background(DS.ColorToken.surfaceMuted, in: Capsule())
    }
}

// MARK: - Avatar

struct Avatar: View {
    var size: CGFloat = 44
    var body: some View {
        Circle()
            .fill(LinearGradient(colors: [Color(hex: "#C7D2FE"), Color(hex: "#E9D5FF")],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.42))
                    .foregroundStyle(.white.opacity(0.9))
            )
    }
}
