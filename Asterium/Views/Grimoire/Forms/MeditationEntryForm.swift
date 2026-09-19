//
//  MeditationEntryForm.swift
//  Sterium
//

import SwiftUI
import SwiftData

struct MeditationEntryForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existing: MeditationEntry?

    @State private var title: String
    @State private var date: Date
    @State private var durationMinutesText: String
    @State private var techniqueSelections: Set<String>
    @State private var customTechnique: String
    @State private var kindSelections: Set<String>
    @State private var customKind: String
    @State private var intentionItems: [String]
    @State private var environmentType: String
    @State private var environment: String
    @State private var beforeMeditation: String
    @State private var duringMeditation: String
    @State private var afterMeditation: String
    @State private var insights: String
    @State private var followUpItems: [String]

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    private static let techniqueOptions = [
        "Breathwork",
        "Visualization",
        "Body Scan",
        "Sound Bathing",
        "Somatic Tracking",
        "Trance / Journeying",
        "Focal Gazing",
        "Mantra",
        "Moving",
        "Custom"
    ]

    private static let kindOptions = [
        "Reconditioning",
        "Inner Child",
        "Shadow Work",
        "Self-Love",
        "Gratitude",
        "Custom"
    ]

    private static let indoorEnvironmentOptions = [
        "Bedroom",
        "Living Room",
        "Office",
        "Patio",
        "Church",
        "Temple"
    ]

    private static let outdoorEnvironmentOptions = [
        "Forest",
        "Woods",
        "Garden",
        "Meadow",
        "Yard",
        "Park",
        "Cave",
        "Mountain"
    ]

    init(existing: MeditationEntry? = nil) {
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _date = State(initialValue: existing?.date ?? .now)
        _durationMinutesText = State(initialValue: existing.map { "\($0.durationMinutes)" } ?? "")
        _techniqueSelections = State(initialValue: Self.selections(from: existing?.technique ?? "", options: Self.techniqueOptions))
        _customTechnique = State(initialValue: Self.customValue(
            from: existing?.technique ?? "",
            savedCustomValue: existing?.customTechnique ?? "",
            options: Self.techniqueOptions
        ))
        _kindSelections = State(initialValue: Self.selections(from: existing?.meditationKind ?? "", options: Self.kindOptions))
        _customKind = State(initialValue: Self.customValue(
            from: existing?.meditationKind ?? "",
            savedCustomValue: existing?.customKind ?? "",
            options: Self.kindOptions
        ))
        _intentionItems = State(initialValue: existing?.intentionItems ?? [])
        _environmentType = State(initialValue: Self.environmentType(for: existing))
        _environment = State(initialValue: existing?.environment ?? "")
        _beforeMeditation = State(initialValue: existing?.beforeMeditation ?? "")
        _duringMeditation = State(initialValue: existing?.duringMeditation ?? "")
        _afterMeditation = State(initialValue: existing?.afterMeditation ?? "")
        _insights = State(initialValue: existing?.insights ?? "")
        _followUpItems = State(initialValue: existing?.followUpItems ?? [])
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
                        Text("Meditation")
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

                    AsteriumTextField(title: "Title", placeholder: "Meditation title...", text: $title)

                    AsteriumDateField(title: "Date", date: $date)

                    durationField

                    AsteriumMultiSelectPickerField(
                        title: "Technique",
                        options: Self.techniqueOptions,
                        selections: $techniqueSelections,
                        maxDropdownHeight: 520
                    )

                    if techniqueSelections.contains("Custom") {
                        AsteriumTextField(
                            title: "Custom Technique",
                            placeholder: "Custom technique...",
                            text: $customTechnique
                        )
                    }

                    AsteriumMultiSelectPickerField(
                        title: "Kind",
                        options: Self.kindOptions,
                        selections: $kindSelections
                    )

                    if kindSelections.contains("Custom") {
                        meditationShortInput("Custom kind...", text: $customKind)
                    }

                    MeditationFollowUpField(
                        title: "Intentions",
                        placeholder: "Add an intention...",
                        listTitle: "Intentions",
                        items: $intentionItems
                    )

                    MeditationEnvironmentField(
                        environmentType: $environmentType,
                        environment: $environment,
                        indoorOptions: Self.indoorEnvironmentOptions,
                        outdoorOptions: Self.outdoorEnvironmentOptions
                    )

                    AsteriumTextEditor(
                        title: "Before Meditation",
                        placeholder: "State of mind before...",
                        text: $beforeMeditation
                    )

                    AsteriumTextEditor(
                        title: "During Meditation",
                        placeholder: "What happened during...",
                        text: $duringMeditation
                    )

                    AsteriumTextEditor(
                        title: "After Meditation",
                        placeholder: "How you felt after...",
                        text: $afterMeditation
                    )

                    AsteriumTextEditor(
                        title: "Insights",
                        placeholder: "Insights gained...",
                        text: $insights
                    )

                    MeditationFollowUpField(
                        title: "Follow-Up",
                        placeholder: "Follow-up action...",
                        listTitle: "Follow-Up Actions",
                        items: $followUpItems
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

    private var durationField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DURATION (MINUTES)")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            TextField("0", text: $durationMinutesText)
                .keyboardType(.numberPad)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
                .padding(14)
                .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.inputRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: LSpacing.inputRadius)
                        .strokeBorder(LColors.glassBorder, lineWidth: 1)
                }
        }
    }

    private func save() {
        let duration = Int(durationMinutesText) ?? 0

        if let existing {
            existing.title = title
            existing.date = date
            existing.durationMinutes = duration
            existing.technique = Self.selectionString(from: techniqueSelections, options: Self.techniqueOptions)
            existing.customTechnique = techniqueSelections.contains("Custom") ? customTechnique.trimmingCharacters(in: .whitespacesAndNewlines) : ""
            existing.meditationKind = Self.selectionString(from: kindSelections, options: Self.kindOptions)
            existing.customKind = kindSelections.contains("Custom") ? customKind.trimmingCharacters(in: .whitespacesAndNewlines) : ""
            existing.intentionItems = intentionItems
            existing.environmentType = environmentType
            existing.environment = environment
            existing.beforeMeditation = beforeMeditation
            existing.duringMeditation = duringMeditation
            existing.afterMeditation = afterMeditation
            existing.insights = insights
            existing.followUpItems = followUpItems
            existing.importance = importance
            existing.tags = tags
            existing.attachments = attachments
            existing.relatedEntries = relatedEntries
            existing.additionalNotes = additionalNotes
            existing.updatedAt = .now
        } else {
            let entry = MeditationEntry(
                title: title,
                date: date,
                durationMinutes: duration,
                technique: Self.selectionString(from: techniqueSelections, options: Self.techniqueOptions),
                customTechnique: techniqueSelections.contains("Custom") ? customTechnique.trimmingCharacters(in: .whitespacesAndNewlines) : "",
                meditationKind: Self.selectionString(from: kindSelections, options: Self.kindOptions),
                customKind: kindSelections.contains("Custom") ? customKind.trimmingCharacters(in: .whitespacesAndNewlines) : "",
                intention: intentionItems.joined(separator: "\n"),
                environment: environment,
                environmentType: environmentType,
                beforeMeditation: beforeMeditation,
                duringMeditation: duringMeditation,
                afterMeditation: afterMeditation,
                insights: insights,
                followUp: followUpItems.joined(separator: "\n"),
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

    private static func selections(from rawValue: String, options: [String]) -> Set<String> {
        let values = rawValue
            .split(separator: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let matches = values.filter { options.contains($0) }

        if matches.isEmpty && !values.isEmpty {
            return ["Custom"]
        }

        return Set(matches)
    }

    private static func customValue(from rawValue: String, savedCustomValue: String, options: [String]) -> String {
        let savedCustomValue = savedCustomValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if !savedCustomValue.isEmpty {
            return savedCustomValue
        }

        return rawValue
            .split(separator: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !options.contains($0) }
            .joined(separator: ", ")
    }

    private static func selectionString(from selections: Set<String>, options: [String]) -> String {
        options
            .filter { selections.contains($0) }
            .joined(separator: " | ")
    }

    private static func environmentType(for entry: MeditationEntry?) -> String {
        guard let entry else { return "" }
        if !entry.environmentType.isEmpty {
            return entry.environmentType
        }
        if indoorEnvironmentOptions.contains(entry.environment) {
            return "Indoor"
        }
        if outdoorEnvironmentOptions.contains(entry.environment) {
            return "Outdoor"
        }
        return ""
    }
}

private struct MeditationEnvironmentField: View {
    @Binding var environmentType: String
    @Binding var environment: String
    let indoorOptions: [String]
    let outdoorOptions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            meditationFieldLabel("Environment")

            HStack(spacing: 10) {
                environmentButton("Indoor", options: indoorOptions)
                environmentButton("Outdoor", options: outdoorOptions)
            }

            if environmentType == "Indoor" {
                AsteriumPickerField(
                    title: "Indoor",
                    options: indoorOptions,
                    selection: $environment
                )
            } else if environmentType == "Outdoor" {
                AsteriumPickerField(
                    title: "Outdoor",
                    options: outdoorOptions,
                    selection: $environment
                )
            }
        }
    }

    private func environmentButton(_ title: String, options: [String]) -> some View {
        let isSelected = environmentType == title

        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                environmentType = title
                if !options.contains(environment) {
                    environment = ""
                }
            }
        } label: {
            Text(title)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(isSelected ? AnyShapeStyle(LColors.bg) : AnyShapeStyle(LColors.textPrimary))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    isSelected ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassSurface),
                    in: RoundedRectangle(cornerRadius: LSpacing.inputRadius)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: LSpacing.inputRadius)
                        .strokeBorder(isSelected ? Color.clear : LColors.glassBorder, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}

