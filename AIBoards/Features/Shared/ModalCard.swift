import SwiftUI

/// Standard 580×650 centered card used by Atlas modals: close-X top-left,
/// centered title, optional trailing action.
struct ModalCard<Trailing: View, Content: View>: View {
    let title: String
    let onClose: () -> Void
    @ViewBuilder var trailing: Trailing
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(title).dsText(DS.Text.h5)
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(DS.ColorToken.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(DS.ColorToken.background, in: Circle())
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    trailing
                }
            }
            .padding(.horizontal, DS.Space.lg)
            .frame(height: 76)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.horizontal, DS.Space.lg)
        }
        .frame(width: 580, height: 650)
        .background(DS.ColorToken.surfaceMuted, in: RoundedRectangle(cornerRadius: DS.Radius.xxl))
        .shadow(color: .black.opacity(0.12), radius: 30, y: 14)
    }
}

extension ModalCard where Trailing == EmptyView {
    init(title: String, onClose: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.init(title: title, onClose: onClose, trailing: { EmptyView() }, content: content)
    }
}

/// Small primary pill button (Apply, Respond…).
struct PrimaryButton: View {
    let title: String
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            Text(title)
                .dsText(DS.Text.labelLg, color: .white)
                .padding(.horizontal, DS.Space.md)
                .frame(height: 36)
                .background(DS.ColorToken.primary, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

/// Dims the shell and hosts the active centered card modal.
struct ModalHost: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        if let route = model.modal {
            ZStack {
                Color.black.opacity(0.18)
                    .ignoresSafeArea()
                    .onTapGesture { model.dismissModal() }
                card(for: route)
                    .transition(.scale(scale: 0.96).combined(with: .opacity))
            }
        }
    }

    @ViewBuilder
    private func card(for route: ModalRoute) -> some View {
        switch route {
        case .profile:
            ProfileModal()
        case .booksFilter, .decisionFilter:
            FilterModal()
        case .meetingDetails:
            MeetingDetailsModal()
        }
    }
}
