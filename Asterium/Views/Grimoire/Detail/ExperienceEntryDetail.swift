//
//  ExperienceEntryDetail.swift
//  Sterium
//

import SwiftUI

struct ExperienceEntryDetail: View {
    let entry: ExperienceEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Experience", title: entry.title, onEdit: { showingEdit = true }) {
                    GrimoireDetailSection {
                        GrimoireDetailRow(label: "Date", value: entry.date.formatted(date: .long, time: .omitted))
                    }

                    if !entry.content.isEmpty {
                        GrimoireDetailSection(title: "Content") {
                            Text(entry.content)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                        }
                    }

                    detailFooter
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
                ExperienceEntryForm(existing: entry)
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

    private var trimmedAdditionalNotes: String {
        entry.additionalNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
