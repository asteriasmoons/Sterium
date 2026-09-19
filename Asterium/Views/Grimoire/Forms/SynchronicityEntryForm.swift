//
//  SynchronicityEntryForm.swift
//  Sterium
//

import SwiftUI
import SwiftData

struct SynchronicityEntryForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existing: SynchronicityEntry?

    @State private var title: String
    @State private var dateTime: Date
    @State private var categorySelections: Set<String>
    @State private var whatHappened: String
    @State private var location: String
    @State private var emotionalState: String
    @State private var possibleMeaning: String
    @State private var relatedEvent: String
    @State private var confidence: Int
    @State private var notes: String

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    private static let categoryOptions = [
        "Numbers",
        "Animals",
        "Dreams",
        "Words & Phrases",
        "Symbols",
        "People",
        "Conversations",
        "Music",
        "Media",
        "Objects",
        "Places",
        "Events",
        "Timing",
        "Nature",
        "Divination",
        "Manifestation",
        "Deity / Spirit",
        "Repeated Pattern",
        "Intuition",
        "Other"
    ]

    private static let emotionalStateOptions = [
        "Calm",
        "Curious",
        "Excited",
        "Happy",
        "Hopeful",
        "Inspired",
        "Grateful",
        "Grounded",
        "Reflective",
        "Thoughtful",
        "Surprised",
        "Amazed",
        "Comforted",
        "Reassured",
        "Connected",
        "Peaceful",
        "Energized",
        "Confused",
        "Uncertain",
        "Uneasy",
        "Anxious",
        "Overwhelmed",
        "Sad",
        "Emotional",
        "Neutral"
    ]

    init(existing: SynchronicityEntry? = nil) {
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _dateTime = State(initialValue: existing?.dateTime ?? .now)
        _categorySelections = State(initialValue: Self.categorySelections(from: existing?.category ?? ""))
        _whatHappened = State(initialValue: existing?.whatHappened ?? "")
        _location = State(initialValue: existing?.location ?? "")
        _emotionalState = State(initialValue: existing?.emotionalState ?? "")
        _possibleMeaning = State(initialValue: existing?.possibleMeaning ?? "")
        _relatedEvent = State(initialValue: existing?.relatedEvent ?? "")
        _confidence = State(initialValue: existing?.confidence ?? 1)
        _notes = State(initialValue: existing?.notes ?? "")
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
                        Text("Synchronicity")
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

                    AsteriumTextField(title: "Title", placeholder: "Synchronicity title...", text: $title)

                    AsteriumDateField(title: "Date & Time", date: $dateTime, includesTime: true)

                    AsteriumMultiSelectPickerField(
                        title: "Category",
                        options: Self.categoryOptions,
                        selections: $categorySelections
                    )

                    AsteriumTextEditor(
                        title: "What Happened",
                        placeholder: "Describe the synchronicity...",
                        text: $whatHappened
                    )

                    AsteriumTextField(title: "Location", placeholder: "Where it happened...", text: $location)

                    AsteriumPickerField(
                        title: "Emotional State",
                        options: Self.emotionalStateOptions,
                        selection: $emotionalState
                    )

                    AsteriumTextEditor(
                        title: "Possible Meaning",
                        placeholder: "What could it mean?",
                        text: $possibleMeaning
                    )

                    AsteriumTextField(title: "Related Event", placeholder: "Any related events...", text: $relatedEvent)

                    confidencePicker

                    AsteriumTextEditor(
                        title: "Notes",
                        placeholder: "Any other notes...",
                        text: $notes
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
                .padding(.bottom, 120)
            }
            .scrollDismissesKeyboard(.never)
            .grimoireFormBackground()
            .toolbar(.hidden, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationContentInteraction(.scrolls)
    }

    private var confidencePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CONFIDENCE")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { level in
                    Button {
                        confidence = level
                    } label: {
                        ZStack {
                            Circle()
                                .fill(level == confidence ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassSurface))
                                .frame(width: 40, height: 40)

                            Circle()
                                .strokeBorder(
                                    level == confidence ? AnyShapeStyle(Color.clear) : AnyShapeStyle(LColors.glassBorder),
                                    lineWidth: 1
                                )
                                .frame(width: 40, height: 40)

                            Text("\(level)")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(level == confidence ? LColors.bg : LColors.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func save() {
        if let existing {
            existing.title = title
            existing.dateTime = dateTime
            existing.category = Self.categoryString(from: categorySelections)
            existing.whatHappened = whatHappened
            existing.location = location
            existing.emotionalState = emotionalState
            existing.possibleMeaning = possibleMeaning
            existing.relatedEvent = relatedEvent
            existing.confidence = confidence
            existing.notes = notes
            existing.importance = importance
            existing.tags = tags
            existing.attachments = attachments
            existing.relatedEntries = relatedEntries
            existing.additionalNotes = additionalNotes
            existing.updatedAt = .now
        } else {
            let entry = SynchronicityEntry(
                title: title,
                dateTime: dateTime,
                category: Self.categoryString(from: categorySelections),
                whatHappened: whatHappened,
                location: location,
                emotionalState: emotionalState,
                possibleMeaning: possibleMeaning,
                relatedEvent: relatedEvent,
                confidence: confidence,
                notes: notes,
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

    private static func categorySelections(from rawValue: String) -> Set<String> {
        let savedValues = rawValue
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let matchingValues = savedValues.filter { categoryOptions.contains($0) }
        if matchingValues.isEmpty && !rawValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return ["Other"]
        }

        return Set(matchingValues)
    }

    private static func categoryString(from selections: Set<String>) -> String {
        categoryOptions
            .filter { selections.contains($0) }
            .joined(separator: ", ")
    }
}
