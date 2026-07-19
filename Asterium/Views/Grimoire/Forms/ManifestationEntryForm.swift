
//
//  ManifestationEntryForm.swift
//  Asterium
//

import SwiftUI
import SwiftData

struct ManifestationEntryForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existing: ManifestationEntry?

    @State private var title: String
    @State private var dateStarted: Date
    @State private var desire: String
    @State private var whyItMatters: String
    @State private var intention: String
    @State private var visualization: String
    @State private var inspiredActions: String
    @State private var obstacles: String
    @State private var evidenceOfProgress: String
    @State private var manifestationStatusDisplay: String
    @State private var reflection: String

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    init(existing: ManifestationEntry? = nil) {
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _dateStarted = State(initialValue: existing?.dateStarted ?? .now)
        _desire = State(initialValue: existing?.desire ?? "")
        _whyItMatters = State(initialValue: existing?.whyItMatters ?? "")
        _intention = State(initialValue: existing?.intention ?? "")
        _visualization = State(initialValue: existing?.visualization ?? "")
        _inspiredActions = State(initialValue: existing?.inspiredActions ?? "")
        _obstacles = State(initialValue: existing?.obstacles ?? "")
        _evidenceOfProgress = State(initialValue: existing?.evidenceOfProgress ?? "")
        _manifestationStatusDisplay = State(initialValue: (existing.flatMap { ManifestationStatus(rawValue: $0.manifestationStatusRawValue) } ?? .inProgress).displayName)
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
                        Text("Manifestation")
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

                    AsteriumTextField(title: "Title", placeholder: "Manifestation title...", text: $title)

                    AsteriumDateField(title: "Date Started", date: $dateStarted)

                    AsteriumTextEditor(
                        title: "Desire",
                        placeholder: "What do you want to manifest?",
                        text: $desire
                    )

                    AsteriumTextEditor(
                        title: "Why It Matters",
                        placeholder: "Why is this important to you?",
                        text: $whyItMatters
                    )

                    AsteriumTextEditor(
                        title: "Intention",
                        placeholder: "Your intention...",
                        text: $intention
                    )

                    AsteriumTextEditor(
                        title: "Visualization",
                        placeholder: "How do you visualize it?",
                        text: $visualization
                    )

                    AsteriumTextEditor(
                        title: "Inspired Actions",
                        placeholder: "Actions you are taking...",
                        text: $inspiredActions
                    )

                    AsteriumTextEditor(
                        title: "Obstacles",
                        placeholder: "What stands in the way?",
                        text: $obstacles
                    )

                    AsteriumTextEditor(
                        title: "Evidence of Progress",
                        placeholder: "Signs it is working...",
                        text: $evidenceOfProgress
                    )

                    AsteriumPickerField(
                        title: "Status",
                        options: ManifestationStatus.allCases.map { $0.displayName },
                        selection: $manifestationStatusDisplay
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
            existing.dateStarted = dateStarted
            existing.desire = desire
            existing.whyItMatters = whyItMatters
            existing.intention = intention
            existing.visualization = visualization
            existing.inspiredActions = inspiredActions
            existing.obstacles = obstacles
            existing.evidenceOfProgress = evidenceOfProgress
            existing.manifestationStatusRawValue = (ManifestationStatus.allCases.first { $0.displayName == manifestationStatusDisplay } ?? .inProgress).rawValue
            existing.reflection = reflection
            existing.importance = importance
            existing.tags = tags
            existing.attachments = attachments
            existing.relatedEntries = relatedEntries
            existing.additionalNotes = additionalNotes
            existing.updatedAt = .now
        } else {
            let entry = ManifestationEntry(
                title: title,
                dateStarted: dateStarted,
                desire: desire,
                whyItMatters: whyItMatters,
                intention: intention,
                visualization: visualization,
                inspiredActions: inspiredActions,
                obstacles: obstacles,
                evidenceOfProgress: evidenceOfProgress,
                manifestationStatus: ManifestationStatus.allCases.first { $0.displayName == manifestationStatusDisplay } ?? .inProgress,
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
