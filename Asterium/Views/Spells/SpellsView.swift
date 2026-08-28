//
//  SpellsView.swift
//  Asterium
//

import SwiftUI

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
    @State private var selectedIntention: String?
    @State private var selectedLevel: PractitionerLevel = .beginner
    @State private var context = ""
    @State private var generatedSpell: SpellEntryResponse?
    @State private var isGenerating = false
    @State private var errorMessage: String?

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

                    if let generatedSpell {
                        NavigationLink {
                            SpellDetailView(spell: generatedSpell)
                        } label: {
                            spellRow(generatedSpell, icon: category.icon)
                        }
                        .buttonStyle(.plain)
                    }
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
                        Image("repeat")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(LGradients.header)
                    }
                    .buttonStyle(.plain)
                }

                levelPicker

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
                    Task { await generateSpell() }
                }
                .disabled(isGenerating || selectedIntention == nil || context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(isGenerating ? 0.72 : 1)
            }
        }
    }

    private var levelPicker: some View {
        Menu {
            ForEach(PractitionerLevel.allCases) { level in
                Button(level.title) {
                    selectedLevel = level
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image("levelup")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(LGradients.header)

                VStack(alignment: .leading, spacing: 2) {
                    Text("EXPERTISE")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)

                    Text(selectedLevel.title)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                }

                Spacer()

                Image("chevdown")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(LGradients.header)
            }
            .padding(14)
            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.inputRadius))
            .overlay {
                RoundedRectangle(cornerRadius: LSpacing.inputRadius)
                    .strokeBorder(LColors.glassBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func generateSpell() async {
        guard let selectedIntention, isGenerating == false else { return }

        let trimmedContext = context.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedContext.isEmpty == false else { return }

        isGenerating = true
        errorMessage = nil

        do {
            generatedSpell = try await service.generate(
                category: category,
                intention: selectedIntention,
                level: selectedLevel,
                context: trimmedContext
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
                            SpellDetailView(spell: spell)
                        } label: {
                            spellRow(spell, icon: category.icon)
                        }
                        .buttonStyle(.plain)
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
        spells = service.savedSpells(for: category)

        do {
            spells = try await service.fetchSavedSpells(for: category)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

private struct SpellDetailView: View {
    let spell: SpellEntryResponse

    @Environment(\.dismiss) private var dismiss

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
