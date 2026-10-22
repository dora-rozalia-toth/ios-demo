import SwiftUI

/// Large page title + optional search / sort / filter toolbar row, matching the
/// Books / Resource center / Approvals headers. Uses the Atlas display font.
struct PageTitle: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.custom(DS.Typeface.bold, size: 40))
            .foregroundStyle(DS.ColorToken.textPrimary)
    }
}

/// Sort control ("Meeting date (newest-oldest) ⌄") used on list pages.
/// Pass `options` + `selection` to open a native sort menu on tap (iOS renders
/// the "Sort by" section header and the checkmark on the selected option);
/// omit them for a plain, non-interactive control.
struct SortControl: View {
    let label: String
    var options: [String] = []
    var selection: Binding<String>? = nil

    var body: some View {
        if let selection, !options.isEmpty {
            Menu {
                Picker("Sort by", selection: selection) {
                    ForEach(options, id: \.self) { Text($0).tag($0) }
                }
            } label: {
                content
            }
            .tint(DS.ColorToken.textPrimary)
        } else {
            Button {} label: { content }
                .buttonStyle(.plain)
        }
    }

    private var content: some View {
        HStack(spacing: DS.Space.sm) {
            Text(label).dsText(DS.Text.bodyMd)
            Image(systemName: "chevron.up.chevron.down")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(DS.ColorToken.textMuted)
        }
    }
}

/// Filter button with an applied-count badge.
struct FilterButton: View {
    var count: Int = 0
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(DS.ColorToken.textPrimary)
                .frame(width: 32, height: 32)
                .overlay(alignment: .topTrailing) {
                    if count > 0 {
                        Text("\(count)")
                            .dsText(DS.Text.labelXs, color: .white)
                            .frame(minWidth: 18, minHeight: 18)
                            .background(DS.ColorToken.primaryStrong, in: Circle())
                            .offset(x: 6, y: -6)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

/// Simple placeholder body for sections still being built out.
struct ComingSoon: View {
    let note: String
    var body: some View {
        VStack(spacing: DS.Space.sm) {
            Image(systemName: "square.dashed")
                .font(.system(size: 28))
                .foregroundStyle(DS.ColorToken.textDisabled)
            Text(note).dsText(DS.Text.bodyMd, color: DS.ColorToken.textMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
