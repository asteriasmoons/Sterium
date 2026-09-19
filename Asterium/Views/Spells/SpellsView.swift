//
//  SpellsView.swift
//  Sterium
//

import SwiftUI
import SwiftData

struct SpellsView: View {
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    @State private var selectedCategory: SpellCategory?
    @State private var browseCategory: SpellCategory?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    AsteriumPageHeader(eyebrow: "ASTERIUM", title: "Spells")

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(SpellCategory.allCases) { category in
                            spellCategoryCard(category)
                        }
                    }
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
            .asteriumAdaptivePresentation(
                isPresented: Binding(
                    get: { selectedCategory != nil },
                    set: { if $0 == false { selectedCategory = nil } }
                )
            ) {
                if let selectedCategory {
                    SpellIntentionFlowView(category: selectedCategory)
                }
            }
            .navigationDestination(item: $browseCategory) { category in
                SpellCategorySavedListView(category: category)
            }
        }
    }

    private func spellCategoryCard(_ category: SpellCategory) -> some View {
        GlassCard(cornerRadius: 18, padding: 14) {
            VStack(alignment: .leading, spacing: 14) {
                Image(category.icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(LGradients.header)

                VStack(alignment: .leading, spacing: 4) {
                    Text(category.title)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    Text("\(category.intentions.count) intentions")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                }

                HStack(spacing: 8) {
                    Button {
                        selectedCategory = category
                    } label: {
                        Image("potionsparkle")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(LColors.bg)
                            .frame(width: 34, height: 34)
                            .background(LGradients.header, in: Circle())
                    }
                    .buttonStyle(.plain)

                    Button {
                        browseCategory = category
                    } label: {
                        HStack(spacing: 6) {
                            Image("openbook")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 13, height: 13)

                            Text("Browse")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                        }
                        .foregroundStyle(LGradients.header)
                        .padding(.horizontal, 10)
                        .frame(height: 34)
                        .background(LColors.glassSurface, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 158, alignment: .leading)
        }
    }
}

private struct SpellIntentionFlowView: View {
    let category: SpellCategory

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var selectedIntention: String?
    @State private var selectedLevel: PractitionerLevel = .beginner
    @State private var context = ""
    @State private var generatedSpell: SpellEntryResponse?
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var showingCustomSpellForm = false
    @FocusState private var contextFieldIsFocused: Bool

    private let service = SpellEngineService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    header

                    if selectedIntention == nil {
                        intentionGrid
                    } else {
                        generationForm
                    }

                    if let errorMessage {
                        statusCard(icon: "warnwavy", title: "Could not generate", message: errorMessage)
                    }

                    if let currentGeneratedSpell = generatedSpell {
                        NavigationLink {
                            SpellDetailView(spell: currentGeneratedSpell) { editedSpell in
                                service.replace(
                                    originalSpell: currentGeneratedSpell,
                                    with: editedSpell,
                                    category: category,
                                    modelContext: modelContext
                                )
                                generatedSpell = editedSpell
                            }
                        } label: {
                            spellRow(currentGeneratedSpell, icon: category.icon)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                service.delete(currentGeneratedSpell, category: category, modelContext: modelContext)
                                generatedSpell = nil
                            } label: {
                                Label("Delete Spell", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
            .dismissesKeyboardOnOutsideTap()
            .asteriumAdaptivePresentation(isPresented: $showingCustomSpellForm) {
                if let selectedIntention {
                    CustomSpellForm(
                        category: category,
                        intention: selectedIntention,
                        level: selectedLevel,
                        context: context
                    ) { spell in
                        service.saveCustom(spell, category: category, modelContext: modelContext)
                        generatedSpell = spell
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SPELLS")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)

                Text(category.title)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image("xmarkwavy")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(LGradients.header)
                    .frame(width: 42, height: 42)
                    .background(LColors.glassSurface, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 16)
    }

    private var intentionGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsteriumSectionHeader(title: "Choose Intention")

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ],
                spacing: 10
            ) {
                ForEach(category.intentions, id: \.self) { intention in
                    Button {
                        selectedIntention = intention
                    } label: {
                        GlassCard(cornerRadius: 16, padding: 12) {
                            HStack(spacing: 10) {
                                Image(category.icon)
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                    .foregroundStyle(LGradients.header)

                                Text(intention)
                                    .font(.system(size: 13, weight: .black, design: .rounded))
                                    .foregroundStyle(LColors.textPrimary)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.75)

                                Spacer(minLength: 0)
                            }
                            .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var generationForm: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("INTENTION")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundStyle(LGradients.header)

                        Text(selectedIntention ?? "")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                    }

                    Spacer()

                    Button {
                        selectedIntention = nil
                        generatedSpell = nil
                        errorMessage = nil
                    } label: {
                        Image("repeatfill")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(LGradients.header)
                    }
                    .buttonStyle(.plain)
                }

                levelPicker

                AsteriumPrimaryButton(title: "Add Spell Manually", asset: "addwavy") {
                    showingCustomSpellForm = true
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("CONTEXT & OUTCOME")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)

                    TextField(
                        "One or two sentences about the situation and what you want the spell to support.",
                        text: $context,
                        axis: .vertical
                    )
                    .lineLimit(3...5)
                    .focused($contextFieldIsFocused)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .padding(14)
                    .background(
                        LColors.glassSurface,
                        in: RoundedRectangle(cornerRadius: LSpacing.inputRadius)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: LSpacing.inputRadius)
                            .strokeBorder(LColors.glassBorder, lineWidth: 1)
                    }
                    .onChange(of: context) {
                        context = cappedContext(context)
                    }
                }

                AsteriumPrimaryButton(
                    title: isGenerating ? "Generating..." : "Generate Spell",
                    asset: isGenerating ? nil : "potionsparkle"
                ) {
                    contextFieldIsFocused = false
                    Task { await generateSpell() }
                }
                .disabled(isGenerating || selectedIntention == nil || context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(isGenerating ? 0.72 : 1)
            }
        }
    }

    private var levelPicker: some View {
        AsteriumPickerField(
            title: "Expertise",
            options: PractitionerLevel.allCases.map(\.title),
            selection: Binding(
                get: { selectedLevel.title },
                set: { newTitle in
                    selectedLevel = PractitionerLevel.allCases.first { $0.title == newTitle } ?? selectedLevel
                }
            ),
            leadingAsset: "levelup"
        )
    }

    private func generateSpell() async {
        guard let selectedIntention, isGenerating == false else { return }

        let trimmedContext = context.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedContext.isEmpty == false else { return }

        context = ""
        isGenerating = true
        errorMessage = nil

        do {
            generatedSpell = try await service.generate(
                category: category,
                intention: selectedIntention,
                level: selectedLevel,
                context: trimmedContext,
                modelContext: modelContext
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isGenerating = false
    }

    private func cappedContext(_ value: String) -> String {
        var sentences: [String] = []
        var current = ""

        for character in value {
            current.append(character)

            if ".!?".contains(character) {
                let trimmed = current.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty == false {
                    sentences.append(trimmed)
                }
                current = ""
            }
        }

        let remaining = current.trimmingCharacters(in: .whitespacesAndNewlines)
        if remaining.isEmpty == false {
            sentences.append(remaining)
        }

        guard sentences.count > 2 else { return value }

        return sentences.prefix(2).joined(separator: " ")
    }
}

private struct SpellCategorySavedListView: View {
    let category: SpellCategory

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var spells: [SpellEntryResponse] = []
    @State private var errorMessage: String?
    @State private var isLoading = false

    private let service = SpellEngineService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                header

                if let errorMessage {
                    statusCard(icon: "warnwavy", title: "Could not load", message: errorMessage)
                }

                if spells.isEmpty {
                    statusCard(
                        icon: category.icon,
                        title: isLoading ? "Loading spells..." : "No spells saved yet",
                        message: "Generated spells for this category will appear here."
                    )
                } else {
                    ForEach(spells) { spell in
                        NavigationLink {
                            SpellDetailView(spell: spell) { editedSpell in
                                service.replace(
                                    originalSpell: spell,
                                    with: editedSpell,
                                    category: category,
                                    modelContext: modelContext
                                )
                                spells = service.savedSpells(for: category, modelContext: modelContext)
                            }
                        } label: {
                            spellRow(spell, icon: category.icon)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                service.delete(spell, category: category, modelContext: modelContext)
                                spells = service.savedSpells(for: category, modelContext: modelContext)
                            } label: {
                                Label("Delete Spell", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, LSpacing.pageHorizontal)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background { AsteriumBackground() }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await loadSpells()
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SAVED SPELLS")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)

                Text(category.title)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image("xmarkwavy")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(LGradients.header)
                    .frame(width: 42, height: 42)
                    .background(LColors.glassSurface, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 16)
    }

    private func loadSpells() async {
        isLoading = true
        spells = service.savedSpells(for: category, modelContext: modelContext)
        errorMessage = nil
        isLoading = false
    }
}

private struct SpellDetailView: View {
    let onSave: (SpellEntryResponse) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var spell: SpellEntryResponse
    @State private var showingEditForm = false

    init(
        spell: SpellEntryResponse,
        onSave: @escaping (SpellEntryResponse) -> Void = { _ in }
    ) {
        self.onSave = onSave
        _spell = State(initialValue: spell)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                header

                textSection(title: "Focus", icon: "startarget", text: spell.focus)
                textSection(title: "Best Timing", icon: "clockwavy", text: spell.bestTiming)
                ingredientSection
                listSection(title: "Tools", icon: "wand", values: spell.tools)
                textSection(title: "Preparation", icon: "candleslit", text: spell.preparation)
                instructionSection
                textSection(title: "Affirmation", icon: "quote", text: spell.affirmation)
                textSection(title: "Visualization", icon: "eye", text: spell.visualization)
                textSection(title: "Closing", icon: "xmarkwavy", text: spell.closing)
                textSection(title: "Aftercare", icon: "seedling", text: spell.aftercare)
                textSection(title: "Duration", icon: "hourglassfill", text: spell.duration)
                textSection(title: "Notes", icon: "starnote", text: spell.notes)
            }
            .padding(.horizontal, LSpacing.pageHorizontal)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background { AsteriumBackground() }
        .toolbar(.hidden, for: .navigationBar)
        .asteriumAdaptivePresentation(isPresented: $showingEditForm) {
            CustomSpellForm(spell: spell) { editedSpell in
                spell = editedSpell
                onSave(editedSpell)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(spell.categoryTitle.uppercased())
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)

                Text(spell.title)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(spell.intention) • \(spell.level.capitalized)")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
            }

            Spacer()

            HStack(spacing: 10) {
                Button {
                    showingEditForm = true
                } label: {
                    Image("pencil")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(LGradients.header)
                        .frame(width: 42, height: 42)
                        .background(LColors.glassSurface, in: Circle())
                }
                .buttonStyle(.plain)

                Button {
                    dismiss()
                } label: {
                    Image("xmarkwavy")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(LGradients.header)
                        .frame(width: 42, height: 42)
                        .background(LColors.glassSurface, in: Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 16)
    }

    private var ingredientSection: some View {
        sectionContainer(title: "Ingredients", icon: "potion") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(spell.ingredients, id: \.self) { ingredient in
                    detailLine(title: ingredient.name, body: ingredient.purpose)
                }
            }
        }
    }

    private var instructionSection: some View {
        sectionContainer(title: "Instructions", icon: "listcircle") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(spell.instructions, id: \.self) { step in
                    detailLine(title: "Step \(step.step)", body: step.instruction)
                }
            }
        }
    }
}

private func spellRow(_ spell: SpellEntryResponse, icon: String) -> some View {
    GlassCard(cornerRadius: 16, padding: 14) {
        HStack(spacing: 12) {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(LGradients.header)

            VStack(alignment: .leading, spacing: 4) {
                Text(spell.title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .lineLimit(2)

                Text(spell.focus)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            Image("rightwavy")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(LGradients.header)
        }
    }
}

private func statusCard(icon: String, title: String, message: String) -> some View {
    GlassCard {
        HStack(alignment: .top, spacing: 12) {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundStyle(LGradients.header)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)

                Text(message)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CustomSpellForm: View {
    let onSave: (SpellEntryResponse) -> Void

    @Environment(\.dismiss) private var dismiss

    private let category: String
    private let categoryTitle: String
    private let intention: String
    private let originalCreatedAt: String?

    @State private var level: String
    @State private var context: String
    @State private var title: String
    @State private var focus: String
    @State private var bestTiming: String
    @State private var ingredients: [SpellIngredientDraft]
    @State private var tools: [String]
    @State private var preparation: String
    @State private var instructions: [String]
    @State private var affirmation: String
    @State private var visualization: String
    @State private var closing: String
    @State private var aftercare: String
    @State private var duration: String
    @State private var notes: String

    private let levelOptions = PractitionerLevel.allCases.map(\.title)

    init(
        category: SpellCategory,
        intention: String,
        level: PractitionerLevel,
        context: String,
        onSave: @escaping (SpellEntryResponse) -> Void
    ) {
        self.category = category.backendValue
        self.categoryTitle = category.title
        self.intention = intention
        self.originalCreatedAt = nil
        self.onSave = onSave

        _level = State(initialValue: level.title)
        _context = State(initialValue: context)
        _title = State(initialValue: "")
        _focus = State(initialValue: "")
        _bestTiming = State(initialValue: "")
        _ingredients = State(initialValue: [])
        _tools = State(initialValue: [])
        _preparation = State(initialValue: "")
        _instructions = State(initialValue: [])
        _affirmation = State(initialValue: "")
        _visualization = State(initialValue: "")
        _closing = State(initialValue: "")
        _aftercare = State(initialValue: "")
        _duration = State(initialValue: "")
        _notes = State(initialValue: "")
    }

    init(
        spell: SpellEntryResponse,
        onSave: @escaping (SpellEntryResponse) -> Void
    ) {
        self.category = spell.category
        self.categoryTitle = spell.categoryTitle
        self.intention = spell.intention
        self.originalCreatedAt = spell.createdAt
        self.onSave = onSave

        _level = State(initialValue: Self.levelTitle(from: spell.level))
        _context = State(initialValue: spell.context)
        _title = State(initialValue: spell.title)
        _focus = State(initialValue: spell.focus)
        _bestTiming = State(initialValue: spell.bestTiming)
        _ingredients = State(initialValue: spell.ingredients.map {
            SpellIngredientDraft(name: $0.name, purpose: $0.purpose)
        })
        _tools = State(initialValue: spell.tools)
        _preparation = State(initialValue: spell.preparation)
        _instructions = State(initialValue: spell.instructions.sorted { $0.step < $1.step }.map(\.instruction))
        _affirmation = State(initialValue: spell.affirmation)
        _visualization = State(initialValue: spell.visualization)
        _closing = State(initialValue: spell.closing)
        _aftercare = State(initialValue: spell.aftercare)
        _duration = State(initialValue: spell.duration)
        _notes = State(initialValue: spell.notes)
    }

    private var canSave: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    header

                    spellMetaCard

                    AsteriumPickerField(
                        title: "Expertise",
                        options: levelOptions,
                        selection: $level
                    )

                    AsteriumTextEditor(
                        title: "Context",
                        placeholder: "One or two sentences about the situation and desired outcome...",
                        text: $context,
                        minHeight: 100
                    )

                    AsteriumTextField(title: "Title", placeholder: "Spell title...", text: $title)
                    AsteriumTextEditor(title: "Focus", placeholder: "What this spell is designed to accomplish...", text: $focus)
                    AsteriumTextEditor(title: "Best Timing", placeholder: "Moon phase, day, hour, season, or time of day...", text: $bestTiming)
                    SpellIngredientInputField(items: $ingredients)
                    SpellStringListInputField(title: "Tools", placeholder: "Add a tool...", items: $tools)
                    AsteriumTextEditor(title: "Preparation", placeholder: "How to prepare before beginning...", text: $preparation)
                    SpellInstructionInputField(items: $instructions)
                    AsteriumTextEditor(title: "Affirmation", placeholder: "Affirmation, chant, invocation, or incantation...", text: $affirmation)
                    AsteriumTextEditor(title: "Visualization", placeholder: "What to imagine, feel, or focus on...", text: $visualization)
                    AsteriumTextEditor(title: "Closing", placeholder: "How to close or seal the spell...", text: $closing)
                    AsteriumTextEditor(title: "Aftercare", placeholder: "What to do with remaining ingredients or tools...", text: $aftercare)
                    AsteriumTextEditor(title: "Duration", placeholder: "Once, repeated, moon phase cycle, etc...", text: $duration)
                    AsteriumTextEditor(title: "Notes", placeholder: "Substitutions, enhancements, tips...", text: $notes)

                    AsteriumPrimaryButton(title: "Save Spell", asset: "addwavy") {
                        save()
                    }
                    .disabled(canSave == false)
                    .opacity(canSave ? 1 : 0.55)
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("CUSTOM SPELL")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)

                Text(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Add Spell" : title)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image("xmarkwavy")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(LGradients.header)
                    .frame(width: 42, height: 42)
                    .background(LColors.glassSurface, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 16)
    }

    private var spellMetaCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                detailLine(title: "Category", body: categoryTitle)
                detailLine(title: "Intention", body: intention)
            }
        }
    }

    private func save() {
        let now = ISO8601DateFormatter().string(from: Date())
        let spell = SpellEntryResponse(
            category: category,
            categoryTitle: categoryTitle,
            intention: intention,
            level: levelRawValue,
            context: context.trimmingCharacters(in: .whitespacesAndNewlines),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            focus: focus.trimmingCharacters(in: .whitespacesAndNewlines),
            bestTiming: bestTiming.trimmingCharacters(in: .whitespacesAndNewlines),
            ingredients: ingredients.map {
                SpellIngredient(name: $0.name, purpose: $0.purpose)
            },
            tools: tools,
            preparation: preparation.trimmingCharacters(in: .whitespacesAndNewlines),
            instructions: instructions.enumerated().map {
                SpellStep(step: $0.offset + 1, instruction: $0.element)
            },
            affirmation: affirmation.trimmingCharacters(in: .whitespacesAndNewlines),
            visualization: visualization.trimmingCharacters(in: .whitespacesAndNewlines),
            closing: closing.trimmingCharacters(in: .whitespacesAndNewlines),
            aftercare: aftercare.trimmingCharacters(in: .whitespacesAndNewlines),
            duration: duration.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            cached: true,
            source: "custom",
            createdAt: originalCreatedAt ?? now,
            updatedAt: now
        )

        onSave(spell)
        dismiss()
    }

    private var levelRawValue: String {
        PractitionerLevel.allCases.first { $0.title == level }?.rawValue ?? PractitionerLevel.beginner.rawValue
    }

    private static func levelTitle(from rawValue: String) -> String {
        PractitionerLevel(rawValue: rawValue)?.title ?? rawValue.capitalized
    }
}

private struct SpellIngredientDraft: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var purpose: String
}

private struct SpellIngredientInputField: View {
    @Binding var items: [SpellIngredientDraft]
    @State private var name = ""
    @State private var purpose = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            spellFieldLabel("Ingredients")

            VStack(alignment: .leading, spacing: 8) {
                ForEach(items) { item in
                    spellPairCard(title: item.name, body: item.purpose) {
                        items.removeAll { $0.id == item.id }
                    }
                }
            }

            VStack(spacing: 10) {
                spellShortInput(placeholder: "Ingredient", text: $name)
                HStack(spacing: 10) {
                    spellShortInput(placeholder: "Purpose...", text: $purpose)
                        .onSubmit(add)
                    spellAddButton(action: add)
                }
            }
        }
    }

    private func add() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPurpose = purpose.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.isEmpty == false || trimmedPurpose.isEmpty == false else { return }
        items.append(SpellIngredientDraft(name: trimmedName, purpose: trimmedPurpose))
        name = ""
        purpose = ""
    }
}

