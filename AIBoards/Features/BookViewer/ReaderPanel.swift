import SwiftUI

/// Liquid Glass left panel. Header = collapse row + Atlas segmented tool switcher.
/// Each tool renders its own content to match the Figma side-panel states.
struct ReaderPanel: View {
    @Binding var tab: PanelTab
    /// File viewer panel has no tool switcher — only Structure / Thumbnails.
    var isFile: Bool = false
    @ObservedObject var composer: NoteComposer
    var onCollapse: () -> Void = {}
    @FocusState private var composeFocused: Bool
    @State private var structureSub = ProcessInfo.processInfo.arguments.contains("-panel=thumbnails") ? 1 : 0   // 0 = Structure, 1 = Thumbnails
    @State private var search = "audit risk 2024"
    @State private var exactMatch = true
    @State private var searchSort = 0            // 0 = Page order, 1 = Search rank
    @State private var expandedMarkup: String? = "Page 2"

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.smd) {
            HStack {
                Spacer()
                PlainIconButton(symbol: "sidebar.left", size: 44, glyph: 18) { onCollapse() }
            }
            // Match the document toolbar's button row so the collapse control sits
            // on the title's line — collapsing then swaps seamlessly to the expand
            // button in the toolbar at the same height.
            .frame(height: 44)

            if isFile {
                structureTool   // files: Structure / Thumbnails only
            } else {
                AtlasToolSegmented(tab: $tab)
                switch tab {
                case .structure: structureTool
                case .search: searchTool
                case .notes: notesTool
                case .markups: markupsTool
                case .bookmarks: bookmarksTool
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, DS.Space.md)
        .padding(.bottom, DS.Space.md)
        .padding(.top, DS.Space.sm)   // 8 — tight inset; panel top edge is dropped to the back-button line in ReaderShell
        .frame(width: 320)
        .frame(maxHeight: .infinity, alignment: .top)
        .glassSurface(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: Section title + doc header line

    private func sectionTitle(_ t: String) -> some View {
        Text(t).font(.custom(DS.Typeface.medium, size: 18)).foregroundStyle(DS.ColorToken.textPrimary)
    }

    private var docHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(ReaderMock.docHeaderTitle).dsText(DS.Text.bodySmEmph)
            Text(ReaderMock.docHeaderSub).dsText(DS.Text.bodySm, color: DS.ColorToken.textMuted)
        }
        .padding(.vertical, DS.Space.xs)
    }

    // MARK: Structure / Thumbnails

    private var structureTool: some View {
        VStack(alignment: .leading, spacing: DS.Space.smd) {
            sectionTitle("Content").padding(.top, DS.Space.xs)
            HStack(spacing: 0) {
                atlasTab("Structure", 0, binding: $structureSub)
                atlasTab("Thumbnails", 1, binding: $structureSub)
                Spacer(minLength: 0)
            }
            .overlay(alignment: .bottom) { Rectangle().fill(DS.ColorToken.border).frame(height: 1) }

            if structureSub == 0 {
                if isFile {
                    scroll { ForEach(ReaderMock.fileTree) { FileTreeRow(node: $0) } }
                } else {
                    scroll { ForEach(Mock.outline) { OutlineRow(node: $0) } }
                }
            } else {
                thumbnails
            }
        }
    }

    private var thumbnails: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Space.md) {
                docHeader
                ForEach(ReaderMock.thumbnailPages, id: \.self) { page in
                    ThumbnailCard(page: page, selected: page == 2)
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    // MARK: Search

    private var searchTool: some View {
        VStack(alignment: .leading, spacing: DS.Space.smd) {
            sectionTitle("Search").padding(.top, DS.Space.xs)
            SearchField(placeholder: "Search", text: $search)
            Toggle(isOn: $exactMatch) {
                Text("Enable exact keyword matching").dsText(DS.Text.bodyMd)
            }
            .toggleStyle(.switch)
            .tint(DS.ColorToken.primaryStrong)

            HStack(spacing: 0) {
                atlasTab("Page order", 0, binding: $searchSort)
                atlasTab("Search rank", 1, binding: $searchSort)
                Spacer(minLength: 0)
            }
            .overlay(alignment: .bottom) { Rectangle().fill(DS.ColorToken.border).frame(height: 1) }

            scroll {
                ForEach(Array(ReaderMock.searchResults.enumerated()), id: \.element.id) { i, r in
                    SearchResultCard(result: r, selected: i == 0)
                }
            }
        }
    }

    // MARK: Notes

    private var notesTool: some View {
        VStack(alignment: .leading, spacing: DS.Space.smd) {
            HStack {
                sectionTitle("Notes")
                Spacer()
                newNoteButton
                PlainIconButton(asset: "ic_filter", size: 28, glyph: 18)
            }
            .padding(.top, DS.Space.xs)

            ScrollView {
                VStack(alignment: .leading, spacing: DS.Space.lg) {
                    if composer.mode == .composing { composeField }
                    // Notes added this session appear at the top of the list.
                    if !composer.addedNotes.isEmpty {
                        VStack(alignment: .leading, spacing: DS.Space.sm) {
                            ForEach(composer.addedNotes) { note in
                                NoteCard(note: note,
                                         focused: note.id == composer.focusedNoteId,
                                         onTap: { composer.focus(note.id) })
                            }
                        }
                    }
                    // 24 between page groups; 8 within a page — matches Figma.
                    ForEach(ReaderMock.notePages) { page in
                        VStack(alignment: .leading, spacing: DS.Space.sm) {
                            Text(page.page).dsText(DS.Text.bodySm, color: DS.ColorToken.textMuted)
                            ForEach(page.notes) { NoteCard(note: $0) }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .onChange(of: composer.mode) { _, mode in
            composeFocused = (mode == .composing)
        }
    }

    // "+" new-note button — fills with the Atlas tint while the flow is active.
    private var newNoteButton: some View {
        Button {
            withAnimation(.snappy(duration: 0.25)) { composer.toggle() }
        } label: {
            Image("ic_note_add").renderingMode(.template).resizable().scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundStyle(composer.isActive ? DS.ColorToken.link : DS.ColorToken.textPrimary)
                .frame(width: 28, height: 28)
                .background(composer.isActive ? Color(hex: "#D7E2FF") : .clear,
                            in: RoundedRectangle(cornerRadius: DS.Radius.md))
        }
        .buttonStyle(.plain)
    }

    // Inline compose field shown while a pin is being annotated.
    private var composeField: some View {
        // Light-indigo card (#ECF0FF) holds the counter (top-right) and a white input box.
        VStack(alignment: .trailing, spacing: DS.Space.xs) {
            Text("\(composer.draft.count)/1000")
                .font(.system(size: 11))
                .foregroundStyle(DS.ColorToken.textMuted)
            HStack(alignment: .center, spacing: DS.Space.sm) {
                NoteAvatar(initials: "KL", tint: "#E9EDFD", size: 20)
                TextField("Reply, @ to tag someone", text: $composer.draft, axis: .vertical)
                    .dsText(DS.Text.bodySm)
                    .lineLimit(1...5)
                    .focused($composeFocused)
                    .onChange(of: composer.draft) { _, new in
                        // Enter submits (vertical TextField inserts a newline).
                        if new.hasSuffix("\n") {
                            composer.draft = String(new.dropLast())
                            composer.submit()
                        }
                    }
                sendButton
            }
            .padding(DS.Space.sm)
            .frame(maxWidth: .infinity)
            .background(DS.ColorToken.background, in: RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(RoundedRectangle(cornerRadius: DS.Radius.md)
                .stroke(DS.ColorToken.border, lineWidth: 1))
        }
        .padding(DS.Space.smd)
        .background(Color(hex: "#ECF0FF"), in: RoundedRectangle(cornerRadius: DS.Radius.lg))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg).stroke(DS.ColorToken.border, lineWidth: 1))
    }

    private var sendButton: some View {
        let empty = composer.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return Button { composer.submit() } label: {
            Group {
                if composer.submitting {
                    ProgressView().controlSize(.mini).tint(.white)
                } else {
                    Image(systemName: "arrow.up").font(.system(size: 11, weight: .bold))
                        .foregroundStyle(empty ? DS.ColorToken.textDisabled : .white)
                }
            }
            .frame(width: 24, height: 24)
            // Rounded square — grey when empty, Atlas blue when ready / loading.
            .background(empty && !composer.submitting ? DS.ColorToken.border : DS.ColorToken.primary,
                        in: RoundedRectangle(cornerRadius: DS.Radius.md))
        }
        .buttonStyle(.plain)
        .disabled(empty || composer.submitting)
    }

    // MARK: Markups

    private var markupsTool: some View {
        VStack(alignment: .leading, spacing: DS.Space.smd) {
            sectionTitle("Markups").padding(.top, DS.Space.xs)
            docHeader
            scroll {
                ForEach(ReaderMock.markupPages) { page in
                    MarkupPageRow(page: page,
                                  expanded: expandedMarkup == page.page,
                                  toggle: { expandedMarkup = expandedMarkup == page.page ? nil : page.page })
                }
            }
        }
    }

    // MARK: Bookmarks

    private var bookmarksTool: some View {
        VStack(alignment: .leading, spacing: DS.Space.smd) {
            sectionTitle("Bookmarks").padding(.top, DS.Space.xs)
            docHeader
            scroll {
                ForEach(Array(ReaderMock.bookmarks.enumerated()), id: \.element.id) { i, b in
                    BookmarkRow(bookmark: b, selected: i == 2)
                }
            }
        }
    }

    // MARK: helpers

    @ViewBuilder
    private func scroll<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Space.sm) { content() }
        }
        .scrollIndicators(.hidden)
    }

    private func atlasTab(_ title: String, _ index: Int, binding: Binding<Int>) -> some View {
        Button { binding.wrappedValue = index } label: {
            Text(title)
                .dsText(DS.Text.bodySmEmph,
                        color: binding.wrappedValue == index ? DS.ColorToken.textPrimary : DS.ColorToken.textMuted)
                .padding(.horizontal, DS.Space.smd)
                .padding(.bottom, DS.Space.smd)
                .overlay(alignment: .bottom) {
                    if binding.wrappedValue == index {
                        Rectangle().fill(DS.ColorToken.primaryStrong).frame(height: 2)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Atlas segmented tool switcher (grey pill track, white selected thumb)

private struct AtlasToolSegmented: View {
    @Binding var tab: PanelTab
    @Namespace private var seg

    var body: some View {
        HStack(spacing: 0) {
            ForEach(PanelTab.allCases, id: \.self) { t in
                Button {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) { tab = t }
                } label: {
                    ZStack {
                        if tab == t {
                            Capsule()
                                .fill(DS.ColorToken.background)
                                .shadow(color: .black.opacity(0.10), radius: 3, y: 1)
                                .overlay(Capsule().stroke(.white.opacity(0.6), lineWidth: 0.5))
                                .matchedGeometryEffect(id: "thumb", in: seg)
                        }
                        Image(t.asset)
                            .renderingMode(.template)
                            .resizable().scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(tab == t ? DS.ColorToken.primaryStrong : DS.ColorToken.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .frame(height: 44)
        .background(DS.ColorToken.surfaceMuted, in: Capsule())
    }
}

// MARK: - Outline row (structure)

private struct OutlineRow: View {
    let node: OutlineNode
    var body: some View {
        HStack(spacing: DS.Space.sm) {
            // Files keep a leading document icon; sections right-align a disclosure chevron.
            if node.isFile {
                Image(systemName: "doc.text")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DS.ColorToken.textMuted)
                    .frame(width: 16)
            }
            Text(node.title)
                .dsText(node.isFile ? DS.Text.bodySm : DS.Text.bodySmEmph,
                        color: node.isFile ? DS.ColorToken.textMuted : DS.ColorToken.textPrimary)
                .lineLimit(2)
            Spacer(minLength: 0)
            if !node.isFile {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DS.ColorToken.textPrimary)
            }
        }
        .padding(.vertical, DS.Space.sm)
        .padding(.leading, CGFloat(node.level) * 16)
    }
}

// MARK: - File tree row (file viewer structure)

private struct FileTreeRow: View {
    let node: ReaderMock.FileNode
    var body: some View {
        HStack(spacing: DS.Space.sm) {
            Image(systemName: node.icon)
                .font(.system(size: 15))
                .foregroundStyle(DS.ColorToken.textMuted)
                .frame(width: 18)
            Text(node.name)
                .dsText(DS.Text.bodySm,
                        color: node.selected ? DS.ColorToken.link : DS.ColorToken.textPrimary)
                .lineLimit(2)
            Spacer(minLength: 0)
            if let chevron = node.chevron {
                Image(systemName: chevron)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DS.ColorToken.textPrimary)
            }
        }
        .padding(.vertical, DS.Space.sm)
        .padding(.trailing, DS.Space.sm)
        .padding(.leading, DS.Space.sm + CGFloat(node.level) * 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(node.selected ? DS.ColorToken.accentTint : .clear,
                    in: RoundedRectangle(cornerRadius: DS.Radius.md))
    }
}

// MARK: - Thumbnail card

private struct ThumbnailCard: View {
    let page: Int
    let selected: Bool
    var body: some View {
        VStack(spacing: DS.Space.sm) {
            RoundedRectangle(cornerRadius: DS.Radius.sm)
                .fill(DS.ColorToken.background)
                .frame(height: 220)
                .overlay(
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(0..<12, id: \.self) { _ in
                            Rectangle().fill(DS.ColorToken.border).frame(height: 3)
                        }
                    }
                    .padding(14)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.sm)
                        .stroke(selected ? DS.ColorToken.primaryStrong : DS.ColorToken.border,
                                lineWidth: selected ? 2 : 1)
                )
                .frame(maxWidth: .infinity)

            if selected {
                Text("\(page)").dsText(DS.Text.labelSm, color: .white)
                    .padding(.horizontal, DS.Space.sm).frame(height: 22)
                    .background(DS.ColorToken.primaryStrong, in: Capsule())
            } else {
                Text("\(page)").dsText(DS.Text.bodySm, color: DS.ColorToken.textPrimary)
            }
        }
        .padding(.horizontal, DS.Space.xl)
    }
}

// MARK: - Search result card

private struct SearchResultCard: View {
    let result: SearchResult
    let selected: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text(result.page).dsText(DS.Text.bodySm, color: DS.ColorToken.textMuted)
            (Text(result.lead + " ").font(DS.Text.bodySmEmph.font).foregroundColor(DS.ColorToken.textPrimary)
             + Text(result.snippet).font(DS.Text.bodySm.font).foregroundColor(DS.ColorToken.textMuted))
                .lineSpacing(3)
        }
        .padding(DS.Space.smd)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(selected ? DS.ColorToken.accentTint : DS.ColorToken.background,
                    in: RoundedRectangle(cornerRadius: DS.Radius.md))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.md)
            .stroke(selected ? DS.ColorToken.primaryStrong.opacity(0.4) : DS.ColorToken.border, lineWidth: 1))
    }
}

// MARK: - Note card

private struct NoteAvatar: View {
    let initials: String; let tint: String; var size: CGFloat = 28
    var body: some View {
        Circle().fill(Color(hex: tint)).frame(width: size, height: size)
            .overlay(Text(initials).dsText(DS.Text.labelXs, color: DS.ColorToken.textPrimary))
    }
}

private struct NoteCard: View {
    let note: BoardNote
    var focused: Bool = false
    var onTap: (() -> Void)? = nil
    var body: some View {
        // Thread = note + "show replies" + replies, separated by 16 (Figma).
        VStack(alignment: .leading, spacing: DS.Space.md) {
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                replyHeader(author: note.author, initials: note.initials, tint: note.tint,
                            timestamp: note.timestamp, trailing: true, visibility: note.visibility, avatar: 32)
                Text(note.body).dsText(DS.Text.bodySm, color: DS.ColorToken.textPrimary)
            }

            if note.earlierReplies > 0 {
                HStack(spacing: DS.Space.xs) {
                    Image(systemName: "ellipsis").font(.system(size: 13)).foregroundStyle(DS.ColorToken.textMuted)
                    Text("Show \(note.earlierReplies) earlier replies")
                        .dsText(DS.Text.labelSm, color: DS.ColorToken.textMuted)
                }
            }
            ForEach(note.replies) { reply in
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    replyHeader(author: reply.author, initials: reply.initials, tint: reply.tint,
                                timestamp: reply.timestamp, trailing: false, visibility: nil, avatar: 28)
                    Text(reply.body).dsText(DS.Text.bodySm, color: DS.ColorToken.textPrimary)
                }
                .padding(.leading, DS.Space.md)
            }
        }
        .padding(DS.Space.smd)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(focused ? Color(hex: "#ECF0FF") : DS.ColorToken.background,
                    in: RoundedRectangle(cornerRadius: DS.Radius.lg))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg).stroke(DS.ColorToken.border, lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }

    private func replyHeader(author: String, initials: String, tint: String, timestamp: String,
                             trailing: Bool, visibility: String?, avatar: CGFloat) -> some View {
        HStack(spacing: DS.Space.sm) {
            NoteAvatar(initials: initials, tint: tint, size: avatar)
            VStack(alignment: .leading, spacing: 0) {
                Text(author).dsText(DS.Text.bodySmEmph)
                Text(timestamp).dsText(DS.Text.labelXs, color: DS.ColorToken.textMuted)
            }
            Spacer(minLength: 0)
            if trailing {
                if let visibility {
                    Image(systemName: visibility).font(.system(size: 13)).foregroundStyle(DS.ColorToken.textMuted)
                }
                Image(systemName: "ellipsis").font(.system(size: 14)).foregroundStyle(DS.ColorToken.textMuted)
            }
        }
    }
}

// MARK: - Markup page row

private struct MarkupPageRow: View {
    let page: MarkupPage
    let expanded: Bool
    let toggle: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: toggle) {
                HStack(spacing: DS.Space.sm) {
                    Image(systemName: expanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 12, weight: .semibold)).foregroundStyle(DS.ColorToken.textPrimary)
                        .frame(width: 16)
                    Text(page.page).dsText(DS.Text.bodySmEmph)
                    Spacer()
                    Text("\(page.count)").dsText(DS.Text.labelSm, color: DS.ColorToken.textMuted)
                        .frame(width: 24, height: 24)
                        .overlay(Circle().stroke(DS.ColorToken.border, lineWidth: 1))
                }
                .frame(height: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expanded {
                ForEach(Array(page.tools.enumerated()), id: \.element.id) { i, tool in
                    HStack(spacing: DS.Space.sm) {
                        Image(systemName: tool.symbol).font(.system(size: 15))
                            .foregroundStyle(DS.ColorToken.textPrimary).frame(width: 20)
                        Text(tool.name).dsText(DS.Text.bodySm)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, DS.Space.sm)
                    .frame(height: 40)
                    .background(i == 1 ? DS.ColorToken.accentTint : .clear,
                                in: RoundedRectangle(cornerRadius: DS.Radius.md))
                    .padding(.leading, DS.Space.lg)
                }
            }
        }
    }
}

// MARK: - Bookmark row

private struct BookmarkRow: View {
    let bookmark: Bookmark
    let selected: Bool
    var body: some View {
        HStack(spacing: DS.Space.smd) {
            Image(systemName: "bookmark").font(.system(size: 16))
                .foregroundStyle(DS.ColorToken.textPrimary).frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(bookmark.page).dsText(DS.Text.bodySmEmph)
                Text(bookmark.section).dsText(DS.Text.bodySm, color: DS.ColorToken.textMuted).lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, DS.Space.smd)
        .padding(.vertical, DS.Space.sm)
        .background(selected ? DS.ColorToken.accentTint : .clear,
                    in: RoundedRectangle(cornerRadius: DS.Radius.md))
    }
}
