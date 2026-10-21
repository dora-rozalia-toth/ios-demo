import Foundation

// MARK: - Status

enum BookStatus: String {
    case archived = "Archived"
    case published = "Published"
}

enum ActionStatus: String {
    case inProgress = "In progress"
}

enum ApprovalResult {
    case approved, rejected, abstained, viewOnly, none
    var label: String? {
        switch self {
        case .approved: return "Approved by you"
        case .rejected: return "Rejected by you"
        case .abstained: return "Abstained by you"
        case .viewOnly: return "View only"
        case .none: return nil
        }
    }
}

enum ApprovalStatus: String {
    case concluded = "Concluded"
    case inProgress = "In progress"
    case awaiting = "Awaiting response"
}

// MARK: - Models

struct Book: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var status: BookStatus
    var meetingDate: String
    var committee: String
    var extraCommittees: Int
}

struct ActionItem: Identifiable {
    let id = UUID()
    var title: String
    var publishedOn: String
    var status: ActionStatus = .inProgress
}

struct CompetitorUpdate: Identifiable {
    let id = UUID()
    var title: String
    var source: String
    var date: String
    var body: String
}

struct ResourceFolder: Identifiable {
    let id = UUID()
    var name: String
    var lastModified: String
}

struct ResourceFile: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var lastModified: String
}

struct Approval: Identifiable {
    let id = UUID()
    var title: String
    var signatureKind: String      // "Diligent signature" / "DocuSign eSignature"
    var result: ApprovalResult
    var status: ApprovalStatus
    var date: String
    var progress: Int              // 0, 50, 100
    var needsResponse: Bool
}

// MARK: - Seed data (mirrors the Figma)

enum Mock {
    static let orgName = "Walmart U.S."

    static let actionItems: [ActionItem] = [
        .init(title: "Global Enterprise Board Governance Coordination, Committee Approval Management, Strategic Decision Lifecycle", publishedOn: "06/03/2026"),
        .init(title: "Regional Operations Compliance Oversight, Policy Review Process, Risk Management Framework", publishedOn: "07/04/2026"),
        .init(title: "Cross-Departmental Innovation Initiatives, Resource Allocation Strategies, Performance Measurement Systems", publishedOn: "08/05/2026"),
        .init(title: "Sustainability Practices Implementation, Environmental Impact Assessments, Stakeholder Engagement Plans", publishedOn: "09/06/2026"),
    ]

    static let upcomingBooks: [Book] = [
        .init(title: "The Digital Frontier: Embracing AI in Governance", status: .archived, meetingDate: "07/15/2026", committee: "Advisory board", extraCommittees: 3),
        .init(title: "The Governance Imperative: Rethinking Public Trust", status: .published, meetingDate: "06/03/2026", committee: "Main committee", extraCommittees: 2),
        .init(title: "Digital Democracy: Engaging Citizens in Decision Making", status: .published, meetingDate: "06/03/2026", committee: "Main committee", extraCommittees: 2),
        .init(title: "Sustainable Policies for Future Generations", status: .published, meetingDate: "06/03/2026", committee: "Main committee", extraCommittees: 2),
    ]

    static let books: [Book] = [
        .init(title: "The Digital Frontier: Embracing AI in Governance", status: .archived, meetingDate: "07/15/2026", committee: "Advisory board", extraCommittees: 3),
        .init(title: "The Governance Imperative: Rethinking Public Trust", status: .published, meetingDate: "06/03/2026", committee: "Main committee", extraCommittees: 2),
        .init(title: "Digital Democracy: Engaging Citizens in Decision Making", status: .published, meetingDate: "07/15/2026", committee: "Engagement panel", extraCommittees: 3),
        .init(title: "Sustainable Policies for Future Generations", status: .published, meetingDate: "05/20/2026", committee: "Policy advisory group", extraCommittees: 1),
        .init(title: "Data Privacy and Public Perception", status: .published, meetingDate: "08/02/2026", committee: "Research team", extraCommittees: 4),
        .init(title: "Crisis Management: Building Resilience in Communities", status: .archived, meetingDate: "07/30/2026", committee: "Crisis response unit", extraCommittees: 2),
        .init(title: "Innovations in Public Health: Lessons from the Pandemic", status: .published, meetingDate: "09/10/2026", committee: "Health committee", extraCommittees: 5),
        .init(title: "Environmental Policy: The Road Ahead", status: .archived, meetingDate: "06/25/2026", committee: "Sustainability group", extraCommittees: 3),
        .init(title: "Education Reform: Bridging the Gap", status: .published, meetingDate: "08/15/2026", committee: "Education board", extraCommittees: 4),
        .init(title: "The Governance Imperative: Rethinking Public Trust", status: .published, meetingDate: "06/03/2026", committee: "Main committee", extraCommittees: 2),
        .init(title: "Equity in Urban Planning: A New Framework", status: .archived, meetingDate: "09/05/2026", committee: "Urban development co.", extraCommittees: 2),
        .init(title: "Empowering Youth: The Future of Civic Engagement", status: .published, meetingDate: "10/01/2026", committee: "Youth initiatives team", extraCommittees: 3),
    ]

