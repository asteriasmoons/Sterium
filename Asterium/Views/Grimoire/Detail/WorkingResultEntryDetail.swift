
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
                    GrimoireDetailSection(title: "Date") {
                        GrimoireDetailRow(label: "Date", value: entry.date.formatted(date: .long, time: .omitted))
                    }

                    if let linked = entry.linkedWorking {
                        VStack(alignment: .leading, spacing: 12) {
                            AsteriumSectionHeader(title: "Linked Working")
                            NavigationLink {
                                WorkingDocumentEntryDetail(entry: linked)
                            } label: {
                                GlassCard(cornerRadius: 18, padding: 0) {
                                    HStack(spacing: 10) {
                                        Image(GrimoireEntryType.workingDocument.icon)
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 18, height: 18)
                                            .foregroundStyle(LGradients.header)
                                            .frame(width: 32, height: 32)
                                            .background(LColors.glassSurface, in: Circle())

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(linked.title)
                                                .font(.system(size: 14, weight: .black, design: .rounded))
                                                .foregroundStyle(LColors.textPrimary)
                                                .lineLimit(1)

                                            Text("Working Document")
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .foregroundStyle(LColors.textSecondary)
                                        }

                                        Spacer()

                                        Image("rightwavy")
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 14, height: 14)
                                            .foregroundStyle(LGradients.header)
                                    }
                                    .padding(14)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    GrimoireDetailSection(title: "Time Since Working") {
                        GrimoireDetailRow(label: "Time Since Working", value: entry.timeSinceWorking)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        AsteriumSectionHeader(title: "Outcome")
                        Text(entry.overallOutcome.displayName)
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(outcomeColor.opacity(0.8)))
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
                WorkingResultEntryForm(existing: entry)
        }
    }
}