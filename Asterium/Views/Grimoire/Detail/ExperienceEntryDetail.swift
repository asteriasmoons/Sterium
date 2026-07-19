
//
//  ExperienceEntryDetail.swift
//  Asterium
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

                    GrimoireDetailFooter(
                        importance: entry.importance,
                        tags: entry.tags,
                        relatedEntries: entry.relatedEntries,
                        additionalNotes: entry.additionalNotes
                    )
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
                ExperienceEntryForm(existing: entry)
        }
    }
}