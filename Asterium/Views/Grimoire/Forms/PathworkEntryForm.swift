
//
//  PathworkEntryForm.swift
//  Asterium
//

import SwiftUI
import SwiftData

struct PathworkEntryForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existing: PathworkEntry?

    @State private var chapterTitle: String
    @State private var started: Date
    @State private var currentStatusDisplay: String
    @State private var focusArea: String
    @State private var whyThisPath: String
    @State private var currentPractices: String
    @State private var goals: String
    @State private var currentChallenges: String
    @State private var recentBreakthroughs: String
    @State private var resourcesStudying: String
    @State private var reflection: String
    @State private var nextSteps: String

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    init(existing: PathworkEntry? = nil) {
        self.existing = existing
        _chapterTitle = State(initialValue: existing?.chapterTitle ?? "")
        _started = State(initialValue: existing?.started ?? .now)
        _currentStatusDisplay = State(initialValue: (existing.flatMap { PathworkStatus(rawValue: $0.currentStatusRawValue) } ?? .exploring).displayName)
        _focusArea = State(initialValue: existing?.focusArea ?? "")
        _whyThisPath = State(initialValue: existing?.whyThisPath ?? "")
        _currentPractices = State(initialValue: existing?.currentPractices ?? "")
        _goals = State(initialValue: existing?.goals ?? "")
        _currentChallenges = State(initialValue: existing?.currentChallenges ?? "")
        _recentBreakthroughs = State(initialValue: existing?.recentBreakthroughs ?? "")
        _resourcesStudying = State(initialValue: existing?.resourcesStudying ?? "")
        _reflection = State(initialValue: existing?.reflection ?? "")
        _nextSteps = State(initialValue: existing?.nextSteps ?? "")
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
                        Text("Pathwork")
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

                    AsteriumTextField(title: "Chapter Title", placeholder: "Title of this chapter...", text: $chapterTitle)

                    AsteriumDateField(title: "Started", date: $started)

                    AsteriumPickerField(
                        title: "Current Status",
                        options: PathworkStatus.allCases.map { $0.displayName },
                        selection: $currentStatusDisplay
                    )

                    AsteriumTextField(title: "Focus Area", placeholder: "Area of focus...", text: $focusArea)

                    AsteriumTextEditor(
                        title: "Why This Path",
                        placeholder: "Why did you choose this path?",
                        text: $whyThisPath
                    )

                    AsteriumTextEditor(
                        title: "Current Practices",
                        placeholder: "Your current practices...",
                        text: $currentPractices
                    )

                    AsteriumTextEditor(
                        title: "Goals",
                        placeholder: "What are your goals?",
                        text: $goals
                    )

                    AsteriumTextEditor(
                        title: "Current Challenges",
                        placeholder: "Challenges you face...",
                        text: $currentChallenges
                    )

                    AsteriumTextEditor(
                        title: "Recent Breakthroughs",
                        placeholder: "Any recent breakthroughs...",
                        text: $recentBreakthroughs
                    )

                    AsteriumTextEditor(
                        title: "Resources Studying",
                        placeholder: "Books, courses, teachers...",
                        text: $resourcesStudying
                    )

                    AsteriumTextEditor(
                        title: "Reflection",
                        placeholder: "Reflect on your journey...",
                        text: $reflection
                    )

                    AsteriumTextEditor(
                        title: "Next Steps",
                        placeholder: "What comes next?",
                        text: $nextSteps
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
            existing.chapterTitle = chapterTitle
            existing.started = started
            existing.currentStatusRawValue = (PathworkStatus.allCases.first { $0.displayName == currentStatusDisplay } ?? .exploring).rawValue
            existing.focusArea = focusArea
            existing.whyThisPath = whyThisPath
            existing.currentPractices = currentPractices
            existing.goals = goals
            existing.currentChallenges = currentChallenges
            existing.recentBreakthroughs = recentBreakthroughs
            existing.resourcesStudying = resourcesStudying
            existing.reflection = reflection
            existing.nextSteps = nextSteps
            existing.importance = importance
            existing.tags = tags
            existing.attachments = attachments
            existing.relatedEntries = relatedEntries
            existing.additionalNotes = additionalNotes
            existing.updatedAt = .now
        } else {
            let entry = PathworkEntry(
                chapterTitle: chapterTitle,
                started: started,
                currentStatus: PathworkStatus.allCases.first { $0.displayName == currentStatusDisplay } ?? .exploring,
                focusArea: focusArea,
                whyThisPath: whyThisPath,
                currentPractices: currentPractices,
                goals: goals,
                currentChallenges: currentChallenges,
                recentBreakthroughs: recentBreakthroughs,
                resourcesStudying: resourcesStudying,
                reflection: reflection,
                nextSteps: nextSteps,
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
