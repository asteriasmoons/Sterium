//
//  JournalEntryDetail.swift
//  Sterium
//

import SwiftUI

struct JournalEntryDetail: View {
    let entry: JournalEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Journal", title: entry.title, onEdit: { showingEdit = true }) {
                    GrimoireDetailSection(title: "Date") {
                        detailValue(entry.date.formatted(date: .long, time: .omitted))
                    }

                    if !entry.content.isEmpty {
                        GrimoireDetailSection(title: "Content") {
                            Text(entry.content)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                        }
                    }

                    journalFooter
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
                JournalEntryForm(existing: entry)
        }
    }

    private var trimmedAdditionalNotes: String {
        entry.additionalNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var journalFooter: some View {
        Group {
            VStack(alignment: .leading, spacing: 10) {
                AsteriumSectionHeader(title: "Importance")
                GrimoireImportanceDots(value: entry.importance, showsLabel: false)
            }

            VStack(alignment: .leading, spacing: 10) {
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
    }

    private func detailValue(_ value: String) -> some View {
        Text(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No details" : value)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? LColors.textSecondary : LColors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }
}
