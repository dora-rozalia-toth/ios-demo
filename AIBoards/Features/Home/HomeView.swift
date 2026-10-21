import SwiftUI

struct HomeView: View {
    @EnvironmentObject var model: AppModel
    @State private var prompt = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Space.xxl) {
                PromptHero(text: $prompt)
                actionItems
                meetings
                competitors
            }
            .padding(.bottom, DS.Space.xl)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: Action items

    private var actionItems: some View {
        VStack(alignment: .leading, spacing: DS.Space.smd) {
            SectionHeader(title: "Your action items from the last 60 days") {
                LinkButton(title: "Go to Decision Hub") { model.select(.decisionHub) }
            }
            VStack(spacing: DS.Space.sm) {
                ForEach(Mock.actionItems) { item in
                    ActionItemRow(item: item)
                }
            }
        }
    }

    // MARK: Books with upcoming meetings

    private var meetings: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            SectionHeader(title: "Books with upcoming meetings") {
                LinkButton(title: "Go to Books") { model.select(.books) }
            }
            MeetingsTable(
                books: Mock.upcomingBooks,
                onOpen: { model.openBook = $0 },
                onMenu: { model.present(.meetingDetails($0)) }
            )
        }
    }

    // MARK: Competitor updates

    private var competitors: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            HStack(spacing: DS.Space.smd) {
                Text("Competitor updates").dsText(DS.Text.h4)
                AIChip()
                Spacer(minLength: DS.Space.md)
                LinkButton(title: "Read more updates")
            }
            HStack(alignment: .top, spacing: DS.Space.sm) {
                ForEach(Mock.competitorUpdates) { update in
                    CompetitorCard(update: update)
                }
            }
        }
    }
}

// MARK: - Prompt hero

private struct PromptHero: View {
    @Binding var text: String

    var body: some View {
        VStack(spacing: DS.Space.lg) {
            VStack(spacing: DS.Space.sm) {
                Text("What would you like to know?")
                    .font(.custom(DS.Typeface.semibold, size: 34))
                    .foregroundStyle(DS.ColorToken.textPrimary)
                Text("Select a prompt to get started, or ask your own question.")
                    .dsText(DS.Text.bodyMd, color: DS.ColorToken.textMuted)
            }

            VStack(spacing: DS.Space.smd) {
                promptField
                HStack(spacing: DS.Space.sm) {
                    PromptChip(label: "Find topics", symbol: "magnifyingglass")
                    PromptChip(label: "Prepare for meetings", symbol: "calendar")
                    PromptChip(label: "Monitor trends", symbol: "chart.line.uptrend.xyaxis")
                    PromptChip(label: "Show more", symbol: "plus")
                }
            }
            .frame(maxWidth: 708)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 120)
        .padding(.top, DS.Space.xxl)
        .padding(.bottom, DS.Space.lg)
        .background {
            ZStack {
                DS.ColorToken.surfaceHero
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: "#B8C4FF").opacity(0.40), location: 0),
                        .init(color: Color(hex: "#FBFBFE").opacity(0), location: 0.82),
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg16))
        }
    }

    private var promptField: some View {
        ZStack {
            // Atlas "AI glow" — a heavily blurred, low-opacity blue wash behind the
            // prompt field (Figma: 660×140 ellipse, layer blur ~154, ~0.24 opacity).
            Ellipse()
                .fill(LinearGradient(
                    stops: [
                        .init(color: .white, location: 0),
                        .init(color: Color(hex: "#4069FE"), location: 0.226),
                        .init(color: Color(hex: "#0040D5"), location: 0.486),
                        .init(color: Color(hex: "#4069FE"), location: 0.726),
                        .init(color: .white, location: 1),
                    ],
                    startPoint: .leading, endPoint: .trailing))
                .frame(width: 660, height: 140)
                .opacity(0.24)
                .blur(radius: 55)
                .offset(y: -6)
                .allowsHitTesting(false)
            promptFieldBox
        }
    }

    private var promptFieldBox: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text("Ask anything about current and archived books")
                    .dsText(DS.Text.bodyLg, color: DS.ColorToken.textMuted)
                    .padding(.horizontal, DS.Space.md)
                    .padding(.top, DS.Space.md)
            }
            TextField("", text: $text, axis: .vertical)
                .font(DS.Text.bodyLg.font)
                .foregroundStyle(DS.ColorToken.textPrimary)
                .padding(.horizontal, DS.Space.md)
                .padding(.top, DS.Space.md)
                .padding(.trailing, 44)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {} label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(DS.ColorToken.textDisabled)
                            .frame(width: 32, height: 32)
                            .background(DS.ColorToken.surfaceMuted, in: RoundedRectangle(cornerRadius: DS.Radius.md))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(DS.Space.sm)
        }
        .frame(height: 96)
        .background(DS.ColorToken.background, in: RoundedRectangle(cornerRadius: DS.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .stroke(DS.ColorToken.border, lineWidth: 1)
        )
    }
}

private struct PromptChip: View {
    let label: String
    let symbol: String
    var body: some View {
        HStack(spacing: DS.Space.xs) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(DS.ColorToken.textPrimary)
            Text(label).dsText(DS.Text.labelLg)
        }
        .padding(.horizontal, DS.Space.smd)
        .frame(height: 36)
        .background(DS.ColorToken.background, in: Capsule())
        .overlay(Capsule().stroke(DS.ColorToken.border, lineWidth: 1))
    }
}

private struct AIChip: View {
    var body: some View {
        HStack(spacing: DS.Space.xs) {
            Image(systemName: "sparkles")
                .font(.system(size: 12))
                .foregroundStyle(DS.ColorToken.textMuted)
            Text("Curated and summarized by AI").dsText(DS.Text.labelSm, color: DS.ColorToken.textMuted)
        }
        .padding(.horizontal, DS.Space.sm)
        .frame(height: 24)
        .overlay(Capsule().stroke(DS.ColorToken.borderStrong, lineWidth: 1))
    }
}

// MARK: - Action item row

private struct ActionItemRow: View {
    let item: ActionItem
    var body: some View {
        HStack(spacing: DS.Space.smd) {
            IconTile(asset: "ic_nav_decision", glyph: 18)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .dsText(DS.Text.bodySmEmph)
                    .lineLimit(1)
                Text("Published on: \(item.publishedOn)")
                    .dsText(DS.Text.bodySm, color: DS.ColorToken.textMuted)
            }
            Spacer(minLength: DS.Space.md)
            StatusChip.info(item.status.rawValue)
        }
        .padding(.horizontal, DS.Space.smd)
        .frame(height: 64)
        .background(DS.ColorToken.background, in: RoundedRectangle(cornerRadius: DS.Radius.lg))
    }
}

// MARK: - Competitor card

private struct CompetitorCard: View {
    let update: CompetitorUpdate
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.smd) {
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text(update.title)
                    .dsText(DS.Text.bodySmEmph)
                    .lineLimit(2)
                HStack(spacing: DS.Space.xs) {
                    Text(update.source).dsText(DS.Text.bodySm, color: DS.ColorToken.textMuted)
                    Text("•").dsText(DS.Text.bodySm, color: DS.ColorToken.textMuted)
                    Text(update.date).dsText(DS.Text.bodySm, color: DS.ColorToken.textMuted)
                }
            }
            Text(update.body)
                .dsText(DS.Text.bodySm, color: DS.ColorToken.textMuted)
                .lineLimit(7)
            Spacer(minLength: 0)
        }
        .padding(DS.Space.md)
        .frame(height: 200, alignment: .top)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DS.ColorToken.background, in: RoundedRectangle(cornerRadius: DS.Radius.lg16))
    }
}
