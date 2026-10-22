import SwiftUI

/// The book reader document: the bundled sample PDF with a working annotation
/// toolbar that mirrors the Figma "Annotations" design and the web app's live
/// behavior — underline / pen / freehand highlighter / text-highlight, each with
/// a color picker (pen & highlighter also a width picker), tap-to-erase, and
/// undo / redo. Drag across the page with a tool selected to mark it.
struct DocumentPage: View {
    @ObservedObject var composer: NoteComposer
    @ObservedObject private var book = PDFBook.shared

    // MARK: Tool model

    enum AnnoTool: String, Hashable, CaseIterable {
        case underline, pen, highlighter, textHighlight

        var asset: String {
            switch self {
            case .underline: return "ic_anno_underline"
            case .pen: return "ic_anno_pen"
            case .highlighter: return "ic_anno_highlight"
            case .textHighlight: return "ic_anno_strike"   // 𝒜a glyph
            }
        }
        var hasWidth: Bool { self == .pen || self == .highlighter }
        var isHighlight: Bool { self == .highlighter || self == .textHighlight }
    }

    /// One placed mark. `points` holds the full freehand path (pen/highlighter)
    /// or just [start, end] for the straight underline / text-highlight band.
    struct Mark: Identifiable {
        let id = UUID()
        let tool: AnnoTool
        let color: Color
        let width: CGFloat
        var points: [CGPoint]
    }

    // Solid palette (pen, underline) and translucent palette (highlighters).
    static let solidPalette: [Color] = [
        Color(hex: "#232429"), Color(hex: "#1C4EE4"), Color(hex: "#E5484D"), Color(hex: "#2E9E5B"),
    ]
    static let hlPalette: [Color] = [
        Color(hex: "#FFE86B"), Color(hex: "#BDEB97"), Color(hex: "#A9D4FF"), Color(hex: "#FFB1C4"),
    ]
    static let penWidths: [CGFloat] = [2, 3.5, 5, 8]
    static let hlWidths: [CGFloat] = [12, 18, 24, 32]

    // MARK: State

