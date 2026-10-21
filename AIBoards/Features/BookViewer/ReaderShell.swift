import SwiftUI

enum PanelTab: CaseIterable {
    case structure, search, notes, markups, bookmarks
    /// Bundled asset exported from the Figma icon set.
    var asset: String {
        switch self {
        case .structure: return "ic_structure"
        case .search: return "ic_search"
        case .notes: return "ic_notes"
        case .markups: return "ic_markups"
        case .bookmarks: return "ic_bookmarks"
        }
    }
}

/// Full-screen document reader shared by the Book viewer and the File viewer.
struct ReaderShell: View {
    @EnvironmentObject var model: AppModel
    let title: String
    var showAI: Bool = true
    /// File viewer = book viewer minus the annotation/notes tools, with a paged
    /// document and page-number control instead of a bookmark.
    var isFile: Bool = false
    let onBack: () -> Void

    @State private var panelOpen: Bool = {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-panelClosed") { return false }
        // GovernAI open by default collapses the sidenav — space is tight.
        if args.contains("-ai") { return false }
        return true
    }()
    @State private var tab: PanelTab = {
        let arg = ProcessInfo.processInfo.arguments.first { $0.hasPrefix("-panel=") }?
            .replacingOccurrences(of: "-panel=", with: "")
        switch arg {
        case "search": return .search
        case "notes": return .notes
        case "markups": return .markups
        case "bookmarks": return .bookmarks
        default: return .structure
        }
    }()
    @State private var aiOpen = ProcessInfo.processInfo.arguments.contains("-ai")
    @StateObject private var composer = NoteComposer()

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: DS.Space.md) {
                if panelOpen {
                    ReaderPanel(tab: $tab, isFile: isFile, composer: composer, onCollapse: {
                        withAnimation(.easeInOut(duration: 0.22)) { panelOpen = false }
                    })
                    // Drop the panel so its top edge lines up with the top of the
                    // back-arrow button (the toolbar's 26pt top inset).
                    .padding(.top, 26)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                }
                documentColumn
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, DS.Space.md)
            .padding(.bottom, DS.Space.md)

            if showAI && aiOpen {
                GovernAIPanel { withAnimation(.easeInOut(duration: 0.25)) { aiOpen = false } }
                    .frame(width: 400)
                    .ignoresSafeArea(edges: .bottom)
                    .overlay(alignment: .leading) {
                        Rectangle().fill(DS.ColorToken.border).frame(width: 1).ignoresSafeArea()
                    }
                    .transition(.move(edge: .trailing))
            }
        }
        .overlay(alignment: .topTrailing) {
            if showAI {
                aiButton
                    .padding(.top, 26)
                    .padding(.trailing, DS.Space.smd)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: panelOpen)
        .animation(.easeInOut(duration: 0.25), value: aiOpen)
    }

    // Single GovernAI button — fixed position & size whether the panel is open or
    // closed, so it reads as the same control lifting the panel in/out.
    private var aiIcon: some View {
        Image("ic_ai").resizable().scaledToFit()
            .frame(width: 24, height: 24)
            .frame(width: 46, height: 46)
    }

    private var aiButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                aiOpen.toggle()
                // Opening GovernAI collapses the sidenav to free up width; the
                // user can reopen it manually with the expand control.
                if aiOpen { panelOpen = false }
            }
        } label: {
            // Glassy by default; fills with the Atlas blue tint while the panel is open.
            if aiOpen {
                aiIcon.background(DS.ColorToken.accentTint, in: Circle())
            } else {
                aiIcon.glassSurface(Circle())
            }
        }
        .buttonStyle(.plain)
    }

    // Document column = custom Liquid Glass toolbar + the scrolling page.
    private var documentColumn: some View {
        VStack(spacing: 0) {
            toolbar
            if isFile { FileDocumentPage() } else { DocumentPage(composer: composer) }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var toolbar: some View {
        HStack(spacing: DS.Space.sm) {
            // Expand control only appears when the sidenav is collapsed — in its
            // own Liquid Glass bubble, separate from the back button.
            if !panelOpen {
                glassCircle("sidebar.left") {
                    withAnimation(.easeInOut(duration: 0.22)) { panelOpen = true }
                }
                .transition(.scale.combined(with: .opacity))
            }
            glassCircle("chevron.backward") { onBack() }

            Text(title).dsText(DS.Text.h5).lineLimit(1)
                .padding(.leading, DS.Space.xs)

            Spacer(minLength: DS.Space.sm)
        }
        .padding(.horizontal, DS.Space.mdl)
        .padding(.top, 26)
        .padding(.bottom, DS.Space.sm)
    }

    private func glassCircle(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(DS.ColorToken.textPrimary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .glassSurface(Circle())
    }
}

struct BookViewer: View {
    @EnvironmentObject var model: AppModel
    let book: Book
    var body: some View {
        ReaderShell(title: book.title, showAI: true) { model.openBook = nil }
    }
}

struct FileViewer: View {
    @EnvironmentObject var model: AppModel
    let file: ResourceFile
    var body: some View {
        ReaderShell(title: file.name, showAI: false, isFile: true) { model.openFile = nil }
    }
}