    static let competitorBody = "A key executive shift is underway at Marriott International. Leeny Oberg, the company's Chief Financial Officer since 2016, will retire on March 31, 2026, after navigating Marriott through pivotal periods including the COVID-19 pandemic."

    static let competitorUpdates: [CompetitorUpdate] = Array(repeating:
        CompetitorUpdate(title: "Marriott finance chief Leeny Oberg to retire next year", source: "Market Screener", date: "02/23/2027", body: competitorBody),
        count: 4
    )

    static let resourceFolders: [ResourceFolder] = [
        .init(name: "Contracts and agreements", lastModified: "06/03/2026"),
        .init(name: "Board MeetingCalls", lastModified: "06/03/2026"),
        .init(name: "Legal", lastModified: "06/03/2026"),
    ]

    static let resourceFiles: [ResourceFile] = [
        .init(name: "Master Services Agreement 2026", lastModified: "06/03/2026"),
        .init(name: "Vendor NDA — GlobalTech", lastModified: "06/01/2026"),
        .init(name: "Board Charter (Amended)", lastModified: "05/28/2026"),
        .init(name: "Quarterly Compliance Report Q2", lastModified: "05/20/2026"),
    ]

    static let approvals: [Approval] = [
        .init(title: "Fashion-Tech Quarterly Strategy Session", signatureKind: "Diligent signature", result: .approved, status: .concluded, date: "07/21/2025", progress: 100, needsResponse: false),
        .init(title: "Fashion-Tech Quarterly Strategy Session with a long-long title to show what happens…", signatureKind: "Diligent signature", result: .approved, status: .concluded, date: "07/21/2025", progress: 100, needsResponse: false),
        .init(title: "Fashion-Tech Quarterly Strategy Session", signatureKind: "Diligent signature", result: .rejected, status: .inProgress, date: "07/21/2025", progress: 50, needsResponse: false),
        .init(title: "Fashion-Tech Quarterly Strategy Session", signatureKind: "Diligent signature", result: .none, status: .inProgress, date: "07/21/2025", progress: 0, needsResponse: true),
        .init(title: "Fashion-Tech Quarterly Strategy Session", signatureKind: "Diligent signature", result: .none, status: .awaiting, date: "07/21/2025", progress: 0, needsResponse: true),
        .init(title: "Fashion-Tech Quarterly Strategy Session", signatureKind: "DocuSign eSignature", result: .viewOnly, status: .concluded, date: "07/21/2025", progress: 100, needsResponse: false),
        .init(title: "Fashion-Tech Quarterly Strategy Session", signatureKind: "DocuSign eSignature", result: .abstained, status: .concluded, date: "07/21/2025", progress: 100, needsResponse: false),
        .init(title: "Fashion-Tech Quarterly Strategy Session", signatureKind: "DocuSign eSignature", result: .none, status: .inProgress, date: "07/21/2025", progress: 50, needsResponse: true),
    ]

    static let promptChips = ["Find topics", "Prepare for meetings", "Monitor trends", "Show more"]

