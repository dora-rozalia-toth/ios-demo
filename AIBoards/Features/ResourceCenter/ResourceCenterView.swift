import SwiftUI

struct ResourceCenterView: View {
    @EnvironmentObject var model: AppModel
    @State private var query = ""
    /// Folders drilled into, root → current. Empty = top-level "Resource center".
    @State private var path: [ResourceNode] = {
        // Screenshot hook: start one level deep inside the first folder.
        ProcessInfo.processInfo.arguments.contains("-folder") ? [Mock.resourceTree[0]] : []
    }()
    @State private var showCrumbs = ProcessInfo.processInfo.arguments.contains("-crumbs")

    private let upID = UUID()

    /// Entries shown at the current depth.
    private var current: [ResourceNode] { path.last?.children ?? Mock.resourceTree }

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: DS.Space.lg) {
                header
                toolbarRow
                NameDateTable(rows: rows) { handleTap($0) }
            }
            // Tap-away catcher + breadcrumb path popover, floated under the title.
            if showCrumbs {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.snappy(duration: 0.18)) { showCrumbs = false } }
                crumbPopover
                    .padding(.leading, 56)
                    .padding(.top, 54)
                    .transition(.scale(scale: 0.96, anchor: .topLeading).combined(with: .opacity))
            }
        }
    }

    // MARK: Header

    @ViewBuilder private var header: some View {
        if path.isEmpty {
            PageTitle(title: "Resource center")
        } else {
            HStack(spacing: DS.Space.smd) {
                Button { pop() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(DS.ColorToken.textPrimary)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .glassSurface(Circle())

                Button { withAnimation(.snappy(duration: 0.18)) { showCrumbs.toggle() } } label: {
                    HStack(spacing: DS.Space.sm) {
                        Text(path.last?.name ?? "")
                            .font(.custom(DS.Typeface.semibold, size: 24))
                            .foregroundStyle(DS.ColorToken.textPrimary)
                        Image(systemName: showCrumbs ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(DS.ColorToken.textPrimary)
                    }
                }
                .buttonStyle(.plain)
                Spacer(minLength: 0)
            }
        }
    }

    private var toolbarRow: some View {
        HStack(spacing: DS.Space.md) {
            SearchField(placeholder: "Search Resource Center", text: $query)
                .frame(width: 320)
            SortControl(label: "Last modified (newest-oldest)")
            FilterButton(count: 3) { model.present(.booksFilter) }
            Spacer()
        }
    }

    // MARK: Breadcrumb popover

    private var crumbPopover: some View {
        VStack(alignment: .leading, spacing: 0) {
            crumbRow("Resource Center") { setPath([]) }
            ForEach(Array(path.enumerated()), id: \.element.id) { i, node in
                crumbRow(node.name) { setPath(Array(path.prefix(i + 1))) }
            }
        }
        .padding(.vertical, DS.Space.sm)
        .frame(width: 300, alignment: .leading)
        .glassSurface(RoundedRectangle(cornerRadius: DS.Radius.lg16))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg16).stroke(DS.ColorToken.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.10), radius: 20, y: 8)
    }

    private func crumbRow(_ title: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .dsText(DS.Text.bodyMd)
                .lineLimit(1)
                .padding(.horizontal, DS.Space.md)
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: Rows + navigation

    private var rows: [NameDateTable.Row] {
        var r: [NameDateTable.Row] = []
        if !path.isEmpty { r.append(.init(id: upID, name: "…", date: "", symbol: "folder")) }
        r += current.map {
            .init(id: $0.id, name: $0.name, date: $0.lastModified,
                  symbol: $0.isFolder ? "folder" : "doc.text")
        }
        return r
    }

    private func handleTap(_ id: UUID) {
        if id == upID { pop(); return }
        guard let node = current.first(where: { $0.id == id }) else { return }
        if node.isFolder {
            withAnimation(.snappy(duration: 0.22)) { path.append(node); showCrumbs = false }
        } else {
            model.openFile = ResourceFile(name: node.name, lastModified: node.lastModified)
        }
    }

    private func pop() {
        withAnimation(.snappy(duration: 0.22)) {
            if !path.isEmpty { path.removeLast() }
            showCrumbs = false
        }
    }

    private func setPath(_ newPath: [ResourceNode]) {
        withAnimation(.snappy(duration: 0.2)) { path = newPath; showCrumbs = false }
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
                    // Align with the row's name text (leading inset + icon + spacing),
                    // matching how the Books header aligns "Title" with its rows.
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, DS.Space.smd + 24 + DS.Space.smd)
                Text("Last modified").dsText(DS.Text.bodySmEmph)
                    .frame(width: dateW, alignment: .trailing).padding(.trailing, DS.Space.lg)
            }
            .frame(height: 48)
            .background(DS.ColorToken.surfaceMuted)

            // Hug the content: the card sizes to its rows instead of stretching
            // to fill the remaining screen height.
            VStack(spacing: 0) {
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
        .fixedSize(horizontal: false, vertical: true)
        .background(DS.ColorToken.background, in: RoundedRectangle(cornerRadius: DS.Radius.lg16))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg16))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg16).stroke(DS.ColorToken.border, lineWidth: 1))
    }
}
