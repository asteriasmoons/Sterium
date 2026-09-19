//
//  PathworkEntryForm.swift
//  Sterium
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
    @State private var selectedPractices: Set<String>
    @State private var customPractices: [String]
    @State private var goals: [String]
    @State private var currentChallenges: [String]
    @State private var recentBreakthroughs: [String]
    @State private var studyingResources: [PathworkStudyResource]
    @State private var reflection: String
    @State private var nextSteps: [String]

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    @State private var editingResource: PathworkStudyResource?
    @State private var showingResourceForm = false

    private static let practiceOptions = [
        "Meditation", "Visualization", "Grounding", "Centering", "Energy Work",
        "Cleansing", "Protection", "Divination", "Moon Work", "Planetary Work",
        "Candle Magic", "Crystal Work", "Herbal Magic", "Sigil Work", "Prayer",
        "Devotion", "Ritual", "Spellwork", "Journaling", "Study", "Custom"
    ]

    init(existing: PathworkEntry? = nil) {
        self.existing = existing
        _chapterTitle = State(initialValue: existing?.chapterTitle ?? "")
        _started = State(initialValue: existing?.started ?? .now)
        _currentStatusDisplay = State(initialValue: (existing.flatMap { PathworkStatus(rawValue: $0.currentStatusRawValue) } ?? .exploring).displayName)
        _focusArea = State(initialValue: existing?.focusArea ?? "")
        _whyThisPath = State(initialValue: existing?.whyThisPath ?? "")

        let savedPractices = Self.practiceItems(from: existing?.currentPractices ?? "")
        let standardPractices = Set(Self.practiceOptions.dropLast())
        let customItems = savedPractices.filter { !standardPractices.contains($0) && $0 != "Custom" }
        var selected = Set(savedPractices.filter { standardPractices.contains($0) })
        if !customItems.isEmpty || savedPractices.contains("Custom") { selected.insert("Custom") }
        _selectedPractices = State(initialValue: selected)
        _customPractices = State(initialValue: customItems)

        _goals = State(initialValue: Self.listItems(from: existing?.goals ?? ""))
        _currentChallenges = State(initialValue: Self.listItems(from: existing?.currentChallenges ?? ""))
        _recentBreakthroughs = State(initialValue: Self.listItems(from: existing?.recentBreakthroughs ?? ""))
        _studyingResources = State(initialValue: existing?.studyingResources ?? [])
        _reflection = State(initialValue: existing?.reflection ?? "")
        let savedSteps = existing?.nextStepsList ?? []
        _nextSteps = State(initialValue: savedSteps.isEmpty ? Self.listItems(from: existing?.nextSteps ?? "") : savedSteps)
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
                    AsteriumMultiSelectPickerField(
                        title: "Current Practices",
                        options: Self.practiceOptions,
                        selections: $selectedPractices
                    )
                    if selectedPractices.contains("Custom") {
                        PathworkAddListField(
                            title: "Custom Practice",
                            placeholder: "Enter another practice...",
                            items: $customPractices
                        )
                    }
                    PathworkAddListField(title: "Goals", placeholder: "Add a goal...", items: $goals)
                    PathworkAddListField(
                        title: "Current Challenges",
                        placeholder: "Add a current challenge...",
                        items: $currentChallenges
                    )
                    PathworkAddListField(
                        title: "Recent Breakthroughs",
                        placeholder: "Add a recent breakthrough...",
                        items: $recentBreakthroughs
                    )
                    studyingResourcesField
                    AsteriumTextEditor(
                        title: "Reflection",
                        placeholder: "Reflect on your journey...",
                        text: $reflection
                    )
                    PathworkAddListField(
                        title: "Next Steps",
                        placeholder: "Add a next step...",
                        items: $nextSteps,
                        maximumItems: 9
                    )

                    GrimoireUniversalFields(
                        importance: $importance,
                        tags: $tags,
                        attachments: $attachments,
                        relatedEntries: $relatedEntries,
                        additionalNotes: $additionalNotes
                    )

                    AsteriumPrimaryButton(title: "Save Entry") { save() }
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 120)
            }
            .scrollDismissesKeyboard(.never)
            .grimoireFormBackground()
            .toolbar(.hidden, for: .navigationBar)
            .asteriumAdaptivePresentation(isPresented: $showingResourceForm) {
                PathworkStudyResourceForm(resource: editingResource) { resource in
                    if let index = studyingResources.firstIndex(where: { $0.id == resource.id }) {
                        studyingResources[index] = resource
                    } else {
                        studyingResources.append(resource)
                    }
                    editingResource = nil
                }
            }
            .onChange(of: showingResourceForm) { _, isShowing in
                if !isShowing { editingResource = nil }
            }
        }
        .presentationDetents([.large])
        .presentationContentInteraction(.scrolls)
    }

    private var studyingResourcesField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RESOURCES STUDYING")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(studyingResources) { resource in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(resource.name)
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .foregroundStyle(LColors.textPrimary)
                            }
                            Spacer()
                            Button {
                                editingResource = resource
                                showingResourceForm = true
                            } label: {
                                pathworkAsset("pencil", size: 17)
                            }
                            .buttonStyle(.plain)
                            Button {
                                studyingResources.removeAll { $0.id == resource.id }
                            } label: {
                                pathworkAsset("trash", size: 16)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                    }

                    Button {
                        editingResource = nil
                        showingResourceForm = true
                    } label: {
                        HStack(spacing: 10) {
                            Text("Add Studying Resource")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                            Spacer()
                            Image("addwavy")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 19, height: 19)
                        }
                        .foregroundStyle(LGradients.header)
                        .padding(14)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func save() {
        let standardPractices = Self.practiceOptions.dropLast().filter { selectedPractices.contains($0) }
        let savedPractices = standardPractices + (selectedPractices.contains("Custom") ? customPractices : [])
        let status = PathworkStatus.allCases.first { $0.displayName == currentStatusDisplay } ?? .exploring

        if let existing {
            existing.chapterTitle = chapterTitle
            existing.started = started
            existing.currentStatusRawValue = status.rawValue
            existing.focusArea = focusArea
            existing.whyThisPath = whyThisPath
            existing.currentPractices = savedPractices.joined(separator: " | ")
            existing.goals = goals.joined(separator: "\n")
            existing.currentChallenges = currentChallenges.joined(separator: "\n")
            existing.recentBreakthroughs = recentBreakthroughs.joined(separator: "\n")
            existing.studyingResources = studyingResources
            existing.reflection = reflection
            existing.nextStepsList = Array(nextSteps.prefix(9))
            existing.attachments = attachments
            existing.relatedEntries = relatedEntries
            existing.importance = importance
            existing.tags = tags
            existing.additionalNotes = additionalNotes
            existing.updatedAt = .now
        } else {
            let entry = PathworkEntry(
                chapterTitle: chapterTitle,
                started: started,
                currentStatus: status,
                focusArea: focusArea,
                whyThisPath: whyThisPath,
                currentPractices: savedPractices.joined(separator: " | "),
                goals: goals.joined(separator: "\n"),
                currentChallenges: currentChallenges.joined(separator: "\n"),
                recentBreakthroughs: recentBreakthroughs.joined(separator: "\n"),
                reflection: reflection,
                nextStepsList: Array(nextSteps.prefix(9)),
                importance: importance,
                tags: tags,
                attachments: attachments,
                relatedEntries: relatedEntries,
                additionalNotes: additionalNotes,
                createdAt: .now,
                updatedAt: .now
            )
            entry.studyingResources = studyingResources
            modelContext.insert(entry)
        }
        try? modelContext.save()
        dismiss()
    }

    private static func practiceItems(from value: String) -> [String] {
        value.split(separator: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private static func listItems(from value: String) -> [String] {
        value.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

private struct PathworkAddListField: View {
    let title: String
    let placeholder: String
    @Binding var items: [String]
    var maximumItems = 30
    var collapsible = false

    @State private var draft = ""
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            HStack(spacing: 10) {
                GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                    TextField(placeholder, text: $draft)
                        .submitLabel(.done)
                        .onSubmit(addItem)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                        .padding(14)
                }

                Button(action: addItem) {
                    Image("addwavy")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(LGradients.header)
                        .frame(width: 44, height: 44)
                        .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
                        .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(LColors.glassBorder, lineWidth: 1) }
                }
                .buttonStyle(.plain)
            }

            if !items.isEmpty {
                GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        if collapsible {
                            Button {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) { isExpanded.toggle() }
                            } label: {
                                HStack {
                                    Text(title)
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
                        }

                        if !collapsible || isExpanded {
                            ForEach(items.indices, id: \.self) { index in
                                HStack(spacing: 10) {
                                    Text(items[index])
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(LColors.textPrimary)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer(minLength: 0)
                                    Button { items.remove(at: index) } label: {
                                        pathworkAsset("xmarkwavy", size: 15)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 11)
                            }
                        }
                    }
                }
            }
        }
    }

    private func addItem() {
        let value = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, items.count < maximumItems else { return }
        items.append(value)
        draft = ""
    }
}

