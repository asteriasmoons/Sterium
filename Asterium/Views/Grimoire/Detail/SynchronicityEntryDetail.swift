
//
//  SynchronicityEntryDetail.swift
//  Asterium
//

import SwiftUI

struct SynchronicityEntryDetail: View {
    let entry: SynchronicityEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Synchronicity", title: entry.title, onEdit: { showingEdit = true }) {
                    GrimoireDetailSection(title: "Details") {
                        GrimoireDetailRow(label: "Date & Time", value: entry.dateTime.formatted(date: .long, time: .shortened))
                        GrimoireDetailRow(label: "Category", value: entry.category)
                        GrimoireDetailRow(label: "Location", value: entry.location)
                        GrimoireDetailRow(label: "Emotional State", value: entry.emotionalState)
                    }

                    if !entry.whatHappened.isEmpty {
                        GrimoireDetailSection(title: "What Happened") {
                            Text(entry.whatHappened)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                        }
                    }

                    GrimoireDetailSection(title: "Meaning & Context") {
                        GrimoireDetailRow(label: "Possible Meaning", value: entry.possibleMeaning)
                        GrimoireDetailRow(label: "Related Event", value: entry.relatedEvent)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("CONFIDENCE")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .tracking(1.5)
                                .foregroundStyle(LColors.textSecondary)
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

                        GrimoireDetailRow(label: "Notes", value: entry.notes)
                    }

                    GrimoireDetailFooter(
                        importance: entry.importance,
                        tags: entry.tags,
                        relatedEntries: entry.relatedEntries,
                        additionalNotes: entry.additionalNotes
                    )
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
                SynchronicityEntryForm(existing: entry)
        }
    }
}