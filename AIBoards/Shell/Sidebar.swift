import SwiftUI

/// Liquid Glass floating sidebar: collapse affordance, nav items, Diligent mark.
struct Sidebar: View {
    @EnvironmentObject var model: AppModel
    @Namespace private var navSelection

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.bottom, DS.Space.xs)

            VStack(spacing: DS.Space.sm) {
                ForEach(AppSection.allCases) { section in
                    NavItem(section: section, isSelected: model.section == section, namespace: navSelection) {
                        model.select(section)
                    }
                }
            }

            Spacer(minLength: 0)

            BrandMark()
                .padding(.leading, DS.Space.sm)
                .padding(.bottom, DS.Space.xs)
        }
        .padding(DS.Space.smd)
        .frame(width: 268)
        .frame(maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(DS.ColorToken.background)
                .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
        )
    }

    private var header: some View {
        HStack {
            Spacer()
            PlainIconButton(symbol: "sidebar.left", size: 48, glyph: 18) {
                withAnimation(.snappy(duration: 0.32)) { model.sidebarCollapsed = true }
            }
        }
        .frame(height: 48)
    }
}

private struct NavItem: View {
    let section: AppSection
    let isSelected: Bool
    var namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Space.smd) {
                Image(section.asset)
                    .renderingMode(.template)
                    .resizable().scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(isSelected ? DS.ColorToken.link : DS.ColorToken.textPrimary)
                Text(section.rawValue)
                    .dsText(DS.Text.labelLg, color: isSelected ? DS.ColorToken.link : DS.ColorToken.textPrimary)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, DS.Space.sm)
            .frame(height: 40)
            .background {
                // The selected pill slides between items via matchedGeometryEffect.
                if isSelected {
                    RoundedRectangle(cornerRadius: DS.Radius.lg)
                        .fill(DS.ColorToken.accentTint)
                        .matchedGeometryEffect(id: "navSelectionPill", in: namespace)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Diligent brand lockup (flame "D" mark + wordmark), exported from Figma.
private struct BrandMark: View {
    var body: some View {
        Image("diligent_logo")
            .resizable()
            .scaledToFit()
            .frame(height: 28)
    }
}