    private static func argTool() -> AnnoTool? {
        switch ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("-anno=") })?
            .replacingOccurrences(of: "-anno=", with: "") {
        case "underline": return .underline
        case "pen": return .pen
        case "highlight": return .highlighter
        case "texthl", "text": return .textHighlight
        default: return nil
        }
    }

    @State private var tool: AnnoTool? = DocumentPage.argTool()
    @State private var eraseMode = ProcessInfo.processInfo.arguments.contains("-erase")
    @State private var openPopover: Popover = DocumentPage.argPopover()
    enum Popover { case none, color, width }

    private static func argPopover() -> Popover {
        guard argTool() != nil else { return .none }
        switch ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("-popover=") })?
            .replacingOccurrences(of: "-popover=", with: "") {
        case "color": return .color
        case "width": return .width
        default: return .none
        }
    }

    @State private var colorIndex: [AnnoTool: Int] = [.underline: 0, .pen: 0, .highlighter: 0, .textHighlight: 0]
    @State private var widthIndex: [AnnoTool: Int] = [.pen: 1, .highlighter: 1]

    @State private var marks: [Mark] = DocumentPage.argTool() == nil ? [] : DocumentPage.seedMarks()
    @State private var current: [CGPoint] = []
    // Snapshot-based undo / redo.
    @State private var undoStack: [[Mark]] = []
    @State private var redoStack: [[Mark]] = []

    // Page-number pill (mirrors the resource-center file viewer).
    private static let pageArgs = ProcessInfo.processInfo.arguments
    @State private var currentPage = pageArgs.contains("-pageNum") || pageArgs.contains("-pageEntry") ? 3 : 1
    @State private var showPill = pageArgs.contains("-pageNum") || pageArgs.contains("-pageEntry")
    @State private var showEntry = pageArgs.contains("-pageEntry")
    @State private var pillHideWork: DispatchWorkItem?
    // Per-page bookmark state (Figma "Bookmark status" — Saved? False/True variant).
    @State private var bookmarkedPages: Set<Int> = pageArgs.contains("-bookmarked") ? [0] : []
    // Demo captures (-pageNum / -pageEntry) pin the pill visible for screenshots.
    private static let pillPinned = pageArgs.contains("-pageNum") || pageArgs.contains("-pageEntry")
    private struct ScrollInfo: Equatable { var offset: CGFloat; var maxOffset: CGFloat }
    private var totalPages: Int { max(1, book.pageCount) }

    private static func seedMarks() -> [Mark] {
        [
            Mark(tool: .highlighter, color: hlPalette[0], width: hlWidths[1],
                 points: (0..<20).map { CGPoint(x: 100 + Double($0) * 18, y: 250 + sin(Double($0) / 3) * 10) }),
            Mark(tool: .underline, color: solidPalette[1], width: 2.5,
                 points: [CGPoint(x: 100, y: 330), CGPoint(x: 470, y: 330)]),
            Mark(tool: .pen, color: solidPalette[0], width: penWidths[1],
                 points: (0..<24).map { CGPoint(x: 120 + Double($0) * 14, y: 430 + sin(Double($0) / 2) * 16) }),
        ]
    }

    /// Show the page pill while the reader is actively scrolling, then fade it
    /// back out shortly after scrolling stops — so it never sits statically on
    /// the page. Staying near the top keeps it hidden.
    private func revealPillWhileScrolling(atTop: Bool) {
        guard !Self.pillPinned else { return }   // pinned for demo screenshots
        pillHideWork?.cancel()
        if atTop {
            withAnimation(.easeOut(duration: 0.2)) { showPill = false }
            return
        }
        withAnimation(.easeOut(duration: 0.15)) { showPill = true }
        guard !showEntry else { return }         // keep visible while the entry popover is open
        let work = DispatchWorkItem {
            withAnimation(.easeOut(duration: 0.3)) { showPill = false }
        }
        pillHideWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
    }

    // MARK: Body

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(spacing: DS.Space.md) {
                    ForEach(0..<book.pageCount, id: \.self) { i in
                        PDFPageView(book: book, index: i)
                            .overlay(alignment: .topTrailing) { bookmark(page: i) }
                    }
                    if book.pageCount == 0 {
                        Text("Couldn't load document.").dsText(DS.Text.bodyMd, color: DS.ColorToken.textMuted)
                            .padding(DS.Space.xxl)
                    }
                    Color.clear.frame(height: 80)
                }
                .padding(DS.Space.lg)
                .overlay {
                    ZStack {
                        annotationCanvas
                        if eraseMode {
                            Color.black.opacity(0.001)
                                .contentShape(Rectangle())
                                .onTapGesture(coordinateSpace: .named("doc")) { eraseAt($0) }
                        }
                    }
                }
                .coordinateSpace(name: "doc")
                .simultaneousGesture(drawGesture)
            }
            .scrollDisabled(tool != nil || eraseMode)   // lock scroll while annotating
            .onScrollGeometryChange(for: ScrollInfo.self) { geo in
                ScrollInfo(offset: geo.contentOffset.y,
                           maxOffset: max(1, geo.contentSize.height - geo.containerSize.height))
            } action: { _, info in
                let progress = min(1, max(0, info.offset / info.maxOffset))
                currentPage = min(totalPages, max(1, Int(progress * Double(totalPages - 1)) + 1))
                revealPillWhileScrolling(atTop: info.offset <= 24)
            }

            if composer.mode != .placing {
                annotationToolbar
                    .padding(.bottom, DS.Space.lg)
            }
        }
        .background(DS.ColorToken.background, in: RoundedRectangle(cornerRadius: DS.Radius.lg16))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg16))
        .overlay { placementLayer }
        .overlay(alignment: .topLeading) {
            if showPill || showEntry {
                PageNumberControl(currentPage: $currentPage, showEntry: $showEntry, totalPages: totalPages)
                    .padding(.top, DS.Space.md)
                    .padding(.leading, DS.Space.md)
                    .transition(.opacity)
            }
        }
    }

    // Bookmark — Figma "Bookmark status": a 40pt glyph pinned to the top-right
    // of each page with a 40pt right inset. Tapping toggles the filled
    // "saved" state for that page independently.
    private func bookmark(page i: Int) -> some View {
        let saved = bookmarkedPages.contains(i)
        return Button {
            withAnimation(.easeOut(duration: 0.15)) {
                if saved { bookmarkedPages.remove(i) } else { bookmarkedPages.insert(i) }
            }
        } label: {
            Image(systemName: saved ? "bookmark.fill" : "bookmark")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundStyle(DS.ColorToken.textPrimary)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.trailing, 40)
    }


    // MARK: Drawing

    private var drawGesture: some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .named("doc"))
            .onChanged { v in
                guard tool != nil else { return }
                if current.isEmpty { current = [v.startLocation] }
                current.append(v.location)
            }
            .onEnded { _ in
                defer { current = [] }
                guard let t = tool, current.count > 1 else { return }
                let pts = t.hasWidth ? current : [current.first!, current.last!]
                commit(marks + [Mark(tool: t, color: color(t), width: width(t), points: pts)])
            }
    }

    private var annotationCanvas: some View {
        Canvas { ctx, _ in
            for m in marks { drawMark(m, in: ctx) }
            if let t = tool, current.count > 1 {
                drawMark(Mark(tool: t, color: color(t), width: width(t), points: current), in: ctx)
            }
        }
        .allowsHitTesting(false)
    }

    private func drawMark(_ m: Mark, in ctx: GraphicsContext) {
        let xs = m.points.map(\.x), ys = m.points.map(\.y)
        guard let minX = xs.min(), let maxX = xs.max(), let minY = ys.min(), let maxY = ys.max() else { return }
        switch m.tool {
        case .pen:
            var p = Path(); p.move(to: m.points[0]); m.points.dropFirst().forEach { p.addLine(to: $0) }
            ctx.stroke(p, with: .color(m.color), style: .init(lineWidth: m.width, lineCap: .round, lineJoin: .round))
        case .highlighter:
            var p = Path(); p.move(to: m.points[0]); m.points.dropFirst().forEach { p.addLine(to: $0) }
            ctx.stroke(p, with: .color(m.color.opacity(0.4)),
                       style: .init(lineWidth: m.width, lineCap: .round, lineJoin: .round))
        case .underline:
            var p = Path(); p.move(to: CGPoint(x: minX, y: maxY)); p.addLine(to: CGPoint(x: maxX, y: maxY))
            ctx.stroke(p, with: .color(m.color), style: .init(lineWidth: m.width, lineCap: .round))
        case .textHighlight:
            let y = (minY + maxY) / 2
            let rect = CGRect(x: minX, y: y - 11, width: maxX - minX, height: 22)
            ctx.fill(Path(roundedRect: rect, cornerRadius: 3), with: .color(m.color.opacity(0.42)))
        }
    }

    // MARK: Resolved tool attributes

    private func palette(_ t: AnnoTool) -> [Color] { t.isHighlight ? Self.hlPalette : Self.solidPalette }
    private func color(_ t: AnnoTool) -> Color { palette(t)[colorIndex[t] ?? 0] }
    private func width(_ t: AnnoTool) -> CGFloat {
        switch t {
        case .pen: return Self.penWidths[widthIndex[t] ?? 1]
        case .highlighter: return Self.hlWidths[widthIndex[t] ?? 1]
        case .underline: return 2.5
        case .textHighlight: return 22
        }
    }

    // MARK: Mutations (undo / redo / erase)

    private func commit(_ new: [Mark]) {
        undoStack.append(marks); redoStack.removeAll()
        marks = new
    }
    private func undo() {
        guard let last = undoStack.popLast() else { return }
        redoStack.append(marks)
        withAnimation(.easeOut(duration: 0.12)) { marks = last }
    }
    private func redo() {
        guard let last = redoStack.popLast() else { return }
        undoStack.append(marks)
        withAnimation(.easeOut(duration: 0.12)) { marks = last }
    }
    private func eraseAt(_ p: CGPoint) {
        // Remove the top-most mark within a small hit radius of the tap.
        if let idx = marks.lastIndex(where: { hitTest($0, p, radius: 16) }) {
            var next = marks; next.remove(at: idx)
            commit(next)
        }
    }

    private func hitTest(_ m: Mark, _ p: CGPoint, radius: CGFloat) -> Bool {
        if m.tool == .textHighlight {
            let xs = m.points.map(\.x), ys = m.points.map(\.y)
            guard let minX = xs.min(), let maxX = xs.max(), let minY = ys.min(), let maxY = ys.max() else { return false }
            return CGRect(x: minX, y: minY - 12, width: maxX - minX, height: (maxY - minY) + 24)
                .insetBy(dx: -radius, dy: -radius).contains(p)
        }
        let pad = max(radius, m.width / 2 + 6)
        for i in 1..<max(m.points.count, 2) where i < m.points.count {
            if distance(p, m.points[i - 1], m.points[i]) <= pad { return true }
        }
        return false
    }

    /// Distance from point `p` to segment `a`–`b`.
    private func distance(_ p: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = b.x - a.x, dy = b.y - a.y
        let len2 = dx * dx + dy * dy
        if len2 == 0 { return hypot(p.x - a.x, p.y - a.y) }
        var t = ((p.x - a.x) * dx + (p.y - a.y) * dy) / len2
        t = min(max(t, 0), 1)
        return hypot(p.x - (a.x + t * dx), p.y - (a.y + t * dy))
    }

    private var hasAny: Bool { !marks.isEmpty }

    // MARK: Toolbar

    private func selectTool(_ t: AnnoTool) {
        withAnimation(.snappy(duration: 0.2)) {
            eraseMode = false
            if tool == t { tool = nil; openPopover = .none }
            else { tool = t; openPopover = .none }
        }
    }

    private var annotationToolbar: some View {
        HStack(alignment: .center, spacing: DS.Space.smd) {
            // Left capsule — undo / redo.
            HStack(spacing: 0) {
                toolbarIcon("arrow.uturn.backward", enabled: !undoStack.isEmpty) { undo() }
                toolbarIcon("arrow.uturn.forward", enabled: !redoStack.isEmpty) { redo() }
            }
            .padding(.horizontal, DS.Space.sm)
            .frame(height: 56)
            .glassSurface(Capsule())

            // Right capsule — tools, inline chips, trash.
            HStack(spacing: DS.Space.xs) {
                ForEach(AnnoTool.allCases, id: \.self) { t in
                    toolButton(t)
                    if tool == t {
                        colorChip(t)
                        if t.hasWidth { widthChip(t) }
                    }
                }
                trashButton
            }
            .padding(.horizontal, DS.Space.smd)
            .frame(height: 56)
            .glassSurface(Capsule())
            .overlay(alignment: .top) {
                if openPopover != .none, let t = tool {
                    popover(for: t).offset(y: -62)
                        .transition(.scale(scale: 0.9, anchor: .bottom).combined(with: .opacity))
                }
            }
        }
    }

    private func toolbarIcon(_ symbol: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol).font(.system(size: 17, weight: .regular))
                .foregroundStyle(DS.ColorToken.textPrimary)
                .opacity(enabled ? 1 : 0.3)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    private func toolButton(_ t: AnnoTool) -> some View {
        let active = tool == t
        return Button { selectTool(t) } label: {
            Image(t.asset).renderingMode(.template).resizable().scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(active ? DS.ColorToken.link : DS.ColorToken.textPrimary)
                .frame(width: 44, height: 44)
                .background(active ? DS.ColorToken.accentTintStrong : .clear,
                            in: RoundedRectangle(cornerRadius: DS.Radius.lg))
        }
        .buttonStyle(.plain)
    }

    // Filled color swatch with a checkmark — tap to open the color popover.
    private func colorChip(_ t: AnnoTool) -> some View {
        let c = color(t)
        return Button {
            withAnimation(.snappy(duration: 0.2)) { openPopover = openPopover == .color ? .none : .color }
        } label: {
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .fill(c)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "checkmark").font(.system(size: 14, weight: .bold))
                        .foregroundStyle(isLight(c) ? DS.ColorToken.textPrimary : .white)
                )
                .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg)
                    .stroke(.black.opacity(0.08), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // Stroke-width preview chip (pen & highlighter) — tap to open the width popover.
    private func widthChip(_ t: AnnoTool) -> some View {
        Button {
            withAnimation(.snappy(duration: 0.2)) { openPopover = openPopover == .width ? .none : .width }
        } label: {
            widthGlyph(t, w: width(t), length: 22)
                .frame(width: 44, height: 44)
                .background(openPopover == .width ? DS.ColorToken.surfaceMuted : .clear,
                            in: RoundedRectangle(cornerRadius: DS.Radius.lg))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var trashButton: some View {
        Button {
            withAnimation(.snappy(duration: 0.2)) {
                if eraseMode { eraseMode = false }
                else { eraseMode = true; tool = nil; openPopover = .none }
            }
        } label: {
            Image(systemName: "trash").font(.system(size: 18))
                .foregroundStyle(eraseMode ? DS.ColorToken.link : DS.ColorToken.textPrimary)
                .opacity(hasAny || eraseMode ? 1 : 0.3)
                .frame(width: 44, height: 44)
                .background(eraseMode ? DS.ColorToken.accentTintStrong : .clear,
                            in: RoundedRectangle(cornerRadius: DS.Radius.lg))
        }
        .buttonStyle(.plain)
        .disabled(!hasAny && !eraseMode)
    }

    // MARK: Popovers

    @ViewBuilder
    private func popover(for t: AnnoTool) -> some View {
        switch openPopover {
        case .color:
            HStack(spacing: DS.Space.md) {
                ForEach(Array(palette(t).enumerated()), id: \.offset) { i, c in
                    Button {
                        withAnimation(.snappy(duration: 0.18)) { colorIndex[t] = i }
                    } label: {
                        Circle().fill(c).frame(width: 28, height: 28)
                            .overlay(Circle().stroke(.black.opacity(0.08), lineWidth: 1))
                            .overlay {
                                if (colorIndex[t] ?? 0) == i {
                                    Circle().stroke(DS.ColorToken.link, lineWidth: 2).padding(-4)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DS.Space.md)
            .frame(height: 52)
            .glassSurface(Capsule())
        case .width:
            HStack(spacing: DS.Space.sm) {
                let widths = t == .pen ? Self.penWidths : Self.hlWidths
                ForEach(Array(widths.enumerated()), id: \.offset) { i, w in
                    Button {
                        withAnimation(.snappy(duration: 0.18)) { widthIndex[t] = i }
                    } label: {
                        widthGlyph(t, w: w, length: 26)
                            .frame(width: 40, height: 40)
                            .background((widthIndex[t] ?? 1) == i ? DS.ColorToken.accentTintStrong : .clear,
                                        in: RoundedRectangle(cornerRadius: DS.Radius.md))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DS.Space.smd)
            .frame(height: 52)
            .glassSurface(Capsule())
        case .none:
            EmptyView()
        }
    }

    // A diagonal stroke preview whose thickness reflects `w`.
    private func widthGlyph(_ t: AnnoTool, w: CGFloat, length: CGFloat) -> some View {
        let c = color(t)
        return Path { p in
            p.move(to: CGPoint(x: 0, y: length))
            p.addLine(to: CGPoint(x: length, y: 0))
        }
        .stroke(t.isHighlight ? c.opacity(0.65) : c,
                style: .init(lineWidth: min(w, 10), lineCap: .round))
        .frame(width: length, height: length)
    }

    private func isLight(_ c: Color) -> Bool {
        let ui = UIColor(c)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (0.299 * r + 0.587 * g + 0.114 * b) > 0.62
    }

    // MARK: Note-taking placement

    @ViewBuilder private var placementLayer: some View {
        ZStack {
            if composer.mode == .placing {
                Color.black.opacity(0.001)
                    .contentShape(Rectangle())
                    .onTapGesture(coordinateSpace: .local) { composer.place(at: $0) }
                VStack { placeHint; Spacer() }
                    .padding(.top, DS.Space.md)
                    .allowsHitTesting(false)
            } else if composer.focusedNoteId != nil {
                Color.black.opacity(0.001)
                    .contentShape(Rectangle())
                    .onTapGesture { composer.unfocus() }
            }
            ForEach(composer.pins) { pin in
                let focused = !pin.committed || pin.noteId == composer.focusedNoteId
                NotePin(pin: pin, focused: focused)
                    .onTapGesture { if pin.committed { composer.focus(pin.noteId) } }
                    .position(pin.point)
            }
        }
    }

    private var placeHint: some View {
        HStack(spacing: DS.Space.sm) {
            Image(systemName: "hand.tap").font(.system(size: 14))
            Text("Tap anywhere on the document to place your note")
                .dsText(DS.Text.bodySm, color: .white)
        }
        .padding(.horizontal, DS.Space.md)
        .frame(height: 40)
        .background(Color(hex: "#232429"), in: Capsule())
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.18), radius: 12, y: 4)
    }
}

/// Avatar marker dropped on the document for a note.
private struct NotePin: View {
    let pin: PlacedPin
    var focused: Bool
    private var bubble: UnevenRoundedRectangle {
        UnevenRoundedRectangle(cornerRadii: .init(topLeading: 16, bottomLeading: 0,
                                                  bottomTrailing: 16, topTrailing: 16))
    }
    private var avatar: some View {
        Circle()
            .fill(Color(hex: pin.tint))
            .frame(width: 24, height: 24)
            .overlay(Text(pin.initials).font(.system(size: 11, weight: .medium))
                .foregroundStyle(DS.ColorToken.neutralFg))
    }
    var body: some View {
        Group {
            if focused {
                bubble.fill(DS.ColorToken.primaryStrong).frame(width: 32, height: 32).overlay(avatar)
            } else {
                avatar.padding(2).background(Circle().fill(.white))
            }
        }
        .shadow(color: .black.opacity(0.18), radius: 6, y: 2)
        .transition(.scale.combined(with: .opacity))
    }
}