private struct SpellInstructionInputField: View {
    @Binding var items: [String]
    @State private var draft = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            spellFieldLabel("Instructions")

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    spellPairCard(title: "Step \(index + 1)", body: item) {
                        items.remove(at: index)
                    }
                }
            }

            HStack(spacing: 10) {
                spellShortInput(placeholder: "Add an instruction...", text: $draft)
                    .onSubmit(add)
                spellAddButton(action: add)
            }
        }
    }

    private func add() {
        let value = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.isEmpty == false else { return }
        items.append(value)
        draft = ""
    }
}

private struct SpellStringListInputField: View {
    let title: String
    let placeholder: String
    @Binding var items: [String]
    @State private var draft = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            spellFieldLabel(title)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    spellListRow(item) {
                        items.removeAll { $0 == item }
                    }
                }
            }

            HStack(spacing: 10) {
                spellShortInput(placeholder: placeholder, text: $draft)
                    .onSubmit(add)
                spellAddButton(action: add)
            }
        }
    }

    private func add() {
        let value = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.isEmpty == false else { return }
        items.append(value)
        draft = ""
    }
}

private func spellFieldLabel(_ title: String) -> some View {
    Text(title.uppercased())
        .font(.system(size: 13, weight: .black, design: .rounded))
        .foregroundStyle(LColors.textSecondary)
}