private struct PathworkStudyResourceForm: View {
    @Environment(\.dismiss) private var dismiss
    let existingID: UUID
    let onSave: (PathworkStudyResource) -> Void
    let preservedTypes: [String]

    @State private var name: String
    @State private var sources: [PathworkStudySource]
    @State private var learned: [String]

    init(resource: PathworkStudyResource?, onSave: @escaping (PathworkStudyResource) -> Void) {
        self.existingID = resource?.id ?? UUID()
        self.onSave = onSave
        self.preservedTypes = resource?.types ?? []
        _name = State(initialValue: resource?.name ?? "")
        _sources = State(initialValue: resource?.sources ?? [])
        _learned = State(initialValue: resource?.learned ?? [])
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    HStack {
                        AsteriumPageHeader(eyebrow: "PATHWORK", title: "Studying Resource")
                        Spacer()
                        Button { dismiss() } label: { pathworkAsset("xmarkwavy", size: 24) }.buttonStyle(.plain)
                    }

                    AsteriumTextField(title: "Resource Name", placeholder: "Resource name...", text: $name)
                    PathworkSourcesField(sources: $sources)
                    PathworkAddListField(
                        title: "Learned",
                        placeholder: "Add something you learned...",
                        items: $learned,
                        collapsible: true
                    )

                    AsteriumPrimaryButton(title: "Save Resource") {
                        onSave(PathworkStudyResource(
                            id: existingID,
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            types: preservedTypes,
                            sources: sources,
                            learned: learned
                        ))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)
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
}

private struct PathworkSourcesField: View {
    @Binding var sources: [PathworkStudySource]
    @State private var label = ""
    @State private var link = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SOURCES")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)
            AsteriumTextField(title: "Label", placeholder: "Source label...", text: $label)
            HStack(alignment: .bottom, spacing: 10) {
                AsteriumTextField(title: "Link", placeholder: "https://...", text: $link)
                Button(action: addSource) {
                    Image("addwavy")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(LGradients.header)
                        .frame(width: 44, height: 44)
                        .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
                        .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(LColors.glassBorder, lineWidth: 1) }
                }
                .buttonStyle(.plain)
            }

            ForEach(sources) { source in
                GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(source.label)
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                            Text(source.link)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(LColors.textSecondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Button { sources.removeAll { $0.id == source.id } } label: {
                            pathworkAsset("xmarkwavy", size: 15)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(14)
                }
            }
        }
    }

    private func addSource() {
        let cleanLabel = label.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanLink = link.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanLabel.isEmpty, !cleanLink.isEmpty else { return }
        sources.append(PathworkStudySource(label: cleanLabel, link: cleanLink))
        label = ""
        link = ""
    }
}

private func pathworkAsset(_ name: String, size: CGFloat) -> some View {
    Image(name)
        .renderingMode(.template)
        .resizable()
        .scaledToFit()
        .frame(width: size, height: size)
        .foregroundStyle(LGradients.header)
        .frame(width: 34, height: 34)
}
