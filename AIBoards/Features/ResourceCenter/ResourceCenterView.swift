import SwiftUI

struct ResourceCenterView: View {
    @EnvironmentObject var model: AppModel
    @State private var query = ""
    @State private var openFolder: ResourceFolder? = nil

    var body: some View { list }

    private var list: some View {
        VStack(alignment: .leading, spacing: DS.Space.lg) {
            HStack(spacing: DS.Space.smd) {
                if let folder = openFolder {
                    Button { self.openFolder = nil } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(DS.ColorToken.textPrimary)
                    }.buttonStyle(.plain)
                    PageTitle(title: folder.name)
                } else {
                    PageTitle(title: "Resource center")
                }
            }

            HStack(spacing: DS.Space.md) {
                SearchField(placeholder: "Search Resource Center", text: $query)
                    .frame(width: 320)
                SortControl(label: "Last modified (newest-oldest)")
                FilterButton(count: 3) { model.present(.booksFilter) }
                Spacer()
            }

            if openFolder == nil {
                NameDateTable(rows: Mock.resourceFolders.map { (.init(id: $0.id, name: $0.name, date: $0.lastModified, symbol: "folder")) }) { tapped in
                    openFolder = Mock.resourceFolders.first { $0.id == tapped }
                }
            } else {
                NameDateTable(rows: Mock.resourceFiles.map { (.init(id: $0.id, name: $0.name, date: $0.lastModified, symbol: "doc.text")) }) { tapped in
                    model.openFile = Mock.resourceFiles.first { $0.id == tapped }
                }
            }
        }
    }
}

/// Two-column (Name · Last modified) table used by the Resource center.
struct NameDateTable: View {
    struct Row: Identifiable { let id: UUID; let name: String; let date: String; let symbol: String }
    let rows: [Row]
    var onTap: (UUID) -> Void = { _ in }

    private let dateW: CGFloat = 200

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("Name").dsText(DS.Text.bodySmEmph)
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, DS.Space.smd)
                Text("Last modified").dsText(DS.Text.bodySmEmph)
                    .frame(width: dateW, alignment: .trailing).padding(.trailing, DS.Space.lg)
            }
            .frame(height: 48)
            .background(DS.ColorToken.surfaceMuted)

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                        HStack(spacing: 0) {
                            HStack(spacing: DS.Space.smd) {
                                Image(systemName: row.symbol)
                                    .font(.system(size: 18))
                                    .foregroundStyle(DS.ColorToken.textPrimary)
                                    .frame(width: 24)
                                Text(row.name).dsText(DS.Text.bodyMd)
                            }
                            .padding(.leading, DS.Space.smd)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Text(row.date).dsText(DS.Text.bodySm, color: DS.ColorToken.textMuted)
                                .frame(width: dateW, alignment: .trailing).padding(.trailing, DS.Space.lg)
                        }
                        .frame(height: 64)
                        .background(DS.ColorToken.background)
                        .contentShape(Rectangle())
                        .onTapGesture { onTap(row.id) }
                        .overlay(alignment: .bottom) {
                            if index != rows.count - 1 {
                                Rectangle().fill(DS.ColorToken.border).frame(height: 1).padding(.horizontal, DS.Space.smd)
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(DS.ColorToken.background, in: RoundedRectangle(cornerRadius: DS.Radius.lg16))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg16))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg16).stroke(DS.ColorToken.border, lineWidth: 1))
    }
}
