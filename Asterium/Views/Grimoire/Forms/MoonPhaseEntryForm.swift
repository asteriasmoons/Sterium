
//
//  MoonPhaseEntryForm.swift
//  Asterium
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
    @State private var mood: String
    @State private var intentions: String
    @State private var ritualsPerformed: String
    @State private var manifestations: String
    @State private var reflections: String

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    init(existing: MoonPhaseEntry? = nil) {
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _date = State(initialValue: existing?.date ?? .now)
        _moonPhase = State(initialValue: existing?.moonPhase ?? "")
        _zodiacSign = State(initialValue: existing?.zodiacSign ?? "")
        _energyLevel = State(initialValue: existing?.energyLevel ?? 1)
        _mood = State(initialValue: existing?.mood ?? "")
        _intentions = State(initialValue: existing?.intentions ?? "")
        _ritualsPerformed = State(initialValue: existing?.ritualsPerformed ?? "")
        _manifestations = State(initialValue: existing?.manifestations ?? "")
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

                    AsteriumTextField(title: "Moon Phase", placeholder: "e.g. Full Moon, New Moon...", text: $moonPhase)

                    AsteriumTextField(title: "Zodiac Sign", placeholder: "e.g. Aries, Pisces...", text: $zodiacSign)

                    energyLevelPicker

                    AsteriumTextField(title: "Mood", placeholder: "Your mood...", text: $mood)

                    AsteriumTextEditor(
                        title: "Intentions",
                        placeholder: "Your intentions...",
                        text: $intentions
                    )

                    AsteriumTextEditor(
                        title: "Rituals Performed",
                        placeholder: "Rituals you performed...",
                        text: $ritualsPerformed
                    )

                    AsteriumTextEditor(
                        title: "Manifestations",
                        placeholder: "Manifestation work...",
                        text: $manifestations
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
                .padding(.bottom, 40)
            }
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
        }
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
            existing.mood = mood
            existing.intentions = intentions
            existing.ritualsPerformed = ritualsPerformed
            existing.manifestations = manifestations
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
                mood: mood,
                intentions: intentions,
                ritualsPerformed: ritualsPerformed,
                manifestations: manifestations,
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
