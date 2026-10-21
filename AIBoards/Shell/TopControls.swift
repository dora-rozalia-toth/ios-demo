import SwiftUI

/// The floating controls row: org selector (left) and notification / messages /
/// avatar (right). All three are Atlas "Liquid Glass" pills.
struct TopControls: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        HStack(spacing: DS.Space.smd) {
            if model.sidebarCollapsed {
                Button { withAnimation(.snappy(duration: 0.32)) { model.sidebarCollapsed = false } } label: {
                    Image(systemName: "sidebar.left")
                        .font(.system(size: 18)).foregroundStyle(DS.ColorToken.textPrimary)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .glassSurface(Circle())
            }
            orgSelector
            Spacer(minLength: 0)
            trailing
        }
        .padding(.horizontal, DS.Space.md)
        .padding(.top, DS.Space.sm)
        .frame(height: 60)
    }

    private var orgSelector: some View {
        Button {} label: {
            HStack(spacing: DS.Space.smd) {
                OrgMark(size: 24)
                Text(Mock.orgName).dsText(DS.Text.labelLg)
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DS.ColorToken.textPrimary)
            }
            .padding(.horizontal, DS.Space.md)
            .frame(height: 44)
        }
        .buttonStyle(.plain)
        .glassSurface(Capsule())
    }

    private var trailing: some View {
        HStack(spacing: DS.Space.smd) {
            circleIcon("ic_bell")
            circleIcon("ic_chat")
            Button { model.present(.profile) } label: {
                Avatar(size: 44)
            }
            .buttonStyle(.plain)
        }
    }

    private func circleIcon(_ asset: String) -> some View {
        Button {} label: {
            Image(asset)
                .renderingMode(.template)
                .resizable().scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(DS.ColorToken.textPrimary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .glassSurface(Circle())
    }
}

/// Original geometric org mark (stands in for the customer's brand avatar).
struct OrgMark: View {
    var size: CGFloat = 24
    var body: some View {
        Circle()
            .fill(Color(hex: "#0A6CFF"))
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: "sparkles")
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundStyle(Color(hex: "#FFC220"))
            )
    }
}
