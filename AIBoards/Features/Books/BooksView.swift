import SwiftUI

struct BooksView: View {
    @EnvironmentObject var model: AppModel
    @State private var query = ""
    @State private var sort = BooksView.sortOptions[0]

    static let sortOptions = [
        "Meeting date (newest-oldest)",
        "Meeting date (oldest-newest)",
        "Title (A-Z)",
        "Title (Z-A)",
        "Updated date (newest-oldest)",
        "Updated date (oldest-newest)",
    ]

    var body: some View { list }

    private var list: some View {
        VStack(alignment: .leading, spacing: DS.Space.lg) {
            PageTitle(title: "Books")

            HStack(spacing: DS.Space.xl) {
                SearchField(placeholder: "Search by Books", text: $query)
                    .frame(width: 320)
                SortControl(label: sort, options: Self.sortOptions, selection: $sort)
                FilterButton(count: 3) { model.present(.booksFilter) }
                Spacer()
            }

            BookTable(
                books: sortedBooks,
                onOpen: { model.openBook = $0 },
                onMenu: { model.present(.meetingDetails($0)) }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            // Bleed the card off the bottom edge: cancel the shell's bottom
            // inset and run through the safe area so the end of the list sits
            // below the fold until the user scrolls to it.
            .padding(.bottom, -DS.Space.md)
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }

    /// Books ordered by the active sort option. ("Updated date" reuses the
    /// meeting date — the mock has no separate updated-date field.)
    private var sortedBooks: [Book] {
        // meetingDate is "MM/DD/YYYY" → a sortable "YYYYMMDD" key.
        func key(_ s: String) -> String {
            let p = s.split(separator: "/")
            return p.count == 3 ? "\(p[2])\(p[0])\(p[1])" : s
        }
        switch sort {
        case "Title (A-Z)":
            return Mock.books.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case "Title (Z-A)":
            return Mock.books.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case "Meeting date (oldest-newest)", "Updated date (oldest-newest)":
            return Mock.books.sorted { key($0.meetingDate) < key($1.meetingDate) }
        default: // newest-oldest
            return Mock.books.sorted { key($0.meetingDate) > key($1.meetingDate) }
        }
    }
}

/// Full Books table: grey header, white rows, dividers, inside a rounded card.
struct BookTable: View {
    let books: [Book]
    var onOpen: (Book) -> Void = { _ in }
    var onMenu: (Book) -> Void = { _ in }

    private let dateW: CGFloat = 160
    private let committeeW: CGFloat = 200
    private let menuW: CGFloat = 44

    // Only the top corners are rounded — the card bleeds off the bottom of the
    // screen so the end of the list is reached by scrolling, not shown at rest.
    private var topRounded: UnevenRoundedRectangle {
        UnevenRoundedRectangle(topLeadingRadius: DS.Radius.lg16, topTrailingRadius: DS.Radius.lg16)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(books.enumerated()), id: \.element.id) { index, book in
                        row(book, isLast: index == books.count - 1)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(DS.ColorToken.background, in: topRounded)
        .clipShape(topRounded)
        .overlay(topRounded.stroke(DS.ColorToken.border, lineWidth: 1))
    }

    private var header: some View {
        HStack(spacing: 0) {
            Text("Title").dsText(DS.Text.bodySmEmph)
                .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 64)
            Text("Meeting date").dsText(DS.Text.bodySmEmph)
                .frame(width: dateW, alignment: .leading).padding(.leading, DS.Space.smd)
            Text("Committee").dsText(DS.Text.bodySmEmph)
                .frame(width: committeeW, alignment: .leading).padding(.leading, DS.Space.smd)
            Color.clear.frame(width: menuW)
        }
        .frame(height: 48)
        .background(DS.ColorToken.surfaceMuted)
    }

    private func row(_ book: Book, isLast: Bool) -> some View {
        HStack(spacing: 0) {
            HStack(spacing: DS.Space.smd) {
                IconTile(asset: "ic_book_item",
                         tint: book.status == .published ? DS.ColorToken.link : DS.ColorToken.textMuted,
                         glyph: 14)
                Text(book.title).dsText(DS.Text.bodySmEmph).lineLimit(1)
            }
            .padding(.leading, DS.Space.smd)
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(book.meetingDate).dsText(DS.Text.bodySm, color: DS.ColorToken.textMuted)
                .frame(width: dateW, alignment: .leading).padding(.leading, DS.Space.smd)

            HStack(spacing: DS.Space.xs) {
                Text("\(book.committee),").dsText(DS.Text.bodySm, color: DS.ColorToken.textMuted).lineLimit(1)
                CountBadge(count: book.extraCommittees)
            }
            .frame(width: committeeW, alignment: .leading).padding(.leading, DS.Space.smd)

            Menu {
                Button("Meeting details") { onMenu(book) }
                Button("Agenda") { onMenu(book) }
                Button("Updates") { onMenu(book) }
                Divider()
                Button("Share") {}
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .font(.system(size: 18))
                    .foregroundStyle(DS.ColorToken.textPrimary)
                    .frame(width: 32, height: 32)
            }
            .menuStyle(.borderlessButton)
            .frame(width: menuW)
        }
        .frame(height: 64)
        .background(DS.ColorToken.background)
        .contentShape(Rectangle())
        .onTapGesture { onOpen(book) }
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle().fill(DS.ColorToken.border).frame(height: 1).padding(.horizontal, DS.Space.smd)
            }
        }
    }
}
