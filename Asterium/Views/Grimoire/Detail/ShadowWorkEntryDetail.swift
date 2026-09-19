//
//  ShadowWorkEntryDetail.swift
//  Sterium
//

import SwiftUI

struct ShadowWorkEntryDetail: View {
    let entry: ShadowWorkEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Shadow Work", title: entry.title, onEdit: { showingEdit = true }) {
            singleCardSection(title: "Date", value: entry.date.formatted(date: .long, time: .omitted))

            singleCardSection(title: "Prompt", value: entry.prompt)

            singleCardSection(title: "Trigger", value: entry.trigger)

            gradientPillSection(title: "Emotions", items: entry.emotions)

            singleCardSection(title: "Limiting Belief", value: entry.limitingBelief)

            GrimoireDetailSection(title: "Origins & Influences") {
                originsInfluencesTiles
            }

            singleCardSection(title: "New Perspective", value: entry.newPerspective)

            GrimoireDetailSection(title: "Actions to Practice") {
                numberedActionsToPractice
            }

            singleCardSection(title: "Affirmation", value: entry.affirmation)

            if !entry.reflection.isEmpty {
                singleCardSection(title: "Reflection", value: entry.reflection)
            }

            detailFooter
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
            ShadowWorkEntryForm(existing: entry)
        }
    }

    private var originsInfluencesTiles: some View {
        VStack(alignment: .leading, spacing: 10) {
            if entry.originsInfluences.isEmpty {
                translucentTile("No origins or influences", isEmpty: true)
            } else {
                ForEach(entry.originsInfluences, id: \.self) { item in
                    translucentTile(item)
                }
            }
        }
    }

    private var numberedActionsToPractice: some View {
        VStack(alignment: .leading, spacing: 12) {
            if entry.actionsToPractice.isEmpty {
                detailValue("No actions to practice", isEmpty: true)
            } else {
                ForEach(entry.actionsToPractice.indices, id: \.self) { index in
                    HStack(alignment: .center, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.bg)
                            .frame(width: 28, height: 28)
                            .background(LGradients.tag, in: Circle())

                        Text(entry.actionsToPractice[index])
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 0)
                    }
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

    private func singleCardSection(title: String, value: String) -> some View {
        GrimoireDetailSection(title: title) {
            detailValue(value, isEmpty: value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func gradientPillSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AsteriumSectionHeader(title: title)
            GrimoireDetailChips(label: title, items: items, showsLabel: false)
        }
    }

    private func translucentTile(_ value: String, isEmpty: Bool = false) -> some View {
        Text(value)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(isEmpty ? LColors.textSecondary : LColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
            }
    }

    private func detailValue(_ value: String, isEmpty: Bool = false) -> some View {
        Text(isEmpty ? "No details" : value)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(isEmpty ? LColors.textSecondary : LColors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }
}
