import SwiftUI

/// Glass "N of M" page pill that morphs into an "Enter Page Number" entry
/// popover — shared by the Book viewer and the Resource-center File viewer.
/// Styled to the Figma "go to page" component (glass surface + translucent
/// grey fields). The pill is hidden while the entry popover is open.
struct PageNumberControl: View {
    @Binding var currentPage: Int
    @Binding var showEntry: Bool
    let totalPages: Int
    @State private var entry = ""

    // Translucent neutral used for the field + button fills in Figma (#76777A @16%).
    private let fieldFill = Color(hex: "#76777A").opacity(0.16)

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            if showEntry { popover } else { pill }
        }
    }

    private var pill: some View {
        Button {
            withAnimation(.easeOut(duration: 0.15)) { showEntry = true }
        } label: {
            Text("\(currentPage) of \(totalPages)")
                .dsText(DS.Text.bodyMdEmph, color: DS.ColorToken.textPrimary)
                .padding(.horizontal, DS.Space.md)
                .frame(height: 40)
        }
        .buttonStyle(.plain)
        .glassSurface(Capsule())
    }

    private var popover: some View {
        VStack(alignment: .leading, spacing: DS.Space.smd) {
            Text("Enter Page Number").dsText(DS.Text.bodyMdEmph)
            HStack(spacing: DS.Space.sm) {
                TextField("1 - \(totalPages)", text: $entry)
                    .keyboardType(.numberPad)
                    .dsText(DS.Text.bodyMd)
                    .padding(.horizontal, DS.Space.md)
                    .frame(width: 160, height: 52)
                    .background(fieldFill, in: Capsule())
                Button { apply() } label: {
                    Text("Go").dsText(DS.Text.bodyMdEmph, color: DS.ColorToken.textPrimary)
                        .frame(width: 76, height: 48)
                        .background(fieldFill, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DS.Space.md)
        .glassSurface(RoundedRectangle(cornerRadius: 28))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(.white.opacity(0.45), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.10), radius: 20, y: 8)
    }

    private func apply() {
        if let n = Int(entry.trimmingCharacters(in: .whitespaces)), (1...totalPages).contains(n) {
            currentPage = n
        }
        entry = ""
        withAnimation(.easeOut(duration: 0.15)) { showEntry = false }
    }
}
