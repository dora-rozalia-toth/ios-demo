import SwiftUI

struct DecisionHubView: View {
    @EnvironmentObject var model: AppModel
    @State private var query = ""

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.lg) {
            PageTitle(title: "Approvals")

            HStack(spacing: DS.Space.md) {
                SearchField(placeholder: "Search by title", text: $query)
                    .frame(width: 320)
                SortControl(label: "Publish date (newest-oldest)")
                FilterButton(count: 3) { model.present(.decisionFilter) }
                Spacer()
            }

            ScrollView {
                VStack(spacing: DS.Space.sm) {
                    ForEach(Mock.approvals) { approval in
                        ApprovalCard(approval: approval)
                    }
                }
                .padding(.bottom, DS.Space.xl)
            }
            .scrollIndicators(.hidden)
        }
    }
}

private struct ApprovalCard: View {
    let approval: Approval

    var body: some View {
        VStack(spacing: 0) {
            row
            if approval.needsResponse {
                respondBanner
                    .padding(.horizontal, DS.Space.smd)
                    .padding(.bottom, DS.Space.smd)
            }
        }
        .background(DS.ColorToken.background, in: RoundedRectangle(cornerRadius: DS.Radius.lg))
    }

    private var row: some View {
        HStack(spacing: DS.Space.md) {
            IconTile(symbol: approval.signatureKind.contains("DocuSign") ? "signature" : "",
                     asset: approval.signatureKind.contains("DocuSign") ? nil : "ic_nav_decision",
                     tint: DS.ColorToken.link, glyph: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(approval.title).dsText(DS.Text.bodySmEmph).lineLimit(1)
                Text(approval.signatureKind).dsText(DS.Text.labelXs, color: DS.ColorToken.textMuted)
            }
            .frame(maxWidth: 380, alignment: .leading)

            resultChip

            Spacer(minLength: DS.Space.md)

            statusChip.frame(width: 150, alignment: .leading)

            Text(approval.date)
                .dsText(DS.Text.bodySm, color: DS.ColorToken.textMuted)
                .padding(.horizontal, DS.Space.sm)
                .frame(height: 28)
                .background(DS.ColorToken.neutralBg, in: Capsule())
                .frame(width: 118, alignment: .leading)

            HStack(spacing: DS.Space.sm) {
                ProgressRing(progress: approval.progress)
                Text("\(approval.progress)%").dsText(DS.Text.bodySm, color: DS.ColorToken.textPrimary)
            }
            .frame(width: 92, alignment: .leading)
        }
        .padding(.horizontal, DS.Space.smd)
        .frame(height: 64)
    }

    @ViewBuilder private var resultChip: some View {
        switch approval.result {
        case .approved: StatusChip.success("Approved by you")
        case .rejected: StatusChip.error("Rejected by you")
        case .abstained: StatusChip.warning("Abstained by you")
        case .viewOnly: StatusChip.neutral("View only")
        case .none: EmptyView()
        }
    }

    private var statusChip: some View {
        switch approval.status {
        case .concluded: return StatusChip.success("Concluded")
        case .inProgress: return StatusChip.info("In progress")
        case .awaiting: return StatusChip.info("Awaiting response")
        }
    }

    private var respondBanner: some View {
        HStack(spacing: DS.Space.smd) {
            Image(systemName: "info.circle")
                .font(.system(size: 18))
                .foregroundStyle(DS.ColorToken.infoFg)
            Text("This approval is waiting for your response.")
                .dsText(DS.Text.bodyMd, color: DS.ColorToken.infoFg)
            Spacer()
            PrimaryButton(title: "Respond")
        }
        .padding(.horizontal, DS.Space.md)
        .frame(height: 56)
        .background(DS.ColorToken.surfaceMuted, in: RoundedRectangle(cornerRadius: DS.Radius.lg))
    }
}

/// Circular approval-progress indicator (0 / 50 / 100%).
struct ProgressRing: View {
    let progress: Int
    var size: CGFloat = 28
    var body: some View {
        ZStack {
            Circle().stroke(DS.ColorToken.border, lineWidth: 3)
            Circle()
                .trim(from: 0, to: CGFloat(progress) / 100)
                .stroke(DS.ColorToken.primary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }
}
