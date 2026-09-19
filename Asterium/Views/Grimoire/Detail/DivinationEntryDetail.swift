//
//  DivinationEntryDetail.swift
//  Sterium
//

import SwiftUI

struct DivinationEntryDetail: View {
    let entry: DivinationEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Divination", title: entry.title, onEdit: { showingEdit = true }) {
                    GrimoireDetailSection(title: "Date") {
                        detailValue(entry.date.formatted(date: .long, time: .omitted))
                    }

                    translucentPillSection(title: "Method", value: entry.method)

                    GrimoireDetailSection(title: "Inquiry") {
                        detailValue(entry.questionAsked)
                    }

                    if !entry.spreadQuestions.isEmpty {
                        GrimoireDetailSection(title: "Spread") {
                            spreadContent
                        }
                    }

                    if !entry.cardSymbolItems.isEmpty {
                        GrimoireDetailSection(title: "Cards / Symbols Drawn") {
                            ForEach(entry.cardSymbolItems) { item in
                                GrimoireDetailRow(label: item.name, value: item.meaning)
                            }
                        }
                    }

                    GrimoireDetailSection(title: "Reading") {
                        GrimoireDetailRow(label: "Interpretation", value: entry.interpretation)
                        GrimoireDetailRow(label: "Advice", value: entry.advice)
                    }

                    if !entry.followUpItems.isEmpty {
                        GrimoireDetailSection(title: "Follow Up Actions") {
                            numberedFollowUpActions
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        AsteriumSectionHeader(title: "Accuracy Review")
                        DivinationAccuracyDisplay(rating: Int(entry.accuracyReview) ?? 0)
                    }

                    detailFooter
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
                DivinationEntryForm(existing: entry)
        }
    }

    private var spreadContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text((entry.spreadLabel.isEmpty ? "Question / Focus" : entry.spreadLabel).uppercased())
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(LColors.textSecondary)

            ForEach(entry.spreadQuestions.indices, id: \.self) { index in
                Text(entry.spreadQuestions[index])
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var numberedFollowUpActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(entry.followUpItems.indices, id: \.self) { index in
                HStack(alignment: .center, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.bg)
                        .frame(width: 28, height: 28)
                        .background(LGradients.tag, in: Circle())

                    Text(entry.followUpItems[index])
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }
            }
        }
    }

    private var detailFooter: some View {
        Group {
            VStack(alignment: .leading, spacing: 8) {
                AsteriumSectionHeader(title: "Importance")
                GrimoireImportanceDots(value: entry.importance, showsLabel: false)
            }

            VStack(alignment: .leading, spacing: 8) {
                AsteriumSectionHeader(title: "Tags")
                GrimoireDetailChips(label: "Tags", items: entry.tags, showsLabel: false)
            }

            GrimoireRelatedEntriesList(entries: entry.relatedEntries)

            GrimoireDetailSection(title: "Additional Notes") {
                Text(trimmedAdditionalNotes.isEmpty ? "No additional notes" : trimmedAdditionalNotes)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(trimmedAdditionalNotes.isEmpty ? LColors.textSecondary : LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var trimmedAdditionalNotes: String {
        entry.additionalNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func translucentPillSection(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AsteriumSectionHeader(title: title)

            Text(value.isEmpty ? "No method" : value)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(value.isEmpty ? LColors.textSecondary : LColors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.12), in: Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                }
        }
    }

    private func detailValue(_ value: String) -> some View {
        Text(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No details" : value)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? LColors.textSecondary : LColors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private struct DivinationAccuracyDisplay: View {
    let rating: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { level in
                Image("starfill")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(level <= rating ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassSurface))
                }
        }
    }
}
