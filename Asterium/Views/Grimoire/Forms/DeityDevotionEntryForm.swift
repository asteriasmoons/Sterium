//
//  DeityDevotionEntryForm.swift
//  Sterium
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
    @State private var intentions: Set<String>
    @State private var practicesPerformed: Set<String>
    @State private var sacredSpace: String
    @State private var offerings: [DeityDevotionOffering]
    @State private var prayerOrInvocation: String
    @State private var reasonForConnection: String
    @State private var receivedMessage: Bool
    @State private var messageTypes: Set<String>
    @State private var messagesReceived: String
    @State private var feelingsDuringPracticeSelections: Set<String>
    @State private var feelingsDuringPractice: String
    @State private var noticedSignsAfterwards: Bool
    @State private var signsAfterwards: String
    @State private var reflection: String

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    private static let devotionTypeOptions = [
        "Prayer",
        "Offering",
        "Meditation",
        "Invocation",
        "Petition",
        "Gratitude",
        "Praise",
        "Worship",
        "Communion",
        "Contemplation",
        "Ritual",
        "Candle Devotion",
        "Altar Work",
        "Acts of Service",
        "Vow or Dedication",
        "Feast or Celebration",
        "Study",
        "Divination",
        "Custom"
    ]

    private static let intentionOptions = [
        "Guidance",
        "Gratitude",
        "Protection",
        "Healing",
        "Wisdom",
        "Strength",
        "Connection",
        "Devotion",
        "Forgiveness",
        "Celebration",
        "Support",
        "Clarity",
        "Transformation",
        "Custom"
    ]

    private static let practiceOptions = [
        "Prayer",
        "Meditation",
        "Candle Lighting",
        "Incense",
        "Chanting",
        "Music",
        "Divination",
        "Altar Tending",
        "Devotional Reading",
        "Journaling",
        "Offering",
        "Custom"
    ]

    private static let sacredSpaceOptions = [
        "Altar",
        "Outdoors",
        "Bedside",
        "Bath",
        "Sacred Space",
        "Temporary Altar",
        "Other"
    ]

    private static let offeringTypeOptions = [
        "Food / Drink",
        "Incense",
        "Candle",
        "Flowers / Plants",
        "Herbs",
        "Objects",
        "Art / Creative Work",
        "Money / Donation",
        "Acts of Service",
        "Personal Item",
        "Other"
    ]

    private static let messageTypeOptions = [
        "Thought",
        "Image",
        "Feeling",
        "Word / Phrase",
        "Symbol",
        "Dream",
        "Intuition",
        "Physical Sensation",
        "Other"
    ]

    private static let feelingOptions = [
        "Peaceful",
        "Connected",
        "Emotional",
        "Energized",
        "Grounded",
        "Comforted",
        "Inspired",
        "Reverent",
        "Curious",
        "Uncertain",
        "Distracted",
        "Overwhelmed",
        "Neutral",
        "Other"
    ]

    init(existing: DeityDevotionEntry? = nil) {
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _deity = State(initialValue: existing?.deity ?? "")
        _date = State(initialValue: existing?.date ?? .now)
        _devotionType = State(initialValue: existing?.devotionType ?? "")
        _intentions = State(initialValue: Self.selections(from: existing?.intentions ?? "", options: Self.intentionOptions))
        _practicesPerformed = State(initialValue: Self.selections(from: existing?.practicesPerformed ?? "", options: Self.practiceOptions))
        _sacredSpace = State(initialValue: existing?.sacredSpace ?? "")
        _offerings = State(initialValue: existing?.offerings ?? [])
        _prayerOrInvocation = State(initialValue: existing?.prayerOrInvocation ?? "")
        _reasonForConnection = State(initialValue: existing?.reasonForConnection ?? "")
        _receivedMessage = State(initialValue: existing?.receivedMessage ?? false)
        _messageTypes = State(initialValue: Self.selections(from: existing?.messageTypes ?? "", options: Self.messageTypeOptions))
        _messagesReceived = State(initialValue: existing?.messagesReceived ?? "")
        _feelingsDuringPracticeSelections = State(initialValue: Self.selections(from: existing?.feelingsDuringPracticeSelections ?? "", options: Self.feelingOptions))
        _feelingsDuringPractice = State(initialValue: existing?.feelingsDuringPractice ?? "")
        _noticedSignsAfterwards = State(initialValue: existing?.noticedSignsAfterwards ?? false)
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

                    formSection("Devotion") {
                        AsteriumTextField(title: "Title", placeholder: "Devotion title...", text: $title)

                        AsteriumTextField(title: "Deity", placeholder: "Name of deity...", text: $deity)

                        AsteriumDateField(title: "Date", date: $date)

                        AsteriumPickerField(
                            title: "Devotion Type",
                            options: Self.devotionTypeOptions,
                            selection: $devotionType
                        )

                        AsteriumMultiSelectPickerField(
                            title: "Intentions",
                            options: Self.intentionOptions,
                            selections: $intentions
                        )
                    }

                    formSection("Practice") {
                        AsteriumMultiSelectPickerField(
                            title: "Practices Performed",
                            options: Self.practiceOptions,
                            selections: $practicesPerformed
                        )

                        AsteriumPickerField(
                            title: "Setting / Sacred Space",
                            options: Self.sacredSpaceOptions,
                            selection: $sacredSpace
                        )

                        DeityOfferingsField(
                            offerings: $offerings,
                            offeringTypeOptions: Self.offeringTypeOptions
                        )

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
                    }

                    formSection("Experience") {
                        DeityYesNoField(
                            title: "Message or Impression Received?",
                            isOn: $receivedMessage
                        )

                        if receivedMessage {
                            AsteriumMultiSelectPickerField(
                                title: "Message Type",
                                options: Self.messageTypeOptions,
                                selections: $messageTypes
                            )

                            AsteriumTextEditor(
                                title: "Messages Received",
                                placeholder: "Any messages or impressions...",
                                text: $messagesReceived
                            )
                        }

                        AsteriumMultiSelectPickerField(
                            title: "Feelings During Practice",
                            options: Self.feelingOptions,
                            selections: $feelingsDuringPracticeSelections
                        )

                        AsteriumTextEditor(
                            title: "Feelings During Practice Details",
                            placeholder: "How you felt during...",
                            text: $feelingsDuringPractice
                        )

                        DeityYesNoField(
                            title: "Signs or Synchronicities Afterwards?",
                            isOn: $noticedSignsAfterwards
                        )

                        if noticedSignsAfterwards {
                            AsteriumTextEditor(
                                title: "Signs Afterwards",
                                placeholder: "Signs or synchronicities after...",
                                text: $signsAfterwards
                            )
                        }
                    }

                    formSection("Reflection") {
                        AsteriumTextEditor(
                            title: "Reflection",
                            placeholder: "Your reflection...",
                            text: $reflection
                        )
                    }

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
                .padding(.bottom, 120)
            }
            .scrollDismissesKeyboard(.never)
            .grimoireFormBackground()
            .toolbar(.hidden, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationContentInteraction(.scrolls)
    }

    private func save() {
        if let existing {
            existing.title = title
            existing.deity = deity
            existing.date = date
            existing.devotionType = devotionType
            existing.intentions = Self.selectionString(from: intentions, options: Self.intentionOptions)
            existing.practicesPerformed = Self.selectionString(from: practicesPerformed, options: Self.practiceOptions)
            existing.sacredSpace = sacredSpace
            existing.offerings = cleanedOfferings
            existing.prayerOrInvocation = prayerOrInvocation
            existing.reasonForConnection = reasonForConnection
            existing.receivedMessage = receivedMessage
            existing.messageTypes = receivedMessage ? Self.selectionString(from: messageTypes, options: Self.messageTypeOptions) : ""
            existing.messagesReceived = messagesReceived
            existing.feelingsDuringPracticeSelections = Self.selectionString(from: feelingsDuringPracticeSelections, options: Self.feelingOptions)
            existing.feelingsDuringPractice = feelingsDuringPractice
            existing.noticedSignsAfterwards = noticedSignsAfterwards
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
                intentions: Self.selectionString(from: intentions, options: Self.intentionOptions),
                practicesPerformed: Self.selectionString(from: practicesPerformed, options: Self.practiceOptions),
                sacredSpace: sacredSpace,
                offerings: cleanedOfferings,
                prayerOrInvocation: prayerOrInvocation,
                reasonForConnection: reasonForConnection,
                receivedMessage: receivedMessage,
                messageTypes: receivedMessage ? Self.selectionString(from: messageTypes, options: Self.messageTypeOptions) : "",
                messagesReceived: messagesReceived,
                feelingsDuringPracticeSelections: Self.selectionString(from: feelingsDuringPracticeSelections, options: Self.feelingOptions),
                feelingsDuringPractice: feelingsDuringPractice,
                noticedSignsAfterwards: noticedSignsAfterwards,
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

    private var cleanedOfferings: [DeityDevotionOffering] {
        offerings.compactMap { offering in
            let type = offering.type.trimmingCharacters(in: .whitespacesAndNewlines)
            let description = offering.description.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !type.isEmpty || !description.isEmpty else { return nil }
            return DeityDevotionOffering(id: offering.id, type: type, description: description)
        }
    }

    private func formSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            AsteriumSectionHeader(title: title)
            content()
        }
    }

    private static func selections(from rawValue: String, options: [String]) -> Set<String> {
        let savedValues = rawValue
            .split(separator: "|")
            .flatMap { $0.split(separator: ",") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let matchingValues = savedValues.filter { options.contains($0) }
        if matchingValues.isEmpty && !rawValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return options.contains("Custom") ? ["Custom"] : []
        }

        return Set(matchingValues)
    }

    private static func selectionString(from selections: Set<String>, options: [String]) -> String {
        options
            .filter { selections.contains($0) }
            .joined(separator: " | ")
    }
}

