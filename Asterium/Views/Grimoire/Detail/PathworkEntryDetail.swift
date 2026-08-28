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
            VStack(alignment: .leading, spacing: 10) {
                AsteriumSectionHeader(title: "Status")
                GrimoireStatusBadge(text: entry.currentStatus.displayName)
            }

            GrimoireDetailSection(title: "Started") {
                GrimoireDetailRow(label: "Started", value: entry.started.formatted(date: .long, time: .omitted))
            }

            GrimoireDetailSection(title: "Focus Area") {
                GrimoireDetailRow(label: "Focus Area", value: entry.focusArea)
            }

            VStack(alignment: .leading, spacing: 12) {
                AsteriumSectionHeader(title: "Path")
                GlassCard {
                    VStack(alignment: .leading, spacing: 18) {
                        GrimoireDetailRow(label: "Why This Path", value: entry.whyThisPath)
                        GrimoireDetailRow(label: "Goals", value: entry.goals)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("CURRENT PRACTICES")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(LColors.textSecondary)
                    FlowLayout(spacing: 8) {
                        if !entry.currentPractices.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(entry.currentPractices)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(Capsule().fill(LGradients.tag.opacity(0.55)))
                                .overlay { Capsule().strokeBorder(LColors.glassBorder, lineWidth: 1) }
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                AsteriumSectionHeader(title: "Progress")
                GlassCard {
                    VStack(alignment: .leading, spacing: 18) {
                        GrimoireDetailRow(label: "Current Challenges", value: entry.currentChallenges)
                        GrimoireDetailRow(label: "Recent Breakthroughs", value: entry.recentBreakthroughs)
                    }
                }

                GlassCard {
                    GrimoireDetailRow(label: "Resources Studying", value: entry.resourcesStudying)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                AsteriumSectionHeader(title: "Reflection")
                GlassCard {
                    GrimoireDetailRow(label: "Reflection", value: entry.reflection)
                }

                if !entry.nextStepsList.isEmpty {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(entry.nextStepsList.prefix(9).enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 10) {
                                    Image("\(index + 1)wavy")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)

                                    Text(step)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(LColors.textPrimary)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                AsteriumSectionHeader(title: "Importance")
                GrimoireImportanceDots(value: entry.importance, showsLabel: false)
            }

            VStack(alignment: .leading, spacing: 10) {
                AsteriumSectionHeader(title: "Tags")
                GrimoireDetailChips(label: "Tags", items: entry.tags, showsLabel: false)
            }

            GrimoireDetailSection(title: "Related Entries") {
                GrimoireRelatedEntriesList(entries: entry.relatedEntries, showsLabel: false)
            }

            GrimoireDetailSection(title: "Additional Notes") {
                let trimmed = entry.additionalNotes.trimmingCharacters(in: .whitespacesAndNewlines)
                Text(trimmed.isEmpty ? "No additional notes" : trimmed)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(trimmed.isEmpty ? LColors.textSecondary : LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
            PathworkEntryForm(existing: entry)
        }
    }
}
