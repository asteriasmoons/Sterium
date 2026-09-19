//
//  MoonPhaseEntryForm.swift
//  Sterium
//

import SwiftUI
import SwiftData

struct MoonPhaseEntryForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existing: MoonPhaseEntry?

    @State private var title: String
    @State private var date: Date
    @State private var moonPhase: String
    @State private var zodiacSign: String
    @State private var energyLevel: Int
    @State private var moodSelections: Set<String>
    @State private var intentionItems: [String]
    @State private var ritualsPerformedItems: [String]
    @State private var manifestationItems: [String]
    @State private var reflections: String

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    private static let moodOptions = [
        "Calm",
        "Reflective",
        "Hopeful",
        "Focused",
        "Inspired",
        "Grounded",
        "Restless",
        "Emotional",
        "Energetic",
        "Drained",
        "Intuitive",
        "Motivated"
    ]

    init(existing: MoonPhaseEntry? = nil) {
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _date = State(initialValue: existing?.date ?? .now)
        _moonPhase = State(initialValue: existing?.moonPhase ?? "")
        _zodiacSign = State(initialValue: existing?.zodiacSign ?? "")
        _energyLevel = State(initialValue: existing?.energyLevel ?? 1)
        _moodSelections = State(initialValue: Set(existing?.moodSelections ?? []))
        _intentionItems = State(initialValue: existing?.intentionItems ?? [])
        _ritualsPerformedItems = State(initialValue: existing?.ritualsPerformedItems ?? [])
        _manifestationItems = State(initialValue: existing?.manifestationItems ?? [])
        _reflections = State(initialValue: existing?.reflections ?? "")
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
                        Text("Moon Phase")
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

                    AsteriumTextField(title: "Title", placeholder: "Moon phase title...", text: $title)

                    AsteriumDateField(title: "Date", date: $date)

                    AsteriumPickerField(
                        title: "Moon Phase",
                        options: ["New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous", "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent"],
                        selection: $moonPhase
                    )

                    AsteriumPickerField(
                        title: "Zodiac Sign",
                        options: ["Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo", "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"],
                        selection: $zodiacSign
                    )

                    energyLevelPicker

                    AsteriumMultiSelectPickerField(
                        title: "Mood",
                        options: Self.moodOptions,
                        selections: $moodSelections
                    )

                    MoonPhaseExpandableItemsField(
                        title: "Intentions",
                        placeholder: "Add an intention...",
                        listTitle: "Intentions",
                        items: $intentionItems
                    )

                    MoonPhaseExpandableItemsField(
                        title: "Rituals Performed",
                        placeholder: "Add a ritual...",
                        listTitle: "Rituals Performed",
                        items: $ritualsPerformedItems
                    )

                    MoonPhaseExpandableItemsField(
                        title: "Manifestations",
                        placeholder: "Add a manifestation...",
                        listTitle: "Manifestations",
                        items: $manifestationItems
                    )

                    AsteriumTextEditor(
                        title: "Reflections",
                        placeholder: "Your reflections...",
                        text: $reflections
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

    private var energyLevelPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ENERGY LEVEL")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { level in
                    Button {
                        energyLevel = level
                    } label: {
                        ZStack {
                            Circle()
                                .fill(level == energyLevel ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassSurface))
                                .frame(width: 40, height: 40)

                            Circle()
                                .strokeBorder(
                                    level == energyLevel ? AnyShapeStyle(Color.clear) : AnyShapeStyle(LColors.glassBorder),
                                    lineWidth: 1
                                )
                                .frame(width: 40, height: 40)

                            Text("\(level)")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(level == energyLevel ? LColors.bg : LColors.textSecondary)
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
            existing.date = date
            existing.moonPhase = moonPhase
            existing.zodiacSign = zodiacSign
            existing.energyLevel = energyLevel
            existing.moodSelections = Self.moodOptions.filter { moodSelections.contains($0) }
            existing.intentionItems = intentionItems
            existing.ritualsPerformedItems = ritualsPerformedItems
            existing.manifestationItems = manifestationItems
            existing.reflections = reflections
            existing.importance = importance
            existing.tags = tags
            existing.attachments = attachments
            existing.relatedEntries = relatedEntries
            existing.additionalNotes = additionalNotes
            existing.updatedAt = .now
        } else {
            let entry = MoonPhaseEntry(
                title: title,
                date: date,
                moonPhase: moonPhase,
                zodiacSign: zodiacSign,
                energyLevel: energyLevel,
                moodSelections: Self.moodOptions.filter { moodSelections.contains($0) },
                intentionItems: intentionItems,
                ritualsPerformedItems: ritualsPerformedItems,
                manifestationItems: manifestationItems,
                reflections: reflections,
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

private struct MoonPhaseExpandableItemsField: View {
    let title: String
    let placeholder: String
    let listTitle: String
    @Binding var items: [String]
    @State private var draft = ""
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            moonPhaseFieldLabel(title)

            HStack(spacing: 10) {
                moonPhaseShortInput(placeholder, text: $draft)
                    .onSubmit(addItem)
                moonPhaseAddButton(action: addItem)
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

private func moonPhaseFieldLabel(_ title: String) -> some View {
    Text(title.uppercased())
        .font(.system(size: 13, weight: .black, design: .rounded))
        .foregroundStyle(LColors.textSecondary)
}

private func moonPhaseShortInput(_ placeholder: String, text: Binding<String>) -> some View {
    GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
        TextField(placeholder, text: text)
            .lineLimit(1)
            .submitLabel(.done)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(LColors.textPrimary)
            .padding(14)
    }
}

private func moonPhaseAddButton(action: @escaping () -> Void) -> some View {
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
