
//
//  DeityDevotionEntryDetail.swift
//  Asterium
//

import SwiftUI

struct DeityDevotionEntryDetail: View {
    let entry: DeityDevotionEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Deity Devotion", title: entry.title, onEdit: { showingEdit = true }) {
                    GrimoireDetailSection(title: "Overview") {
                        GrimoireDetailRow(label: "Deity", value: entry.deity)
                        GrimoireDetailRow(label: "Date", value: entry.date.formatted(date: .long, time: .omitted))
                        GrimoireDetailRow(label: "Devotion Type", value: entry.devotionType)
                    }

                    GrimoireDetailSection(title: "Practice") {
                        GrimoireDetailRow(label: "Offering Given", value: entry.offeringGiven)
                        GrimoireDetailRow(label: "Prayer / Invocation", value: entry.prayerOrInvocation)
                        GrimoireDetailRow(label: "Reason for Connection", value: entry.reasonForConnection)
                    }

                    GrimoireDetailSection(title: "Experience") {
                        GrimoireDetailRow(label: "Messages Received", value: entry.messagesReceived)
                        GrimoireDetailRow(label: "Feelings During Practice", value: entry.feelingsDuringPractice)
                        GrimoireDetailRow(label: "Signs Afterwards", value: entry.signsAfterwards)
                    }

                    if !entry.reflection.isEmpty {
                        GrimoireDetailSection(title: "Reflection") {
                            Text(entry.reflection)
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
                DeityDevotionEntryForm(existing: entry)
        }
    }
}