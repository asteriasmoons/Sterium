//
//  DeityDevotionEntryDetail.swift
//  Sterium
//

import SwiftUI

struct DeityDevotionEntryDetail: View {
    let entry: DeityDevotionEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Deity Devotion", title: entry.title, onEdit: { showingEdit = true }) {
            singleCardSection(title: "Date") {
                paragraphText(entry.date.formatted(date: .long, time: .omitted))
            }

            GrimoireDetailSection(title: "Devotion") {
                LazyVGrid(columns: tileColumns, spacing: 12) {
                    detailTile(label: "Deity Name", value: entry.deity)
                    detailTile(label: "Devotion Type", value: entry.devotionType)
                }
            }

            chipSection(title: "Intentions", items: items(from: entry.intentions))

            chipSection(title: "Practices Performed", items: items(from: entry.practicesPerformed))

            singleCardSection(title: "Setting / Sacred Space") {
                paragraphText(entry.sacredSpace)
            }

            offeringsRows

            singleCardSection(title: "Prayer / Invocation") {
                paragraphText(entry.prayerOrInvocation)
            }

            singleCardSection(title: "Reason for Connection") {
                paragraphText(entry.reasonForConnection)
            }

            translucentStatusPill(title: "Message Received", value: entry.receivedMessage ? "Yes" : "No")

            if entry.receivedMessage {
                chipSection(title: "Message Type", items: items(from: entry.messageTypes))

                singleCardSection(title: "Message Details") {
                    paragraphText(entry.messagesReceived)
                }
            }

            chipSection(title: "Feelings During Practice", items: items(from: entry.feelingsDuringPracticeSelections))

            singleCardSection(title: "Feeling Details") {
                paragraphText(entry.feelingsDuringPractice)
            }

            translucentStatusPill(title: "Signs or Synchronicities", value: entry.noticedSignsAfterwards ? "Yes" : "No")

            if entry.noticedSignsAfterwards {
                singleCardSection(title: "Signs or Synchronicities Details") {
                    paragraphText(entry.signsAfterwards)
                }
            }

            if !entry.reflection.isEmpty {
                GrimoireDetailSection(title: "Reflection") {
                    Text(entry.reflection)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                AsteriumSectionHeader(title: "Importance")
                GrimoireImportanceDots(value: entry.importance, showsLabel: false)
            }

            chipSection(title: "Tags", items: entry.tags)

            if !entry.attachments.isEmpty {
                GrimoireDetailSection(title: "Attachments") {
                    GrimoireAttachmentGallery(attachments: entry.attachments)
                }
            }

            GrimoireRelatedEntriesList(entries: entry.relatedEntries)

            GrimoireDetailSection(title: "Additional Notes") {
                let trimmedAdditionalNotes = entry.additionalNotes.trimmingCharacters(in: .whitespacesAndNewlines)
                Text(trimmedAdditionalNotes.isEmpty ? "No additional notes" : trimmedAdditionalNotes)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(trimmedAdditionalNotes.isEmpty ? LColors.textSecondary : LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
            DeityDevotionEntryForm(existing: entry)
        }
    }

    private var tileColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
    }

    @ViewBuilder
    private var offeringsRows: some View {
        let offerings = entry.offerings
        if !offerings.isEmpty {
            GrimoireDetailSection(title: "Offerings") {
                LazyVGrid(columns: tileColumns, spacing: 12) {
                    ForEach(offerings) { offering in
                        detailTile(
                            label: offering.type.isEmpty ? "Offering" : offering.type,
                            value: offering.description
                        )
                    }
                }
            }
        }
    }

    private func singleCardSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            AsteriumSectionHeader(title: title)

            GlassCard {
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func chipSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AsteriumSectionHeader(title: title)
            GrimoireDetailChips(label: title, items: items, showsLabel: false)
        }
    }

    private func translucentStatusPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AsteriumSectionHeader(title: title)

            Text(value)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.12), in: Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                }
        }
    }

    private func detailTile(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(LColors.textSecondary)

            Text(value.isEmpty ? "No \(label.lowercased())" : value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(value.isEmpty ? LColors.textSecondary : LColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(LColors.glassBorder, lineWidth: 1)
        }
    }

    private func paragraphText(_ value: String) -> some View {
        Text(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No details" : value)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? LColors.textSecondary : LColors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func items(from rawValue: String) -> [String] {
        rawValue
            .split(separator: "|")
            .flatMap { $0.split(separator: ",") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
