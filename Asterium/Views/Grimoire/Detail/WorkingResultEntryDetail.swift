
//
//  WorkingResultEntryDetail.swift
//  Asterium
//

import SwiftUI

struct WorkingResultEntryDetail: View {
    let entry: WorkingResultEntry
    @State private var showingEdit = false

    private var outcomeColor: Color {
        switch entry.overallOutcome {
        case .successful: return LColors.success
        case .partial:    return LColors.warning
        case .none:       return LColors.danger
        case .unsure:     return LColors.textSecondary
        }
    }

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Working Result", title: entry.title, onEdit: { showingEdit = true }) {
                    GrimoireDetailSection(title: "Overview") {
                        if let linked = entry.linkedWorking {
                            GrimoireDetailRow(label: "Linked Working", value: linked.title)
                        }
                        GrimoireDetailRow(label: "Date", value: entry.date.formatted(date: .long, time: .omitted))
                        GrimoireDetailRow(label: "Time Since Working", value: entry.timeSinceWorking)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("OUTCOME")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .tracking(1.5)
                                .foregroundStyle(LColors.textSecondary)
                            Text(entry.overallOutcome.displayName)
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule().fill(outcomeColor.opacity(0.8))
                                )
                        }
                    }

                    GrimoireDetailSection(title: "Results") {
                        GrimoireDetailRow(label: "Observable Results", value: entry.observableResults)
                        GrimoireDetailRow(label: "Unexpected Outcomes", value: entry.unexpectedOutcomes)
                        GrimoireDetailRow(label: "Signs & Omens", value: entry.signsAndOmens)
                    }

                    GrimoireDetailSection(title: "Reflection") {
                        GrimoireDetailRow(label: "Lessons Learned", value: entry.lessonsLearned)
                        GrimoireDetailRow(label: "Would Repeat", value: entry.wouldRepeat.displayName)
                        GrimoireDetailRow(label: "Changes for Next Time", value: entry.changesNextTime)
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
                WorkingResultEntryForm(existing: entry)
        }
    }
}