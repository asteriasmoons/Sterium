
//
//  DeityDevotionEntryForm.swift
//  Asterium
//

import SwiftUI
import SwiftData

struct DeityDevotionEntryForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existing: DeityDevotionEntry?

    @State private var title: String
    @State private var deity: String
    @State private var date: Date
    @State private var devotionType: String
    @State private var offeringGiven: String
    @State private var prayerOrInvocation: String
    @State private var reasonForConnection: String
    @State private var messagesReceived: String
    @State private var feelingsDuringPractice: String
    @State private var signsAfterwards: String
    @State private var reflection: String

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    init(existing: DeityDevotionEntry? = nil) {
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _deity = State(initialValue: existing?.deity ?? "")
        _date = State(initialValue: existing?.date ?? .now)
        _devotionType = State(initialValue: existing?.devotionType ?? "")
        _offeringGiven = State(initialValue: existing?.offeringGiven ?? "")
        _prayerOrInvocation = State(initialValue: existing?.prayerOrInvocation ?? "")
        _reasonForConnection = State(initialValue: existing?.reasonForConnection ?? "")
        _messagesReceived = State(initialValue: existing?.messagesReceived ?? "")
        _feelingsDuringPractice = State(initialValue: existing?.feelingsDuringPractice ?? "")
        _signsAfterwards = State(initialValue: existing?.signsAfterwards ?? "")
        _reflection = State(initialValue: existing?.reflection ?? "")
        _importance = State(initialValue: existing?.importance ?? 1)
        _tags = State(initialValue: existing?.tags ?? [])
        _attachments = State(initialValue: existing?.attachments ?? [])
        _relatedEntries = State(initialValue: existing?.relatedEntries ?? [])
        _additionalNotes = State(initialValue: existing?.additionalNotes ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    HStack(alignment: .center) {
                        Text("Deity Devotion")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)

                        Spacer()

                        Button { dismiss() } label: {
                            Image("xmarkwavy")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(LGradients.header)
                        }
                        .buttonStyle(.plain)
                    }

                    AsteriumTextField(title: "Title", placeholder: "Devotion title...", text: $title)

                    AsteriumTextField(title: "Deity", placeholder: "Name of deity...", text: $deity)

                    AsteriumDateField(title: "Date", date: $date)

                    AsteriumTextField(title: "Devotion Type", placeholder: "e.g. Prayer, Offering, Meditation...", text: $devotionType)

                    AsteriumTextField(title: "Offering Given", placeholder: "What was offered...", text: $offeringGiven)

                    AsteriumTextEditor(
                        title: "Prayer or Invocation",
                        placeholder: "Words spoken or chanted...",
                        text: $prayerOrInvocation
                    )

                    AsteriumTextEditor(
                        title: "Reason for Connection",
                        placeholder: "Why you reached out...",
                        text: $reasonForConnection
                    )

                    AsteriumTextEditor(
                        title: "Messages Received",
                        placeholder: "Any messages or impressions...",
                        text: $messagesReceived
                    )

                    AsteriumTextEditor(
                        title: "Feelings During Practice",
                        placeholder: "How you felt during...",
                        text: $feelingsDuringPractice
                    )

                    AsteriumTextEditor(
                        title: "Signs Afterwards",
                        placeholder: "Signs or synchronicities after...",
                        text: $signsAfterwards
                    )

                    AsteriumTextEditor(
                        title: "Reflection",
                        placeholder: "Your reflection...",
                        text: $reflection
                    )

                    GrimoireUniversalFields(
                        importance: $importance,
                        tags: $tags,
                        attachments: $attachments,
                        relatedEntries: $relatedEntries,
                        additionalNotes: $additionalNotes
                    )

                    AsteriumPrimaryButton(title: "Save Entry") {
                        save()
                    }
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 40)
            }
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func save() {
        if let existing {
            existing.title = title
            existing.deity = deity
            existing.date = date
            existing.devotionType = devotionType
            existing.offeringGiven = offeringGiven
            existing.prayerOrInvocation = prayerOrInvocation
            existing.reasonForConnection = reasonForConnection
            existing.messagesReceived = messagesReceived
            existing.feelingsDuringPractice = feelingsDuringPractice
            existing.signsAfterwards = signsAfterwards
            existing.reflection = reflection
            existing.importance = importance
            existing.tags = tags
            existing.attachments = attachments
            existing.relatedEntries = relatedEntries
            existing.additionalNotes = additionalNotes
            existing.updatedAt = .now
        } else {
            let entry = DeityDevotionEntry(
                title: title,
                deity: deity,
                date: date,
                devotionType: devotionType,
                offeringGiven: offeringGiven,
                prayerOrInvocation: prayerOrInvocation,
                reasonForConnection: reasonForConnection,
                messagesReceived: messagesReceived,
                feelingsDuringPractice: feelingsDuringPractice,
                signsAfterwards: signsAfterwards,
                reflection: reflection,
                importance: importance,
                tags: tags,
                attachments: attachments,
                relatedEntries: relatedEntries,
                additionalNotes: additionalNotes,
                createdAt: .now,
                updatedAt: .now
            )
            modelContext.insert(entry)
        }
        dismiss()
    }
}