    // Book viewer outline (Structure tab)
    static let outline: [OutlineNode] = [
        .init(title: "Agenda", level: 0, hasChildren: true),
        .init(title: "1. Review of Key Financial Metrics", level: 0, hasChildren: true),
        .init(title: "Summary of the financial and audit director", level: 1, isFile: true),
        .init(title: "Proposals introduced in the very beginning and reviewed", level: 1, isFile: true),
        .init(title: "1.1. Revenue", level: 0, hasChildren: true),
        .init(title: "1.2. Expenses", level: 0, hasChildren: true),
        .init(title: "Secret ingredients", level: 1, isFile: true),
        .init(title: "1.2.1. What does the future hold?", level: 1, hasChildren: true),
        .init(title: "1.3. Profit Margins", level: 0, hasChildren: true),
    ]
}

struct OutlineNode: Identifiable {
    let id = UUID()
    var title: String
    var level: Int
    var hasChildren: Bool = false
    var isFile: Bool = false
}

// MARK: - Book viewer panel content

struct NoteReply: Identifiable {
    let id = UUID()
    var author: String
    var initials: String
    var tint: String   // avatar bg hex
    var timestamp: String
    var body: String
}

struct BoardNote: Identifiable {
    let id = UUID()
    var author: String
    var initials: String
    var tint: String
    var timestamp: String
    var body: String
    var visibility: String = "globe"  // SF symbol: globe / person.2
    var earlierReplies: Int = 0
    var replies: [NoteReply] = []
}

struct NotePage: Identifiable {
    let id = UUID()
    var page: String
    var notes: [BoardNote]
}

struct MarkupTool: Identifiable {
    let id = UUID()
    var name: String
    var symbol: String
}

struct MarkupPage: Identifiable {
    let id = UUID()
    var page: String
    var count: Int
    var tools: [MarkupTool] = []
}

struct Bookmark: Identifiable {
    let id = UUID()
    var page: String
    var section: String
}

struct SearchResult: Identifiable {
    let id = UUID()
    var page: String
    var lead: String      // bold lead-in (section)
    var snippet: String
}

enum ReaderMock {
    static let docHeaderTitle = "1. Review of Key Financial Metrics/"
    static let docHeaderSub = "Summary of the financial and audit director"

    /// Flattened folder/file tree shown in the file viewer's Structure tab.
    struct FileNode: Identifiable {
        let id = UUID()
        let name: String
        let icon: String            // SF Symbol
        let level: Int
        var chevron: String? = nil  // folders only: "chevron.down" / "chevron.right"
        var selected: Bool = false
    }

    static let fileTree: [FileNode] = [
        .init(name: "Governance_Policies", icon: "folder", level: 0, chevron: "chevron.down"),
        .init(name: "Bylaws_and_Charters", icon: "folder", level: 1, chevron: "chevron.down"),
        .init(name: "Board_Bylaws_2026.pdf", icon: "doc.text", level: 2),
        .init(name: "Audit_Committee_Charter_2025.docx", icon: "doc.text", level: 2, selected: true),
        .init(name: "Governance_Principles_Manual.xlsx", icon: "doc.text", level: 2),
        .init(name: "Code_of_Conduct", icon: "folder", level: 1, chevron: "chevron.down"),
        .init(name: "Code_of_Ethics_2026.pdf", icon: "doc.text", level: 2),
        .init(name: "Conflict_of_Interest_Policy.pdf", icon: "doc.text", level: 2),
        .init(name: "Confidentiality_Agreement_Template.docx", icon: "doc.text", level: 2),
        .init(name: "Risk_and_Compliance", icon: "folder", level: 1, chevron: "chevron.down"),
        .init(name: "Enterprise_Risk_Framework.docx", icon: "doc.text", level: 2),
        .init(name: "Compliance_Reporting_Guidelines.pdf", icon: "doc.text", level: 2),
        .init(name: "Whistleblower_Policy.pdf", icon: "doc.text", level: 2),
        .init(name: "Board_Meeting_Schedules", icon: "folder", level: 0, chevron: "chevron.right"),
        .init(name: "Meeting_Agendas", icon: "folder", level: 0, chevron: "chevron.right"),
        .init(name: "Presentations_and_Reports", icon: "folder", level: 0, chevron: "chevron.right"),
        .init(name: "Governance_Communications", icon: "folder", level: 0, chevron: "chevron.right"),
        .init(name: "Financial_Documents", icon: "folder", level: 0, chevron: "chevron.right"),
    ]