private struct DeityOfferingsField: View {
    @Binding var offerings: [DeityDevotionOffering]
    let offeringTypeOptions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("OFFERINGS")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            VStack(spacing: 12) {
                ForEach($offerings) { $offering in
                    GlassCard(cornerRadius: LSpacing.inputRadius, padding: 12) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Offering")
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundStyle(LGradients.header)

                                Spacer()

                                Button {
                                    offerings.removeAll { $0.id == offering.id }
                                } label: {
                                    Image("xmarkwavy")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                        .foregroundStyle(LGradients.header)
                                }
                                .buttonStyle(.plain)
                            }

                            AsteriumPickerField(
                                title: "Offering Type",
                                options: offeringTypeOptions,
                                selection: $offering.type
                            )

                            AsteriumTextEditor(
                                title: "Description",
                                placeholder: "Describe what was offered...",
                                text: $offering.description,
                                minHeight: 90
                            )
                        }
                    }
                }
            }

            Button {
                offerings.append(DeityDevotionOffering(type: "", description: ""))
            } label: {
                HStack(spacing: 8) {
                    Image("addwavy")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)

                    Text("Add Offering")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                }
                .foregroundStyle(LGradients.header)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(LColors.glassBorder, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

private struct DeityYesNoField: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            HStack(spacing: 10) {
                yesNoButton("Yes", selected: isOn) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                        isOn = true
                    }
                }

                yesNoButton("No", selected: !isOn) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                        isOn = false
                    }
                }
            }
        }
    }

    private func yesNoButton(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(selected ? AnyShapeStyle(LColors.bg) : AnyShapeStyle(LColors.textPrimary))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(selected ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassSurface), in: RoundedRectangle(cornerRadius: LSpacing.inputRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: LSpacing.inputRadius)
                        .strokeBorder(selected ? AnyShapeStyle(Color.clear) : AnyShapeStyle(LColors.glassBorder), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}
