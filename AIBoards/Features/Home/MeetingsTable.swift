import SwiftUI

/// Compact "Books with upcoming meetings" table used on Home.
/// Columns: Title (flex) · Status 160 · Meeting date 160 · Committee 200 · menu 44.
struct MeetingsTable: View {
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
            ForEach(Array(books.enumerated()), id: \.element.id) { index, book in
                if index > 0 {
                    Rectangle().fill(DS.ColorToken.border).frame(height: 1)
                }
                row(book)
            }
        }
        // Single clip so ONLY the outer four corners are rounded — rows stay flush.
        .background(DS.ColorToken.background, in: RoundedRectangle(cornerRadius: DS.Radius.lg16))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg16))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg16).stroke(DS.ColorToken.border, lineWidth: 1))
    }

    private var header: some View {
        HStack(spacing: 0) {
            Text("Title").dsText(DS.Text.bodySmEmph)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 64)
            Text("Status").dsText(DS.Text.bodySmEmph)
                .frame(width: statusW, alignment: .leading).padding(.leading, DS.Space.smd)
            Text("Meeting date").dsText(DS.Text.bodySmEmph)
                .frame(width: dateW, alignment: .leading).padding(.leading, DS.Space.smd)
            Text("Committee").dsText(DS.Text.bodySmEmph)
                .frame(width: committeeW, alignment: .leading).padding(.leading, DS.Space.smd)
            Color.clear.frame(width: menuW)
        }
        .frame(height: 40)
        .background(DS.ColorToken.surfaceMuted)
    }

    private func row(_ book: Book) -> some View {
        HStack(spacing: 0) {
            // Title
            HStack(spacing: DS.Space.smd) {
                IconTile(asset: "ic_book_item",
                         tint: book.status == .published ? DS.ColorToken.link : DS.ColorToken.textMuted,
                         glyph: 14)
                Text(book.title).dsText(DS.Text.bodySmEmph).lineLimit(1)
            }
            .padding(.leading, DS.Space.smd)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Status
            HStack { StatusChip.book(book.status) }
                .frame(width: statusW, alignment: .leading).padding(.leading, DS.Space.smd)

            // Date
            Text(book.meetingDate).dsText(DS.Text.bodySm, color: DS.ColorToken.textMuted)
                .frame(width: dateW, alignment: .leading).padding(.leading, DS.Space.smd)

            // Committee
            HStack(spacing: DS.Space.xs) {
                Text("\(book.committee),").dsText(DS.Text.bodySm, color: DS.ColorToken.textMuted).lineLimit(1)
                CountBadge(count: book.extraCommittees)
            }
            .frame(width: committeeW, alignment: .leading).padding(.leading, DS.Space.smd)

            // Menu
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
    }
}