    static let notePages: [NotePage] = [
        .init(page: "Page 2", notes: [
            .init(author: "James W.", initials: "JW", tint: "#FCE4E4", timestamp: "06/03/2026, 9:30 AM",
                  body: "The vendor contract renewal is due next Friday — legal has flagged two clauses that need revision before we can sign off.",
                  visibility: "globe", earlierReplies: 5,
                  replies: [.init(author: "Ashley J.", initials: "AJ", tint: "#EADDFF", timestamp: "06/03/2026, 9:30 AM",
                                  body: "I'll coordinate with procurement to get the updated terms by Wednesday.")]),
            .init(author: "Michael T.", initials: "MT", tint: "#D7F0E3", timestamp: "06/03/2026, 9:30 AM",
                  body: "The quarterly financial report is due soon; all departments must submit their data by end of the week.",
                  visibility: "globe", earlierReplies: 0,
                  replies: [.init(author: "Ashley J.", initials: "AJ", tint: "#EADDFF", timestamp: "06/03/2026, 9:30 AM",
                                  body: "I'll coordinate with procurement to get the updated terms by Wednesday.")]),
            .init(author: "Linda M.", initials: "LM", tint: "#D9E8FF", timestamp: "06/03/2026, 9:30 AM",
                  body: "The product feedback session is set for next Tuesday; please prepare your insights from the last round of testing.",
                  visibility: "person.2"),
        ]),
        .init(page: "Page 3", notes: [
            .init(author: "James W.", initials: "JW", tint: "#FCE4E4", timestamp: "06/03/2026, 9:30 AM",
                  body: "The vendor contract renewal is due next Friday — legal has flagged two clauses that need revision."),
        ]),
    ]

    static let markupPages: [MarkupPage] = [
        .init(page: "Page 1", count: 4),
        .init(page: "Page 2", count: 4, tools: [
            .init(name: "Pen", symbol: "pencil.tip"),
            .init(name: "Pen", symbol: "pencil.tip"),
            .init(name: "Highlighter", symbol: "highlighter"),
            .init(name: "Text highlighter", symbol: "character.cursor.ibeam"),
        ]),
        .init(page: "Page 3", count: 4),
        .init(page: "Page 4", count: 4),
        .init(page: "Page 5", count: 4),
    ]

    static let bookmarks: [Bookmark] = [
        .init(page: "Page 2", section: "1.3 Profit Margins"),
        .init(page: "Page 3", section: "1.3 Profit Margins"),
        .init(page: "Page 25", section: "2.6.3 What does the future holds?"),
        .init(page: "Page 56", section: "3.4.1.2 The unforeseen expenses of the next century"),
        .init(page: "Page 62", section: "6.7 Summary"),
        .init(page: "Page 63", section: "6.7 Summary"),
    ]

    static let searchResults: [SearchResult] = [
        .init(page: "Page 5", lead: "Audit Committee Report", snippet: "Privileged user accounts in the legacy ERP system had not been reviewed for 18 months. The CIO submitted a remediation plan with a target cl…"),
        .init(page: "Page 9", lead: "Risk Register", snippet: "The EU AI Act risk was elevated from Medium to High likelihood and Critical impact following the publication of implementation guidelines in August 2024."),
        .init(page: "Page 1", lead: "Audit Committee Report", snippet: "12 active vendors lack current third-party risk assessments — Procurement initiated remediation, target close November 30, 2024."),
        .init(page: "Page 3", lead: "Executive Summary", snippet: "Three high-priority internal audit findings require board attention ahead of the October 15 Extraordinary Meeting."),
        .init(page: "Page 7", lead: "Audit Committee Report", snippet: "Expense policy exceptions in the APAC region showed a pattern of approvals bypassing standard controls — HR and Finance conducting joint…"),
        .init(page: "Page 2", lead: "Risk Register", snippet: "Data privacy breach rated Medium likelihood and Critical impact — owned by the CISO. Supply chain disruption…"),
    ]

    // Thumbnails: page number + whether it is the current page.
    static let thumbnailPages = Array(1...8)
}
