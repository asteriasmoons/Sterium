
//
//  JournalEntryDetail.swift
//  Asterium
//

import SwiftUI

struct JournalEntryDetail: View {
    let entry: JournalEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Journal", title: entry.title, onEdit: { showingEdit = true }) {
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
                JournalEntryForm(existing: entry)
        }
    }
}