
//
//  PathworkEntryDetail.swift
//  Asterium
//

import SwiftUI

struct PathworkEntryDetail: View {
    let entry: PathworkEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Pathwork", title: entry.chapterTitle, onEdit: { showingEdit = true }) {
                    GrimoireDetailSection(title: "Overview") {
                        GrimoireDetailRow(label: "Started", value: entry.started.formatted(date: .long, time: .omitted))

                        VStack(alignment: .leading, spacing: 6) {
                            Text("STATUS")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .tracking(1.5)
                                .foregroundStyle(LColors.textSecondary)
                            GrimoireStatusBadge(text: entry.currentStatus.displayName)
                        }

                        GrimoireDetailRow(label: "Focus Area", value: entry.focusArea)
                    }

                    GrimoireDetailSection(title: "Path") {
                        GrimoireDetailRow(label: "Why This Path", value: entry.whyThisPath)
                        GrimoireDetailRow(label: "Current Practices", value: entry.currentPractices)
                        GrimoireDetailRow(label: "Goals", value: entry.goals)
                    }

                    GrimoireDetailSection(title: "Progress") {
                        GrimoireDetailRow(label: "Current Challenges", value: entry.currentChallenges)
                        GrimoireDetailRow(label: "Recent Breakthroughs", value: entry.recentBreakthroughs)
                        GrimoireDetailRow(label: "Resources Studying", value: entry.resourcesStudying)
                    }

                    GrimoireDetailSection(title: "Reflection") {
                        GrimoireDetailRow(label: "Reflection", value: entry.reflection)
                        GrimoireDetailRow(label: "Next Steps", value: entry.nextSteps)
                    }

                    GrimoireDetailFooter(
                        importance: entry.importance,
                        tags: entry.tags,
                        relatedEntries: entry.relatedEntries,
                        additionalNotes: entry.additionalNotes
                    )
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
                PathworkEntryForm(existing: entry)
        }
    }
}