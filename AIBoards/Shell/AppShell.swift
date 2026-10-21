import SwiftUI

/// Root layout: radial page gradient, fixed top controls, Liquid Glass sidebar,
/// and the scrolling content for the selected section.
struct AppShell: View {
    @StateObject private var model = AppModel()

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [DS.ColorToken.pageTop, DS.ColorToken.pageBottom],
                center: .init(x: 0.5, y: 0.0), startRadius: 0, endRadius: 1100
            )
            .ignoresSafeArea()

            // Opening a book/file pushes in from the trailing edge over the shell.
            if let book = model.openBook {
                BookViewer(book: book)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else if let file = model.openFile {
                FileViewer(file: file)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                mainShell
                    .transition(.opacity)
            }
        }
        .animation(.snappy(duration: 0.34), value: model.openBook?.id)
        .animation(.snappy(duration: 0.34), value: model.openFile?.id)
        .overlay {
            ModalHost()
                .environmentObject(model)
        }
        .animation(.easeOut(duration: 0.18), value: model.modal?.id)
        .environmentObject(model)
        .tint(DS.ColorToken.primary)
    }

    private var mainShell: some View {
        VStack(spacing: 0) {
            TopControls()

            HStack(alignment: .top, spacing: DS.Space.md) {
                if !model.sidebarCollapsed {
                    Sidebar()
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
                content
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .id(model.section)                 // cross-fade when the section changes
                    .transition(.opacity)
            }
            .padding(.horizontal, DS.Space.md)
            .padding(.top, DS.Space.sm)
            .padding(.bottom, DS.Space.md)
            // One implicit spring drives both the content cross-fade and the
            // sidebar's selection pill, from any entry point (nav tap or "Go to…").
            .animation(.smooth(duration: 0.28), value: model.section)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch model.section {
        case .home:
            HomeView()
        case .books:
            BooksView()
        case .resourceCenter:
            ResourceCenterView()
        case .decisionHub:
            DecisionHubView()
        }
    }
}
