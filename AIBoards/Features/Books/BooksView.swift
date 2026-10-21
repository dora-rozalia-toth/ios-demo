import SwiftUI

struct BooksView: View {
    @EnvironmentObject var model: AppModel
    @State private var query = ""

    var body: some View { list }

    private var list: some View {
        VStack(alignment: .leading, spacing: DS.Space.lg) {
            PageTitle(title: "Books")

            HStack(spacing: DS.Space.xl) {
                SearchField(placeholder: "Search by Books", text: $query)
                    .frame(width: 320)
                SortControl(label: "Meeting date (newest-oldest)")
                FilterButton(count: 3) { model.present(.booksFilter) }
                Spacer()
            }

            BookTable(
                books: Mock.books,
                onOpen: { model.openBook = $0 },
                onMenu: { model.present(.meetingDetails($0)) }
            )
        }
    }
}

/// Full Books table: grey header, white rows, dividers, inside a rounded card.
struct BookTable: View {
    let books: [Book]
    var onOpen: (Book) -> Void = { _ in }
    var onMenu: (Book) -> Void = { _ in }

    private let statusW: CGFloat = 160
    private let dateW: CGFloat = 160
    private let committeeW: CGFloat = 200
    private let menuW: CGFloat = 44

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
        .background(DS.ColorToken.background, in: RoundedRectangle(cornerRadius: DS.Radius.lg16))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg16))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg16).stroke(DS.ColorToken.border, lineWidth: 1))
    }

    private var header: some View {
        HStack(spacing: 0) {
            Text("Title").dsText(DS.Text.bodySmEmph)
                .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 64)
            Text("Status").dsText(DS.Text.bodySmEmph)
                .frame(width: statusW, alignment: .leading).padding(.leading, DS.Space.smd)
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

            HStack { StatusChip.book(book.status) }
                .frame(width: statusW, alignment: .leading).padding(.leading, DS.Space.smd)

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
