//
//  SynchronicityEntryDetail.swift
//  Sterium
//

import SwiftUI

struct SynchronicityEntryDetail: View {
    let entry: SynchronicityEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Synchronicity", title: entry.title, onEdit: { showingEdit = true }) {
            VStack(alignment: .leading, spacing: 12) {
                AsteriumSectionHeader(title: "Emotional State")
                GrimoireDetailChips(label: "Emotional State", items: emotionalStateItems, showsLabel: false)
            }

            VStack(alignment: .leading, spacing: 12) {
                AsteriumSectionHeader(title: "Category")
                GrimoireDetailChips(label: "Category", items: categoryItems, showsLabel: false)
            }

            detailTextSection(
                title: "Date & Time",
                value: entry.dateTime.formatted(date: .long, time: .shortened),
                emptyText: "No date"
            )

            detailTextSection(title: "Location", value: entry.location, emptyText: "No location")

            detailTextSection(title: "What Happened", value: entry.whatHappened, emptyText: "No details")

            detailTextSection(title: "Possible Meaning", value: entry.possibleMeaning, emptyText: "No possible meaning")

            detailTextSection(title: "Related Event", value: entry.relatedEvent, emptyText: "No related event")

            confidenceSection

            detailTextSection(title: "Notes", value: entry.notes, emptyText: "No notes")

            VStack(alignment: .leading, spacing: 12) {
                AsteriumSectionHeader(title: "Importance")
                GrimoireImportanceDots(value: entry.importance, showsLabel: false)
            }

            VStack(alignment: .leading, spacing: 12) {
                AsteriumSectionHeader(title: "Tags")
                GrimoireDetailChips(label: "Tags", items: entry.tags, showsLabel: false)
            }

            if !entry.attachments.isEmpty {
                GrimoireDetailSection(title: "Attachments") {
                    GrimoireAttachmentGallery(attachments: entry.attachments)
                }
            }

            GrimoireRelatedEntriesList(entries: entry.relatedEntries)

            GrimoireDetailSection(title: "Additional Notes") {
                Text(trimmedAdditionalNotes.isEmpty ? "No additional notes" : trimmedAdditionalNotes)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(trimmedAdditionalNotes.isEmpty ? LColors.textSecondary : LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
            SynchronicityEntryForm(existing: entry)
        }
    }

    private var categoryItems: [String] {
        splitPillValues(entry.category)
    }

    private var emotionalStateItems: [String] {
        splitPillValues(entry.emotionalState)
    }

    private var trimmedAdditionalNotes: String {
        entry.additionalNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var confidenceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsteriumSectionHeader(title: "Confidence")

            HStack(spacing: 6) {
                ForEach(1...5, id: \.self) { i in
                    Circle()
                        .fill(i <= entry.confidence ? AnyShapeStyle(LGradients.tag) : AnyShapeStyle(LColors.glassSurface))
                        .frame(width: 12, height: 12)
                        .overlay {
                            Circle()
                                .strokeBorder(i <= entry.confidence ? Color.clear : LColors.glassBorder, lineWidth: 1)
                        }
                }

                Text("\(entry.confidence)/5")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .padding(.leading, 4)
            }
        }
    }

    private func detailTextSection(title: String, value: String, emptyText: String) -> some View {
        GrimoireDetailSection(title: title) {
            Text(displayText(value, emptyText: emptyText))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? LColors.textSecondary : LColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func displayText(_ value: String, emptyText: String) -> String {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? emptyText : trimmedValue
    }

    private func splitPillValues(_ value: String) -> [String] {
        value
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