private func spellShortInput(placeholder: String, text: Binding<String>) -> some View {
    GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
        TextField(placeholder, text: text)
            .lineLimit(1)
            .submitLabel(.done)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(LColors.textPrimary)
            .padding(14)
    }
}

private func spellAddButton(action: @escaping () -> Void) -> some View {
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

private func spellListRow(_ title: String, onRemove: @escaping () -> Void) -> some View {
    GlassCard(cornerRadius: LSpacing.inputRadius, padding: 12) {
        HStack(alignment: .top, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Button(action: onRemove) {
                Image("xmarkwavy")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(LGradients.header)
            }
            .buttonStyle(.plain)
        }
    }
}

private func spellPairCard(title: String, body: String, onRemove: @escaping () -> Void) -> some View {
    GlassCard(cornerRadius: LSpacing.inputRadius, padding: 12) {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                if title.isEmpty == false {
                    Text(title)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(LGradients.header)
                }

                if body.isEmpty == false {
                    Text(body)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer()

            Button(action: onRemove) {
                Image("xmarkwavy")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(LGradients.header)
            }
            .buttonStyle(.plain)
        }
    }
}

private func listSection(title: String, icon: String, values: [String]) -> some View {
    sectionContainer(title: title, icon: icon) {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(values, id: \.self) { value in
                Text(value)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
            }
        }
    }
}

private func textSection(title: String, icon: String, text: String) -> some View {
    let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

    return sectionContainer(title: title, icon: icon) {
        Text(trimmedText.isEmpty ? "None" : trimmedText)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(LColors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private func sectionContainer<Content: View>(
    title: String,
    icon: String,
    @ViewBuilder content: () -> Content
) -> some View {
    GlassCard {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(LGradients.header)

                Text(title)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private func detailLine(title: String, body: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(title)
            .font(.system(size: 13, weight: .black, design: .rounded))
            .foregroundStyle(LGradients.header)

        Text(body)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(LColors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}
