//
//  ManifestationEntryForm.swift
//  Sterium
//

import SwiftUI
import SwiftData

struct ManifestationEntryForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existing: ManifestationEntry?

    @State private var title: String
    @State private var dateStarted: Date
    @State private var manifestationType: String
    @State private var customManifestationType: String
    @State private var methodSelections: Set<String>
    @State private var customManifestationMethod: String
    @State private var timeframe: String
    @State private var specificTimeframeDate: Date
    @State private var desire: String
    @State private var whyItMatters: String
    @State private var intentionItems: [String]
    @State private var desiredRealityItems: [String]
    @State private var inspiredActionItems: [String]
    @State private var obstacleItems: [String]
    @State private var manifestationStatusDisplay: String
    @State private var manifestedDate: Date
    @State private var outcome: String
    @State private var reflection: String

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    private static let typeOptions = [
        "Love & Relationships", "Career", "Finances", "Home",
        "Health & Wellness", "Creativity", "Personal Growth", "Spirituality",
        "Opportunity", "Confidence", "Travel", "Education", "Community",
        "Protection", "Release", "Custom"
    ]

    private static let methodOptions = [
        "Visualization", "Affirmation", "Scripting", "Candle Work", "Sigil Work",
        "Crystal Work", "Meditation", "Moon Work", "Petition", "Gratitude",
        "Vision Board", "Ritual", "Energy Work", "Repetition", "Custom"
    ]

    private static let timeframeOptions = [
        "No Deadline", "Days", "Weeks", "Months", "This Year", "Long-Term", "Specific Date"
    ]

    static let statusOptions = [
        "Started", "In-Progress", "Early Stages", "Manifested", "Released"
    ]

    init(existing: ManifestationEntry? = nil) {
        self.existing = existing

        let savedType = existing?.manifestationType ?? ""
        let savedCustomType = existing?.customManifestationType ?? ""
        var savedMethods = Set(existing?.manifestationMethods ?? [])
        let savedCustomMethod = existing?.customManifestationMethod ?? ""
        if !savedCustomMethod.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            savedMethods.insert("Custom")
        }

        _title = State(initialValue: existing?.title ?? "")
        _dateStarted = State(initialValue: existing?.dateStarted ?? .now)
        _manifestationType = State(initialValue: savedType.isEmpty && !savedCustomType.isEmpty ? "Custom" : savedType)
        _customManifestationType = State(initialValue: savedCustomType)
        _methodSelections = State(initialValue: savedMethods)
        _customManifestationMethod = State(initialValue: savedCustomMethod)
        _timeframe = State(initialValue: existing?.timeframe ?? "No Deadline")
        _specificTimeframeDate = State(initialValue: existing?.specificTimeframeDate ?? .now)
        _desire = State(initialValue: existing?.desire ?? "")
        _whyItMatters = State(initialValue: existing?.whyItMatters ?? "")
        _intentionItems = State(initialValue: Self.savedItems(existing?.intentionItems, legacyValue: existing?.intention))
        _desiredRealityItems = State(initialValue: Self.savedItems(existing?.desiredRealityItems, legacyValue: existing?.visualization))
        _inspiredActionItems = State(initialValue: Self.savedItems(existing?.inspiredActionItems, legacyValue: existing?.inspiredActions))
        _obstacleItems = State(initialValue: Self.savedItems(existing?.obstacleItems, legacyValue: existing?.obstacles))
        _manifestationStatusDisplay = State(initialValue: Self.statusDisplay(from: existing?.manifestationStatusRawValue))
        _manifestedDate = State(initialValue: existing?.manifestedDate ?? .now)
        _outcome = State(initialValue: existing?.outcome ?? "")
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

                    AsteriumPickerField(
                        title: "Type",
                        options: Self.typeOptions,
                        selection: $manifestationType,
                        maxDropdownHeight: 192
                    )

                    if manifestationType == "Custom" {
                        AsteriumTextField(
                            title: "Custom Type",
                            placeholder: "Custom manifestation type...",
                            text: $customManifestationType
                        )
                    }

                    AsteriumMultiSelectPickerField(
                        title: "Method",
                        options: Self.methodOptions,
                        selections: $methodSelections
                    )

                    if methodSelections.contains("Custom") {
                        AsteriumTextField(
                            title: "Custom Method",
                            placeholder: "Custom manifestation method...",
                            text: $customManifestationMethod
                        )
                    }

                    AsteriumPickerField(
                        title: "Timeframe",
                        options: Self.timeframeOptions,
                        selection: $timeframe
                    )

                    if timeframe == "Specific Date" {
                        AsteriumDateField(title: "Specific Date", date: $specificTimeframeDate)
                    }

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

                    ManifestationExpandableItemsField(
                        title: "Intentions",
                        placeholder: "Add an intention...",
                        listTitle: "Intentions",
                        items: $intentionItems
                    )

                    ManifestationExpandableItemsField(
                        title: "Desired Reality",
                        placeholder: "Add part of your desired reality...",
                        listTitle: "Desired Reality",
                        items: $desiredRealityItems
                    )

                    ManifestationExpandableItemsField(
                        title: "Inspired Actions",
                        placeholder: "Add an inspired action...",
                        listTitle: "Inspired Actions",
                        items: $inspiredActionItems
                    )

                    ManifestationExpandableItemsField(
                        title: "Obstacles",
                        placeholder: "Add an obstacle...",
                        listTitle: "Obstacles",
                        items: $obstacleItems
                    )

                    AsteriumPickerField(
                        title: "Status",
                        options: Self.statusOptions,
                        selection: $manifestationStatusDisplay
                    )

                    if manifestationStatusDisplay == "Manifested" {
                        AsteriumDateField(title: "Manifested Date", date: $manifestedDate)

                        AsteriumTextEditor(
                            title: "Outcome",
                            placeholder: "What really happened?",
                            text: $outcome,
                            minHeight: 110
                        )
                    }

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
        let orderedMethods = Self.methodOptions.filter { methodSelections.contains($0) }
        let selectedStatus = Self.status(from: manifestationStatusDisplay)
        let trimmedCustomType = manifestationType == "Custom"
            ? customManifestationType.trimmingCharacters(in: .whitespacesAndNewlines)
            : ""
        let trimmedCustomMethod = methodSelections.contains("Custom")
            ? customManifestationMethod.trimmingCharacters(in: .whitespacesAndNewlines)
            : ""

        if let existing {
            existing.title = title
            existing.dateStarted = dateStarted
            existing.manifestationType = manifestationType
            existing.customManifestationType = trimmedCustomType
            existing.manifestationMethods = orderedMethods
            existing.customManifestationMethod = trimmedCustomMethod
            existing.timeframe = timeframe
            existing.specificTimeframeDate = specificTimeframeDate
            existing.desire = desire
            existing.whyItMatters = whyItMatters
            existing.intention = intentionItems.joined(separator: "\n")
            existing.intentionItems = intentionItems
            existing.visualization = desiredRealityItems.joined(separator: "\n")
            existing.desiredRealityItems = desiredRealityItems
            existing.inspiredActions = inspiredActionItems.joined(separator: "\n")
            existing.inspiredActionItems = inspiredActionItems
            existing.obstacles = obstacleItems.joined(separator: "\n")
            existing.obstacleItems = obstacleItems
            existing.manifestationStatusRawValue = selectedStatus.rawValue
            existing.manifestedDate = manifestedDate
            existing.outcome = outcome
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
                manifestationType: manifestationType,
                customManifestationType: trimmedCustomType,
                manifestationMethods: orderedMethods,
                customManifestationMethod: trimmedCustomMethod,
                timeframe: timeframe,
                specificTimeframeDate: specificTimeframeDate,
                desire: desire,
                whyItMatters: whyItMatters,
                intention: intentionItems.joined(separator: "\n"),
                intentionItems: intentionItems,
                visualization: desiredRealityItems.joined(separator: "\n"),
                desiredRealityItems: desiredRealityItems,
                inspiredActions: inspiredActionItems.joined(separator: "\n"),
                inspiredActionItems: inspiredActionItems,
                obstacles: obstacleItems.joined(separator: "\n"),
                obstacleItems: obstacleItems,
                manifestationStatus: selectedStatus,
                manifestedDate: manifestedDate,
                outcome: outcome,
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

    private static func savedItems(_ items: [String]?, legacyValue: String?) -> [String] {
        if let items, !items.isEmpty {
            return items
        }

        guard let legacyValue else { return [] }
        let trimmed = legacyValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? [] : [trimmed]
    }

    private static func statusDisplay(from rawValue: String?) -> String {
        guard let rawValue, let status = ManifestationStatus(rawValue: rawValue) else {
            return "In-Progress"
        }

        return status == .notManifested ? "Released" : status.displayName
    }

    static func status(from displayName: String) -> ManifestationStatus {
        switch displayName {
        case "Started": return .started
        case "Early Stages": return .earlyStages
        case "Manifested": return .manifested
        case "Released": return .released
        default: return .inProgress
        }
    }
}

private struct ManifestationExpandableItemsField: View {
    let title: String
    let placeholder: String
    let listTitle: String
    @Binding var items: [String]
    @State private var draft = ""
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            manifestationFieldLabel(title)

            HStack(spacing: 10) {
                manifestationShortInput(placeholder, text: $draft)
                    .onSubmit(addItem)
                manifestationAddButton(action: addItem)
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

private func manifestationFieldLabel(_ title: String) -> some View {
    Text(title.uppercased())
        .font(.system(size: 13, weight: .black, design: .rounded))
        .foregroundStyle(LColors.textSecondary)
}

private func manifestationShortInput(_ placeholder: String, text: Binding<String>) -> some View {
    GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
        TextField(placeholder, text: text)
            .lineLimit(1)
            .submitLabel(.done)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(LColors.textPrimary)
            .padding(14)
    }
}

private func manifestationAddButton(action: @escaping () -> Void) -> some View {
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
