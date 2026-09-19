//
//  MeditationEntryDetail.swift
//  Sterium
//

import SwiftUI

struct MeditationEntryDetail: View {
    let entry: MeditationEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Meditation", title: entry.title, onEdit: { showingEdit = true }) {
            GrimoireDetailSection(title: "Date") {
                detailValue(entry.date.formatted(date: .long, time: .omitted))
            }

            translucentPillSection(
                title: "Duration",
                value: entry.durationMinutes > 0 ? "\(entry.durationMinutes) minutes" : "",
                emptyText: "No duration"
            )

            gradientPillSection(
                title: "Techniques",
                items: selectionItems(from: entry.technique, customValue: entry.customTechnique)
            )

            gradientPillSection(
                title: "Kind",
                items: selectionItems(from: entry.meditationKind, customValue: entry.customKind)
            )

            GrimoireDetailSection(title: "Intentions") {
                intentionsTiles
            }

            translucentPillSection(
                title: "Environment",
                value: entry.environment,
                emptyText: "No environment"
            )

            GrimoireDetailSection(title: "Experience") {
                GrimoireDetailRow(label: "Before Meditation", value: entry.beforeMeditation)
                GrimoireDetailRow(label: "During Meditation", value: entry.duringMeditation)
                GrimoireDetailRow(label: "After Meditation", value: entry.afterMeditation)
            }

            GrimoireDetailSection(title: "Insights") {
                if !entry.insights.isEmpty {
                    detailValue(entry.insights)
                }
            }

            if !entry.followUpItems.isEmpty {
                GrimoireDetailSection(title: "Follow Up Actions") {
                    numberedFollowUpActions
                }
            }

            detailFooter
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
            MeditationEntryForm(existing: entry)
        }
    }

    private var intentionsTiles: some View {
        VStack(alignment: .leading, spacing: 10) {
            if entry.intentionItems.isEmpty {
                translucentTile("No intentions", isEmpty: true)
            } else {
                ForEach(entry.intentionItems, id: \.self) { intention in
                    translucentTile(intention)
                }
            }
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

    private var numberedFollowUpActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(entry.followUpItems.indices, id: \.self) { index in
                HStack(alignment: .center, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.bg)
                        .frame(width: 28, height: 28)
                        .background(LGradients.tag, in: Circle())

                    Text(entry.followUpItems[index])
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func gradientPillSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AsteriumSectionHeader(title: title)
            GrimoireDetailChips(label: title, items: items, showsLabel: false)
        }
    }

    private func translucentPillSection(title: String, value: String, emptyText: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AsteriumSectionHeader(title: title)

            Text(value.isEmpty ? emptyText : value)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(value.isEmpty ? LColors.textSecondary : LColors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.12), in: Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                }
        }
    }

    private func translucentTile(_ value: String, isEmpty: Bool = false) -> some View {
        Text(value)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(isEmpty ? LColors.textSecondary : LColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
            }
    }

    private func detailValue(_ value: String) -> some View {
        Text(value)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(LColors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func selectionItems(from rawValue: String, customValue: String) -> [String] {
        rawValue
            .split(separator: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { value in
                let trimmedCustomValue = customValue.trimmingCharacters(in: .whitespacesAndNewlines)
                return value == "Custom" && !trimmedCustomValue.isEmpty ? trimmedCustomValue : value
            }
    }
}
