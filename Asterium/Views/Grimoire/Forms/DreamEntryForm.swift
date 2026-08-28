
//
//  DreamEntryForm.swift
//  Asterium
//

import SwiftUI
import SwiftData

struct DreamEntryForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existing: DreamEntry?

    @State private var title: String
    @State private var date: Date
    @State private var sleepQualityDisplay: String
    @State private var dreamTypeDisplay: String
    @State private var dreamSummary: String
    @State private var symbols: [String]
    @State private var peoplePresent: [String]
    @State private var animals: [String]
    @State private var locations: [String]
    @State private var dominantEmotions: [String]
    @State private var colors: [String]
    @State private var interpretation: String
    @State private var followUpActions: String

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    init(existing: DreamEntry? = nil) {
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _date = State(initialValue: existing?.date ?? .now)
        _sleepQualityDisplay = State(initialValue: (existing.flatMap { SleepQuality(rawValue: $0.sleepQualityRawValue) } ?? .fair).displayName)
        _dreamTypeDisplay = State(initialValue: (existing.flatMap { DreamType(rawValue: $0.dreamTypeRawValue) } ?? .ordinary).displayName)
        _dreamSummary = State(initialValue: existing?.dreamSummary ?? "")
        _symbols = State(initialValue: existing?.symbols ?? [])
        _peoplePresent = State(initialValue: existing?.peoplePresent ?? [])
        _animals = State(initialValue: existing?.animals ?? [])
        _locations = State(initialValue: existing?.locations ?? [])
        _dominantEmotions = State(initialValue: existing?.dominantEmotions ?? [])
        _colors = State(initialValue: existing?.colors ?? [])
        _interpretation = State(initialValue: existing?.interpretation ?? "")
        _followUpActions = State(initialValue: existing?.followUpActions ?? "")
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
                        Text("Dream")
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

                    AsteriumTextField(title: "Title", placeholder: "Dream title...", text: $title)

                    AsteriumDateField(title: "Date", date: $date)

                    AsteriumPickerField(
                        title: "Sleep Quality",
                        options: SleepQuality.allCases.map { $0.displayName },
                        selection: $sleepQualityDisplay
                    )

                    AsteriumPickerField(
                        title: "Dream Type",
                        options: DreamType.allCases.map { $0.displayName },
                        selection: $dreamTypeDisplay
                    )

                    AsteriumTextEditor(
                        title: "Dream Summary",
                        placeholder: "Describe your dream...",
                        text: $dreamSummary,
                        minHeight: 250
                    )

                    GrimoireChipInput(title: "Symbols", placeholder: "Add symbol...", items: $symbols)

                    GrimoireChipInput(title: "People Present", placeholder: "Add person...", items: $peoplePresent)

                    GrimoireChipInput(title: "Animals", placeholder: "Add animal...", items: $animals)

                    GrimoireChipInput(title: "Locations", placeholder: "Add location...", items: $locations)

                    GrimoireChipInput(title: "Dominant Emotions", placeholder: "Add emotion...", items: $dominantEmotions)

                    GrimoireChipInput(title: "Colors", placeholder: "Add color...", items: $colors)

                    AsteriumTextEditor(
                        title: "Interpretation",
                        placeholder: "Your interpretation...",
                        text: $interpretation
                    )

                    AsteriumTextEditor(
                        title: "Follow-Up Actions",
                        placeholder: "Any actions to take...",
                        text: $followUpActions
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
            .scrollDismissesKeyboard(.immediately)
            .simultaneousGesture(
                TapGesture().onEnded {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
            )
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func save() {
        if let existing {
            existing.title = title
            existing.date = date
            existing.sleepQualityRawValue = (SleepQuality.allCases.first { $0.displayName == sleepQualityDisplay } ?? .fair).rawValue
            existing.dreamTypeRawValue = (DreamType.allCases.first { $0.displayName == dreamTypeDisplay } ?? .ordinary).rawValue
            existing.dreamSummary = dreamSummary
            existing.symbols = symbols
            existing.peoplePresent = peoplePresent
            existing.animals = animals
            existing.locations = locations
            existing.dominantEmotions = dominantEmotions
            existing.colors = colors
            existing.interpretation = interpretation
            existing.followUpActions = followUpActions
            existing.importance = importance
            existing.tags = tags
            existing.attachments = attachments
            existing.relatedEntries = relatedEntries
            existing.additionalNotes = additionalNotes
            existing.updatedAt = .now
        } else {
            let entry = DreamEntry(
                title: title,
                date: date,
                sleepQuality: SleepQuality.allCases.first { $0.displayName == sleepQualityDisplay } ?? .fair,
                dreamType: DreamType.allCases.first { $0.displayName == dreamTypeDisplay } ?? .ordinary,
                dreamSummary: dreamSummary,
                symbols: symbols,
                peoplePresent: peoplePresent,
                animals: animals,
                locations: locations,
                dominantEmotions: dominantEmotions,
                colors: colors,
                interpretation: interpretation,
                followUpActions: followUpActions,
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
