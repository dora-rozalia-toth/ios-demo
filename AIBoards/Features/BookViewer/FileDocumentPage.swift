import SwiftUI

/// Scrolling document used by the resource-center File viewer. Unlike the book
/// reader it has no annotation toolbar or bookmark — instead a page-number pill
/// appears while scrolling and can be tapped to jump to a page. Sample content
/// is an original (placeholder) services agreement so it reads as a file, not a book.
struct FileDocumentPage: View {
    private let navy = Color(hex: "#1F3A5F")
    private let totalPages = 237

    private static let args = ProcessInfo.processInfo.arguments
    @State private var currentPage = args.contains("-pageNum") || args.contains("-pageEntry") ? 12 : 1
    @State private var showPill = args.contains("-pageNum") || args.contains("-pageEntry")
    @State private var showEntry = args.contains("-pageEntry")
    @State private var pillHideWork: DispatchWorkItem?
    // Demo captures (-pageNum / -pageEntry) pin the pill visible for screenshots.
    private static let pillPinned = args.contains("-pageNum") || args.contains("-pageEntry")

    private struct ScrollInfo: Equatable { var offset: CGFloat; var maxOffset: CGFloat }

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

    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Space.md) {
                    titleBlock
                    clause("1. Definitions", "In this Master Services Agreement (the \u{201C}Agreement\u{201D}), the following terms have the meanings set out below unless the context requires otherwise.")
                    sub("1.1", "\u{201C}Services\u{201D} means the advisory, implementation and support services described in each Statement of Work executed by the parties under this Agreement.")
                    sub("1.2", "\u{201C}Deliverables\u{201D} means any report, document, software, or other work product that the Provider is required to deliver to the Client under a Statement of Work.")
                    sub("1.3", "\u{201C}Confidential Information\u{201D} means all non-public information disclosed by one party to the other, whether orally, in writing, or by inspection of tangible objects.")
                    clause("2. Scope of Services", "The Provider shall perform the Services with reasonable skill and care and in accordance with the standards of a competent professional provider in the relevant industry.")
                    sub("2.1", "Each engagement shall be documented in a Statement of Work that references this Agreement and sets out the scope, timeline, acceptance criteria, and fees applicable to that engagement.")
                    sub("2.2", "Where there is a conflict between a Statement of Work and this Agreement, the terms of this Agreement shall prevail unless the Statement of Work expressly states otherwise and is signed by authorized representatives of both parties.")
                    clause("3. Term and Termination", "This Agreement commences on the Effective Date and continues for an initial term of twenty-four (24) months, after which it renews automatically for successive twelve (12) month periods.")
                    sub("3.1", "Either party may terminate this Agreement for convenience on not less than sixty (60) days\u{2019} prior written notice to the other party.")
                    sub("3.2", "Either party may terminate this Agreement immediately on written notice if the other party commits a material breach that is not remedied within thirty (30) days of notice.")
                    clause("4. Fees and Payment", "The Client shall pay the fees set out in each Statement of Work. Unless stated otherwise, invoices are payable within thirty (30) days of the invoice date.")
                    sub("4.1", "Fees are exclusive of value-added tax and any other applicable taxes, which shall be added to invoices at the prevailing rate where required by law.")
                    sub("4.2", "Late payments shall accrue interest at a rate of 1.5% per month, or the maximum rate permitted by applicable law, whichever is lower.")
                    clause("5. Confidentiality", "Each party shall keep the other party\u{2019}s Confidential Information strictly confidential and shall not disclose it to any third party except as expressly permitted under this Agreement.")
                    sub("5.1", "The obligations in this clause survive termination of this Agreement for a period of five (5) years, except for trade secrets which remain protected for as long as they remain secret.")
                    clause("6. Intellectual Property", "Subject to payment of all applicable fees, the Provider assigns to the Client all right, title and interest in the Deliverables created specifically for the Client under a Statement of Work.")
                    sub("6.1", "The Provider retains ownership of all pre-existing materials, methodologies, and know-how, and grants the Client a non-exclusive licence to use them to the extent embedded in the Deliverables.")
                    clause("7. Limitation of Liability", "Neither party shall be liable for any indirect, incidental, special or consequential loss, or for any loss of profits, revenue, or anticipated savings, arising out of or in connection with this Agreement.")
                    sub("7.1", "The total aggregate liability of each party under this Agreement shall not exceed the total fees paid or payable under the relevant Statement of Work in the twelve (12) months preceding the event giving rise to the claim.")
                    clause("8. Governing Law", "This Agreement is governed by and construed in accordance with the laws of the State of Delaware, without regard to its conflict-of-laws principles.")
                    Color.clear.frame(height: 40)
                }
                .padding(48)
            }
            .onScrollGeometryChange(for: ScrollInfo.self) { geo in
                ScrollInfo(offset: geo.contentOffset.y,
                           maxOffset: max(1, geo.contentSize.height - geo.containerSize.height))
            } action: { _, info in
                let progress = min(1, max(0, info.offset / info.maxOffset))
                currentPage = min(totalPages, max(1, Int(progress * Double(totalPages - 1)) + 1))
                revealPillWhileScrolling(atTop: info.offset <= 24)
            }

            if showPill || showEntry {
                PageNumberControl(currentPage: $currentPage, showEntry: $showEntry, totalPages: totalPages)
                    .padding(.top, DS.Space.md)
                    .padding(.leading, DS.Space.md)
                    .transition(.opacity)
            }
        }
        .background(DS.ColorToken.background, in: RoundedRectangle(cornerRadius: DS.Radius.lg16))
    }

    // MARK: Content

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text("MASTER SERVICES AGREEMENT")
                .font(.custom(DS.Typeface.bold, size: 26)).foregroundStyle(navy)
            Text("Between GlobalTech Industries, Inc. (\u{201C}Client\u{201D}) and Meridian Advisory Partners LLP (\u{201C}Provider\u{201D})")
                .dsText(DS.Text.bodyMd, color: DS.ColorToken.textMuted)
            Text("Effective Date: 3 June 2026")
                .dsText(DS.Text.bodyMd, color: DS.ColorToken.textMuted)
            Rectangle().fill(DS.ColorToken.border).frame(height: 1).padding(.top, DS.Space.sm)
        }
        .padding(.bottom, DS.Space.sm)
    }

    private func clause(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text(title).font(.custom(DS.Typeface.semibold, size: 18)).foregroundStyle(navy)
                .padding(.top, DS.Space.sm)
            Text(text).dsText(DS.Text.bodyLg, color: DS.ColorToken.textPrimary)
        }
    }

    private func sub(_ number: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: DS.Space.smd) {
            Text(number).dsText(DS.Text.bodyLgEmph, color: DS.ColorToken.textMuted)
                .frame(width: 36, alignment: .leading)
            Text(text).dsText(DS.Text.bodyLg, color: DS.ColorToken.textPrimary)
        }
    }
}
