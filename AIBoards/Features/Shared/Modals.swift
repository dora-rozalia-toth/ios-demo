import SwiftUI

// MARK: - Profile

struct ProfileModal: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        ModalCard(title: "Profile", onClose: model.dismissModal) {
            VStack(spacing: DS.Space.lg) {
                VStack(spacing: DS.Space.sm) {
                    Circle()
                        .fill(DS.ColorToken.infoBg)
                        .frame(width: 72, height: 72)
                        .overlay(Text("AB").dsText(DS.Text.h5, color: DS.ColorToken.infoFg))
                    VStack(spacing: 2) {
                        Text("Anne Belaney").dsText(DS.Text.h3)
                        Text(verbatim: "belaneyanne@board.com")
                            .dsText(DS.Text.bodyMd, color: DS.ColorToken.textMuted)
                            .tint(DS.ColorToken.textMuted)
                    }
                }
                .padding(.top, DS.Space.sm)

                VStack(spacing: DS.Space.smd) {
                    ProfileRow(title: "Manage app settings")
                    ProfileRow(title: "Help & Support")
                    ProfileRow(title: "Sign out", destructive: true)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, DS.Space.sm)
        }
    }
}

private struct ProfileRow: View {
    let title: String
    var destructive: Bool = false
    var body: some View {
        Button {} label: {
            HStack {
                Text(title).dsText(DS.Text.bodyLg, color: destructive ? DS.ColorToken.errorFg : DS.ColorToken.textPrimary)
                Spacer()
                if !destructive {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(DS.ColorToken.textDisabled)
                }
            }
            .padding(.horizontal, DS.Space.md)
            .frame(height: 56)
            .background(DS.ColorToken.background, in: RoundedRectangle(cornerRadius: DS.Radius.lg))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Filter

struct FilterModal: View {
    @EnvironmentObject var model: AppModel
    @State private var committees: Set<String> = ["Main", "Nomination"]
    @State private var ranges: Set<String> = ["New content", "Last month"]

    private let committeeOptions = ["Main", "Nomination", "Marketing", "Finance", "Sales"]
    private let rangeOptions = ["New content", "Last month", "Last 3 months", "Last 6 months", "Custom"]

    var body: some View {
        ModalCard(title: "Filter", onClose: model.dismissModal,
                  trailing: { PrimaryButton(title: "Apply") { model.dismissModal() } }) {
            VStack(alignment: .leading, spacing: DS.Space.lg) {
                group("Filter by committees", options: committeeOptions, selection: $committees)
                group("Filter by date range", options: rangeOptions, selection: $ranges)
                Spacer(minLength: 0)
                Button { committees = []; ranges = [] } label: {
                    Text("Clear all").dsText(DS.Text.bodyMdEmph, color: DS.ColorToken.link)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
            .padding(.top, DS.Space.sm)
            .padding(.bottom, DS.Space.lg)
        }
    }

    private func group(_ title: String, options: [String], selection: Binding<Set<String>>) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.smd) {
            Text(title).dsText(DS.Text.labelSm, color: DS.ColorToken.textMuted)
            FlowLayout(spacing: DS.Space.sm, lineSpacing: DS.Space.sm) {
                ForEach(options, id: \.self) { opt in
                    FilterChip(label: opt, selected: selection.wrappedValue.contains(opt)) {
                        if selection.wrappedValue.contains(opt) { selection.wrappedValue.remove(opt) }
                        else { selection.wrappedValue.insert(opt) }
                    }
                }
            }
        }
    }
}

private struct FilterChip: View {
    let label: String
    let selected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Space.xs) {
                if selected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DS.ColorToken.link)
                }
                Text(label).dsText(DS.Text.bodyMd, color: DS.ColorToken.textPrimary)
            }
            .padding(.horizontal, DS.Space.md)
            .frame(height: 40)
            .background(selected ? DS.ColorToken.accentTint : .clear, in: Capsule())
            .overlay(Capsule().stroke(selected ? DS.ColorToken.link : DS.ColorToken.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Meeting details

struct MeetingDetailsModal: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        ModalCard(title: "Meeting details", onClose: model.dismissModal) {
            VStack(alignment: .leading, spacing: DS.Space.lg) {
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    Text("Call details").dsText(DS.Text.labelSm, color: DS.ColorToken.textMuted)
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        line("Friday, 22 May 9:00 AM – 5:00 PM")
                        line("Time zone: (UTC) Coordinated Universal Time")
                        line("Microsoft Teams meeting")
                        line("Join video call: https://teams.microsoft.com/meet/21698059741765?p=kqetRzqFF1A4EY0G0L")
                        line("Meeting ID: 216 980 597 417 65")
                        line("Passcode: 9Fu9uS9e")
                    }
                }
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    Text("Meeting link").dsText(DS.Text.labelSm, color: DS.ColorToken.textMuted)
                    HStack(spacing: DS.Space.sm) {
                        Text("https://teams.microsoft.com/meet/21698059741765?p=kqetRz…")
                            .dsText(DS.Text.bodyMdEmph, color: DS.ColorToken.link)
                            .underline()
                            .lineLimit(1)
                        Image(systemName: "square.on.square")
                            .font(.system(size: 16))
                            .foregroundStyle(DS.ColorToken.textMuted)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.top, DS.Space.sm)
        }
    }

    private func line(_ text: String) -> some View {
        Text(text).dsText(DS.Text.bodyLg, color: DS.ColorToken.textPrimary)
    }
}
