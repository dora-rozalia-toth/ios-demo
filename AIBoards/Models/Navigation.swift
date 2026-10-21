import SwiftUI

/// Top-level destinations shown in the sidebar.
enum AppSection: String, CaseIterable, Identifiable {
    case home = "Home"
    case books = "Books"
    case resourceCenter = "Resource center"
    case decisionHub = "Decision hub"

    var id: String { rawValue }

    /// Bundled icon asset exported from the Figma icon set.
    var asset: String {
        switch self {
        case .home: return "ic_nav_home"
        case .books: return "ic_nav_books"
        case .resourceCenter: return "ic_nav_resource"
        case .decisionHub: return "ic_nav_decision"
        }
    }
}

/// Drives sidebar selection and in-section drill-downs (book viewer, file viewer).
/// Centered card modals that float above the whole shell.
enum ModalRoute: Identifiable {
    case profile
    case booksFilter
    case decisionFilter
    case meetingDetails(Book)

    var id: String {
        switch self {
        case .profile: return "profile"
        case .booksFilter: return "booksFilter"
        case .decisionFilter: return "decisionFilter"
        case .meetingDetails(let b): return "meeting-\(b.id)"
        }
    }
}

@MainActor
final class AppModel: ObservableObject {
    @Published var section: AppSection = .home
    /// When set, the book viewer is presented over the Books section.
    @Published var openBook: Book? = nil
    /// When set, the resource-center file viewer is presented.
    @Published var openFile: ResourceFile? = nil
    /// Active centered card modal, if any.
    @Published var modal: ModalRoute? = nil
    /// Whether the main navigation sidebar is collapsed.
    @Published var sidebarCollapsed = false

    init() {
        // Launch-argument hooks so any state can be screenshotted headlessly.
        let args = ProcessInfo.processInfo.arguments
        func value(_ key: String) -> String? {
            guard let i = args.firstIndex(of: key), i + 1 < args.count else { return nil }
            return args[i + 1]
        }
        switch value("-section") {
        case "books": section = .books
        case "resource": section = .resourceCenter
        case "decision": section = .decisionHub
        default: break
        }
        if args.contains("-collapsed") { sidebarCollapsed = true }
        if value("-openBook") == "1" { openBook = Mock.books.first }
        if value("-openFile") == "1" { section = .resourceCenter; openFile = Mock.resourceFiles.first }
        switch value("-modal") {
        case "profile": modal = .profile
        case "booksFilter": section = .books; modal = .booksFilter
        case "decisionFilter": section = .decisionHub; modal = .decisionFilter
        case "meetingDetails": section = .books; modal = .meetingDetails(Mock.books[0])
        default: break
        }
    }

    func select(_ section: AppSection) {
        openBook = nil
        openFile = nil
        modal = nil
        self.section = section
    }

    func present(_ route: ModalRoute) { modal = route }
    func dismissModal() { modal = nil }
}