private struct MeditationFollowUpField: View {
    let title: String
    let placeholder: String
    let listTitle: String
    @Binding var items: [String]
    @State private var draft = ""
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            meditationFieldLabel(title)

            HStack(spacing: 10) {
                meditationShortInput(placeholder, text: $draft)
                    .onSubmit(addItem)
                meditationAddButton(action: addItem)
            }

            if !items.isEmpty {
                GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                                isExpanded.toggle()
                            }
                        } label: {
                            HStack {
                                Text(listTitle)
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundStyle(LColors.textPrimary)

                                Spacer()

                                Image(isExpanded ? "chevup" : "chevdown")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                    .foregroundStyle(LGradients.header)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)

                        if isExpanded {
                            ForEach(items.indices, id: \.self) { index in
                                HStack(spacing: 10) {
                                    Text(items[index])
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(LColors.textPrimary)

                                    Spacer(minLength: 0)

                                    Button {
                                        items.remove(at: index)
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
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                            }
                        }
                    }
                }
            }
        }
    }

    private func addItem() {
        let value = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        items.append(value)
        draft = ""
    }
}

private func meditationFieldLabel(_ title: String) -> some View {
    Text(title.uppercased())
        .font(.system(size: 13, weight: .black, design: .rounded))
        .foregroundStyle(LColors.textSecondary)
}

private func meditationShortInput(_ placeholder: String, text: Binding<String>) -> some View {
    GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
        TextField(placeholder, text: text)
            .lineLimit(1)
            .submitLabel(.done)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(LColors.textPrimary)
            .padding(14)
    }
}

private func meditationAddButton(action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Image("addwavy")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .foregroundStyle(LGradients.header)
            .frame(width: 44, height: 44)
            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(LColors.glassBorder, lineWidth: 1)
            }
    }
    .buttonStyle(.plain)
}
