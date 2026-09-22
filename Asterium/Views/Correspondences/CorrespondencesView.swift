//
//  CorrespondencesView.swift
//  Sterium
//

import SwiftUI
import Foundation
import SwiftData

struct CorrespondencesView: View {
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    AsteriumPageHeader(
                        eyebrow: "ASTERIUM",
                        title: "Correspondences"
                    )

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(CorrespondenceType.allCases) { type in
                            NavigationLink {
                                CorrespondenceTypeSearchView(type: type)
                            } label: {
                                correspondenceTypeCard(type)
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
        }
    }

    private func correspondenceTypeCard(_ type: CorrespondenceType) -> some View {
        GlassCard(cornerRadius: 18, padding: 14) {
            VStack(alignment: .leading, spacing: 14) {
                Image(type.icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(LGradients.header)

                VStack(alignment: .leading, spacing: 4) {
                    Text(type.title)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    Text(type.singularTitle)
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
        }
    }
}

private struct CorrespondenceTypeSearchView: View {
    let type: CorrespondenceType

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var generatedEntry: CorrespondenceEntryResponse?
    @State private var savedEntries: [CorrespondenceEntryResponse] = []
    @State private var showingCustomEntryForm = false

    private let service = CorrespondenceEngineService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                pageHeader

                searchCard

                if let errorMessage {
                    statusCard(
                        icon: "warnwavy",
                        title: "Could not generate",
                        message: errorMessage
                    )
                }

                if let currentGeneratedEntry = generatedEntry {
                    VStack(alignment: .leading, spacing: 12) {
                        AsteriumSectionHeader(title: "Generated")
                        NavigationLink {
                            CorrespondenceEntryDetailView(
                                type: type,
                                entry: currentGeneratedEntry
                            ) { editedEntry in
                                service.saveCustom(editedEntry, type: type, modelContext: modelContext)
                                savedEntries = service.savedEntries(for: type, modelContext: modelContext)
                                generatedEntry = editedEntry.source == "custom" ? nil : editedEntry
                            }
                        } label: {
                            correspondenceEntryRow(currentGeneratedEntry)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteEntry(currentGeneratedEntry)
                            } label: {
                                Text("Delete Correspondence")
                            }
                        }
                    }
                }

                savedList
            }
            .padding(.horizontal, LSpacing.pageHorizontal)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background { AsteriumBackground() }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            savedEntries = service.savedEntries(for: type, modelContext: modelContext)
        }
        .asteriumAdaptivePresentation(isPresented: $showingCustomEntryForm) {
            CustomCorrespondenceEntryForm(type: type) { entry in
                service.saveCustom(entry, type: type, modelContext: modelContext)
                savedEntries = service.savedEntries(for: type, modelContext: modelContext)
                generatedEntry = nil
            }
        }
    }

    private var pageHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("CORRESPONDENCES")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)

                Text(type.title)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            HStack(spacing: 10) {
                Button {
                    showingCustomEntryForm = true
                } label: {
                    Image("addwavy")
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
            .padding(.top, 2)
        }
        .padding(.top, 16)
    }

    private var searchCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Search \(type.singularTitle)")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)

                HStack(spacing: 10) {
                    Image("searchwavy")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(LGradients.header)

                    TextField("Calendula", text: $searchText)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                        .submitLabel(.search)
                        .onSubmit {
                            Task { await generate() }
                        }
                }
                .padding(14)
                .background(
                    LColors.glassSurface,
                    in: RoundedRectangle(cornerRadius: LSpacing.inputRadius)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: LSpacing.inputRadius)
                        .strokeBorder(LColors.glassBorder, lineWidth: 1)
                }

                AsteriumPrimaryButton(
                    title: isLoading ? "Generating..." : "Generate Correspondence",
                    asset: isLoading ? nil : "sparklesearch"
                ) {
                    Task { await generate() }
                }
                .disabled(isLoading || searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(isLoading ? 0.72 : 1)
            }
        }
    }

    @ViewBuilder
    private var savedList: some View {
        if savedEntries.isEmpty {
            statusCard(
                icon: type.icon,
                title: "No saved \(type.title.lowercased()) yet",
                message: "Generated correspondences will save here automatically."
            )
        } else {
            VStack(alignment: .leading, spacing: 12) {
                AsteriumSectionHeader(title: "Saved")

                ForEach(savedEntries) { entry in
                    NavigationLink {
                        CorrespondenceEntryDetailView(type: type, entry: entry) { editedEntry in
                            service.saveCustom(editedEntry, type: type, modelContext: modelContext)
                            savedEntries = service.savedEntries(for: type, modelContext: modelContext)
                        }
                    } label: {
                        correspondenceEntryRow(entry)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            deleteEntry(entry)
                        } label: {
                            Text("Delete Correspondence")
                        }
                    }
                }
            }
        }
    }

    private func correspondenceEntryRow(
        _ entry: CorrespondenceEntryResponse
    ) -> some View {
        GlassCard(cornerRadius: 16, padding: 14) {
            HStack(spacing: 12) {
                Image(type.icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(LGradients.header)

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.name)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)

                    Text(entry.shortDescription)
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

    private func statusCard(
        icon: String,
        title: String,
        message: String
    ) -> some View {
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

    private func deleteEntry(_ entry: CorrespondenceEntryResponse) {
        service.delete(entry, type: type, modelContext: modelContext)
        savedEntries = service.savedEntries(for: type, modelContext: modelContext)

        if generatedEntry?.name.caseInsensitiveCompare(entry.name) == .orderedSame {
            generatedEntry = nil
        }
    }

    private func generate() async {
        let trimmedName = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.isEmpty == false, isLoading == false else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let entry = try await service.generate(type: type, name: trimmedName, modelContext: modelContext)
            generatedEntry = entry.source.caseInsensitiveCompare("custom") == .orderedSame ? nil : entry
            savedEntries = service.savedEntries(for: type, modelContext: modelContext)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

private struct CustomCorrespondenceEntryForm: View {
    let type: CorrespondenceType
    let onSave: (CorrespondenceEntryResponse) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var intentions: [String] = []
    @State private var purposes: [String] = []
    @State private var alternativeNames: [String] = []
    @State private var scientificName = ""
    @State private var shortDescription = ""
    @State private var planetaryCorrespondences: [String] = []
    @State private var zodiacCorrespondences: [String] = []
    @State private var elementalCorrespondences: [String] = []
    @State private var deities: [String] = []
    @State private var chakraAssociations: [CustomCorrespondencePair] = []
    @State private var numerology: [CustomCorrespondencePair] = []
    @State private var tarotAssociations: [CustomCorrespondencePair] = []
    @State private var sabbats: [String] = []
    @State private var lunarPhases: [CustomCorrespondencePair] = []
    @State private var seasons: [CustomCorrespondencePair] = []
    @State private var daysOfWeek: [CustomCorrespondencePair] = []
    @State private var colorCorrespondences: [CustomCorrespondencePair] = []
    @State private var symbols: [String] = []
    @State private var usesInSpellwork: [String] = []
    @State private var usesInRitual: [String] = []
    @State private var usage = ""
    @State private var divinationAssociations = ""
    @State private var spiritualMeanings: [String] = []
    @State private var historicalNotes = ""
    @State private var folklore = ""
    @State private var warnings = ""
    @State private var foods: [String] = []
    @State private var drinks: [String] = []
    @State private var waysToCelebrate: [String] = []
    @State private var ritualIdeas: [String] = []
    @State private var activities: [String] = []
    @State private var decorations: [String] = []
    @State private var altarIdeas: [String] = []
    @State private var herbsAndPlants: [String] = []
    @State private var crystalsAndStones: [String] = []
    @State private var incenseAndScents: [String] = []
    @State private var seasonalThemes: [String] = []
    @State private var botanicalFamily = ""
    @State private var partsUsed: [String] = []
    @State private var preparationMethods: [String] = []
    @State private var harvestingAndStorage = ""
    @State private var commonSubstitutions: [String] = []
    @State private var complementaryHerbs: [String] = []
    @State private var smokeAndIncenseUses: [String] = []
    @State private var bloomingSeason: [String] = []
    @State private var preservationMethods: [String] = []
    @State private var floralSymbolism: [String] = []
    @State private var traditionalGiftMeanings: [String] = []
    @State private var complementaryFlowers: [String] = []
    @State private var mineralFamily = ""
    @State private var composition = ""
    @State private var hardness = ""
    @State private var crystalSystem = ""
    @State private var commonColorsAndVarieties: [String] = []
    @State private var cleansingMethods: [String] = []
    @State private var chargingMethods: [String] = []
    @State private var sourcePlant = ""
    @State private var plantPartUsed = ""
    @State private var aromaProfile = ""
    @State private var blendingNotes = ""
    @State private var complementaryOils: [String] = []
    @State private var shadesAndVariations: [String] = []
    @State private var candleMagicUses: [String] = []
    @State private var visualizationUses: [String] = []
    @State private var planetaryDay = ""
    @State private var planetaryHour = ""
    @State private var traditionalMetal = ""
    @State private var associatedHerbs: [String] = []
    @State private var associatedCrystals: [String] = []
    @State private var magicalDomains: [String] = []
    @State private var modality = ""
    @State private var polarity = ""
    @State private var rulingPlanet = ""
    @State private var houseAssociation = ""
    @State private var symbolMeaning = ""
    @State private var energeticQualities: [String] = []
    @State private var strengthsAndWeaknesses: [String] = []
    @State private var energeticTheme = ""
    @State private var bestMagicalWork: [String] = []
    @State private var seasonalFoods: [String] = []
    @State private var seasonalDrinks: [String] = []
    @State private var seasonalPlants: [String] = []
    @State private var seasonalAnimals: [String] = []
    @State private var seasonalActivities: [String] = []
    @State private var magicalFocus: [String] = []
    @State private var associatedColors: [String] = []
    @State private var deityAssociations: [String] = []
    @State private var direction = ""
    @State private var qualities: [String] = []
    @State private var associatedTools: [String] = []
    @State private var associatedSpirits: [String] = []
    @State private var associatedWeather: [String] = []
    @State private var invocationMethods: [String] = []
    @State private var altarRepresentation = ""
    @State private var arcana = ""
    @State private var suit = ""
    @State private var numberOrRank = ""
    @State private var element = ""
    @State private var astrologicalAssociation = ""
    @State private var uprightMeaning = ""
    @State private var reversedMeaning = ""
    @State private var keywords: [String] = []
    @State private var imageryAndSymbolism = ""
    @State private var yesNoAssociation = ""
    @State private var timingAssociation = ""
    @State private var cultureTradition = ""
    @State private var pantheon = ""
    @State private var domains: [String] = []
    @State private var epithetsTitles: [String] = []
    @State private var sacredAnimals: [String] = []
    @State private var sacredPlants: [String] = []
    @State private var sacredPlaces: [String] = []
    @State private var offerings: [String] = []
    @State private var devotionalActs: [String] = []
    @State private var festivalsHolyDays: [String] = []
    @State private var mythsAndStories = ""
    @State private var historicalWorship = ""
    @State private var modernDevotionalPractices: [String] = []
    @State private var spiritType = ""
    @State private var culturalContext = ""
    @State private var domainsAssociations: [String] = []
    @State private var appearanceDescriptions = ""
    @State private var signsAndPresence: [String] = []
    @State private var communicationMethods: [String] = []
    @State private var relatedSpirits: [String] = []
    @State private var protectiveConsiderations = ""
    @State private var habitat = ""
    @State private var behavioralTraits: [String] = []
    @State private var symbolicTraits: [String] = []
    @State private var omensAndSigns: [String] = []
    @State private var dreamMeaning = ""
    @State private var encounterMeaning = ""
    @State private var associatedSeasons: [String] = []
    @State private var spiritGuideInterpretations = ""
    @State private var culturalSymbolism = ""
    @State private var toolType = ""
    @State private var traditionalPurpose = ""
    @State private var howToUse = ""
    @State private var preparation = ""
    @State private var cleansing = ""
    @State private var consecration = ""
    @State private var charging = ""
    @State private var storage = ""
    @State private var materials: [String] = []
    @State private var commonVariations: [String] = []
    @State private var substitutions: [String] = []
    @State private var ritualApplications: [String] = []
    @State private var spellworkApplications: [String] = []
    @State private var coreMeaning = ""
    @State private var positiveExpression = ""
    @State private var shadowExpression = ""
    @State private var repeatingNumberMeaning = ""
    @State private var synchronicityMeaning = ""
    @State private var manifestationAssociation = ""
    @State private var divinationMeaning = ""
    @State private var tarotConnections: [String] = []
    @State private var astrologicalConnections: [String] = []
    @State private var sacredGeometrySymbolism = ""
    @State private var culturalHistoricalMeanings: [String] = []

    init(
        type: CorrespondenceType,
        existing: CorrespondenceEntryResponse? = nil,
        onSave: @escaping (CorrespondenceEntryResponse) -> Void
    ) {
        self.type = type
        self.onSave = onSave

        _name = State(initialValue: existing?.name ?? "")
        _intentions = State(initialValue: existing?.intentions ?? [])
        _purposes = State(initialValue: existing?.purposes ?? [])
        _alternativeNames = State(initialValue: existing?.alternativeNames ?? [])
        _scientificName = State(initialValue: existing?.scientificName ?? "")
        _shortDescription = State(initialValue: existing?.shortDescription ?? "")
        _planetaryCorrespondences = State(initialValue: existing?.planetaryCorrespondences ?? [])
        _zodiacCorrespondences = State(initialValue: existing?.zodiacCorrespondences ?? [])
        _elementalCorrespondences = State(initialValue: existing?.elementalCorrespondences ?? [])
        _deities = State(initialValue: existing?.deities ?? [])
        _chakraAssociations = State(initialValue: existing?.chakraAssociations.map {
            CustomCorrespondencePair(label: $0.name, detail: $0.explanation)
        } ?? [])
        _numerology = State(initialValue: existing?.numerology.map {
            CustomCorrespondencePair(label: $0.number, detail: $0.significance)
        } ?? [])
        _tarotAssociations = State(initialValue: existing?.tarotAssociations.map {
            CustomCorrespondencePair(label: $0.card, detail: $0.explanation)
        } ?? [])
        _sabbats = State(initialValue: existing?.sabbats ?? [])
        _lunarPhases = State(initialValue: existing?.lunarPhases.map {
            CustomCorrespondencePair(label: $0.phase, detail: $0.explanation)
        } ?? [])
        _seasons = State(initialValue: existing?.seasons.map {
            CustomCorrespondencePair(label: $0.season, detail: $0.explanation)
        } ?? [])
        _daysOfWeek = State(initialValue: existing?.daysOfWeek.map {
            CustomCorrespondencePair(label: $0.day, detail: $0.explanation)
        } ?? [])
        _colorCorrespondences = State(initialValue: existing?.colorCorrespondences.map {
            CustomCorrespondencePair(label: $0.color, detail: $0.meaning)
        } ?? [])
        _symbols = State(initialValue: existing?.symbols ?? [])
        _usesInSpellwork = State(initialValue: existing?.usesInSpellwork ?? [])
        _usesInRitual = State(initialValue: Self.paragraphList(from: existing?.usesInRitual ?? ""))
        _usage = State(initialValue: existing?.usage ?? "")
        _divinationAssociations = State(initialValue: existing?.divinationAssociations ?? "")
        _spiritualMeanings = State(initialValue: existing?.spiritualMeanings ?? [])
        _historicalNotes = State(initialValue: existing?.historicalNotes ?? "")
        _folklore = State(initialValue: existing?.folklore ?? "")
        _warnings = State(initialValue: existing?.warnings ?? "")
        _foods = State(initialValue: existing?.foods ?? [])
        _drinks = State(initialValue: existing?.drinks ?? [])
        _waysToCelebrate = State(initialValue: existing?.waysToCelebrate ?? [])
        _ritualIdeas = State(initialValue: existing?.ritualIdeas ?? [])
        _activities = State(initialValue: existing?.activities ?? [])
        _decorations = State(initialValue: existing?.decorations ?? [])
        _altarIdeas = State(initialValue: existing?.altarIdeas ?? [])
        _herbsAndPlants = State(initialValue: existing?.herbsAndPlants ?? [])
        _crystalsAndStones = State(initialValue: existing?.crystalsAndStones ?? [])
        _incenseAndScents = State(initialValue: existing?.incenseAndScents ?? [])
        _seasonalThemes = State(initialValue: existing?.seasonalThemes ?? [])
        _botanicalFamily = State(initialValue: existing?.botanicalFamily ?? "")
        _partsUsed = State(initialValue: existing?.partsUsed ?? [])
        _preparationMethods = State(initialValue: existing?.preparationMethods ?? [])
        _harvestingAndStorage = State(initialValue: existing?.harvestingAndStorage ?? "")
        _commonSubstitutions = State(initialValue: existing?.commonSubstitutions ?? [])
        _complementaryHerbs = State(initialValue: existing?.complementaryHerbs ?? [])
        _smokeAndIncenseUses = State(initialValue: existing?.smokeAndIncenseUses ?? [])
        _bloomingSeason = State(initialValue: existing?.bloomingSeason ?? [])
        _preservationMethods = State(initialValue: existing?.preservationMethods ?? [])
        _floralSymbolism = State(initialValue: existing?.floralSymbolism ?? [])
        _traditionalGiftMeanings = State(initialValue: existing?.traditionalGiftMeanings ?? [])
        _complementaryFlowers = State(initialValue: existing?.complementaryFlowers ?? [])
        _mineralFamily = State(initialValue: existing?.mineralFamily ?? "")
        _composition = State(initialValue: existing?.composition ?? "")
        _hardness = State(initialValue: existing?.hardness ?? "")
        _crystalSystem = State(initialValue: existing?.crystalSystem ?? "")
        _commonColorsAndVarieties = State(initialValue: existing?.commonColorsAndVarieties ?? [])
        _cleansingMethods = State(initialValue: existing?.cleansingMethods ?? [])
        _chargingMethods = State(initialValue: existing?.chargingMethods ?? [])
        _sourcePlant = State(initialValue: existing?.sourcePlant ?? "")
        _plantPartUsed = State(initialValue: existing?.plantPartUsed ?? "")
        _aromaProfile = State(initialValue: existing?.aromaProfile ?? "")
        _blendingNotes = State(initialValue: existing?.blendingNotes ?? "")
        _complementaryOils = State(initialValue: existing?.complementaryOils ?? [])
        _shadesAndVariations = State(initialValue: existing?.shadesAndVariations ?? [])
        _candleMagicUses = State(initialValue: existing?.candleMagicUses ?? [])
        _visualizationUses = State(initialValue: existing?.visualizationUses ?? [])
        _planetaryDay = State(initialValue: existing?.planetaryDay ?? "")
        _planetaryHour = State(initialValue: existing?.planetaryHour ?? "")
        _traditionalMetal = State(initialValue: existing?.traditionalMetal ?? "")
        _associatedHerbs = State(initialValue: existing?.associatedHerbs ?? [])
        _associatedCrystals = State(initialValue: existing?.associatedCrystals ?? [])
        _magicalDomains = State(initialValue: existing?.magicalDomains ?? [])
        _modality = State(initialValue: existing?.modality ?? "")
        _polarity = State(initialValue: existing?.polarity ?? "")
        _rulingPlanet = State(initialValue: existing?.rulingPlanet ?? "")
        _houseAssociation = State(initialValue: existing?.houseAssociation ?? "")
        _symbolMeaning = State(initialValue: existing?.symbolMeaning ?? "")
        _energeticQualities = State(initialValue: existing?.energeticQualities ?? [])
        _strengthsAndWeaknesses = State(initialValue: existing?.strengthsAndWeaknesses ?? [])
        _energeticTheme = State(initialValue: existing?.energeticTheme ?? "")
        _bestMagicalWork = State(initialValue: existing?.bestMagicalWork ?? [])
        _seasonalFoods = State(initialValue: existing?.seasonalFoods ?? [])
        _seasonalDrinks = State(initialValue: existing?.seasonalDrinks ?? [])
        _seasonalPlants = State(initialValue: existing?.seasonalPlants ?? [])
        _seasonalAnimals = State(initialValue: existing?.seasonalAnimals ?? [])
        _seasonalActivities = State(initialValue: existing?.seasonalActivities ?? [])
        _magicalFocus = State(initialValue: existing?.magicalFocus ?? [])
        _associatedColors = State(initialValue: existing?.associatedColors ?? [])
        _deityAssociations = State(initialValue: existing?.deityAssociations ?? [])
        _direction = State(initialValue: existing?.direction ?? "")
        _qualities = State(initialValue: existing?.qualities ?? [])
        _associatedTools = State(initialValue: existing?.associatedTools ?? [])
        _associatedSpirits = State(initialValue: existing?.associatedSpirits ?? [])
        _associatedWeather = State(initialValue: existing?.associatedWeather ?? [])
        _invocationMethods = State(initialValue: existing?.invocationMethods ?? [])
        _altarRepresentation = State(initialValue: existing?.altarRepresentation ?? "")
        _arcana = State(initialValue: existing?.arcana ?? "")
        _suit = State(initialValue: existing?.suit ?? "")
        _numberOrRank = State(initialValue: existing?.numberOrRank ?? "")
        _element = State(initialValue: existing?.element ?? "")
        _astrologicalAssociation = State(initialValue: existing?.astrologicalAssociation ?? "")
        _uprightMeaning = State(initialValue: existing?.uprightMeaning ?? "")
        _reversedMeaning = State(initialValue: existing?.reversedMeaning ?? "")
        _keywords = State(initialValue: existing?.keywords ?? [])
        _imageryAndSymbolism = State(initialValue: existing?.imageryAndSymbolism ?? "")
        _yesNoAssociation = State(initialValue: existing?.yesNoAssociation ?? "")
        _timingAssociation = State(initialValue: existing?.timingAssociation ?? "")
        _cultureTradition = State(initialValue: existing?.cultureTradition ?? "")
        _pantheon = State(initialValue: existing?.pantheon ?? "")
        _domains = State(initialValue: existing?.domains ?? [])
        _epithetsTitles = State(initialValue: existing?.epithetsTitles ?? [])
        _sacredAnimals = State(initialValue: existing?.sacredAnimals ?? [])
        _sacredPlants = State(initialValue: existing?.sacredPlants ?? [])
        _sacredPlaces = State(initialValue: existing?.sacredPlaces ?? [])
        _offerings = State(initialValue: existing?.offerings ?? [])
        _devotionalActs = State(initialValue: existing?.devotionalActs ?? [])
        _festivalsHolyDays = State(initialValue: existing?.festivalsHolyDays ?? [])
        _mythsAndStories = State(initialValue: existing?.mythsAndStories ?? "")
        _historicalWorship = State(initialValue: existing?.historicalWorship ?? "")
        _modernDevotionalPractices = State(initialValue: existing?.modernDevotionalPractices ?? [])
        _spiritType = State(initialValue: existing?.spiritType ?? "")
        _culturalContext = State(initialValue: existing?.culturalContext ?? "")
        _domainsAssociations = State(initialValue: existing?.domainsAssociations ?? [])
        _appearanceDescriptions = State(initialValue: existing?.appearanceDescriptions ?? "")
        _signsAndPresence = State(initialValue: existing?.signsAndPresence ?? [])
        _communicationMethods = State(initialValue: existing?.communicationMethods ?? [])
        _relatedSpirits = State(initialValue: existing?.relatedSpirits ?? [])
        _protectiveConsiderations = State(initialValue: existing?.protectiveConsiderations ?? "")
        _habitat = State(initialValue: existing?.habitat ?? "")
        _behavioralTraits = State(initialValue: existing?.behavioralTraits ?? [])
        _symbolicTraits = State(initialValue: existing?.symbolicTraits ?? [])
        _omensAndSigns = State(initialValue: existing?.omensAndSigns ?? [])
        _dreamMeaning = State(initialValue: existing?.dreamMeaning ?? "")
        _encounterMeaning = State(initialValue: existing?.encounterMeaning ?? "")
        _associatedSeasons = State(initialValue: existing?.associatedSeasons ?? [])
        _spiritGuideInterpretations = State(initialValue: existing?.spiritGuideInterpretations ?? "")
        _culturalSymbolism = State(initialValue: existing?.culturalSymbolism ?? "")
        _toolType = State(initialValue: existing?.toolType ?? "")
        _traditionalPurpose = State(initialValue: existing?.traditionalPurpose ?? "")
        _howToUse = State(initialValue: existing?.howToUse ?? "")
        _preparation = State(initialValue: existing?.preparation ?? "")
        _cleansing = State(initialValue: existing?.cleansing ?? "")
        _consecration = State(initialValue: existing?.consecration ?? "")
        _charging = State(initialValue: existing?.charging ?? "")
        _storage = State(initialValue: existing?.storage ?? "")
        _materials = State(initialValue: existing?.materials ?? [])
        _commonVariations = State(initialValue: existing?.commonVariations ?? [])
        _substitutions = State(initialValue: existing?.substitutions ?? [])
        _ritualApplications = State(initialValue: existing?.ritualApplications ?? [])
        _spellworkApplications = State(initialValue: existing?.spellworkApplications ?? [])
        _coreMeaning = State(initialValue: existing?.coreMeaning ?? "")
        _positiveExpression = State(initialValue: existing?.positiveExpression ?? "")
        _shadowExpression = State(initialValue: existing?.shadowExpression ?? "")
        _repeatingNumberMeaning = State(initialValue: existing?.repeatingNumberMeaning ?? "")
        _synchronicityMeaning = State(initialValue: existing?.synchronicityMeaning ?? "")
        _manifestationAssociation = State(initialValue: existing?.manifestationAssociation ?? "")
        _divinationMeaning = State(initialValue: existing?.divinationMeaning ?? "")
        _tarotConnections = State(initialValue: existing?.tarotConnections ?? [])
        _astrologicalConnections = State(initialValue: existing?.astrologicalConnections ?? [])
        _sacredGeometrySymbolism = State(initialValue: existing?.sacredGeometrySymbolism ?? "")
        _culturalHistoricalMeanings = State(initialValue: existing?.culturalHistoricalMeanings ?? [])
    }

    private var canSave: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private static func paragraphList(from text: String) -> [String] {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedText.isEmpty == false else {
            return []
        }

        let lines = trimmedText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }

        return lines.isEmpty ? [trimmedText] : lines
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    header

                    AsteriumTextField(
                        title: "Name",
                        placeholder: "\(type.singularTitle) name...",
                        text: $name
                    )

                    AsteriumTextEditor(
                        title: "Short Description",
                        placeholder: "Briefly describe this correspondence...",
                        text: $shortDescription,
                        minHeight: 110
                    )

                    listFields

                    structuredFields

                    conditionalSpecificFields

                    longTextFields

                    AsteriumPrimaryButton(title: "Save Correspondence", asset: "addwavy") {
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
                Text("CUSTOM \(type.singularTitle.uppercased())")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)

                Text("Add Correspondence")
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

    private var listFields: some View {
        VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
            CustomPillInputField(title: "Intentions", placeholder: "Protection", items: $intentions)
            CustomDropdownListInputField(title: "Purposes", placeholder: "Add a purpose...", items: $purposes)
            CustomPillInputField(title: "Alternative Names", placeholder: "Common name", items: $alternativeNames)
            AsteriumTextField(title: "Scientific Name", placeholder: "Scientific or Latin name...", text: $scientificName)
            CustomPillInputField(title: "Planetary Correspondences", placeholder: "Moon", items: $planetaryCorrespondences)
            CustomPillInputField(title: "Zodiac Correspondences", placeholder: "Cancer", items: $zodiacCorrespondences)
            CustomPillInputField(title: "Elemental Correspondences", placeholder: "Water", items: $elementalCorrespondences)
            CustomPillInputField(title: "Deities Associated", placeholder: "Associated deity", items: $deities)
            CustomPillInputField(title: "Sabbats Associated", placeholder: "Beltane", items: $sabbats)
            CustomPillInputField(title: "Symbols Associated", placeholder: "Symbol", items: $symbols)
        }
    }

    private var structuredFields: some View {
        VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
            CustomPairListField(title: "Chakra Associations", labelPlaceholder: "Heart Chakra", detailPlaceholder: "Connection description...", items: $chakraAssociations)
            CustomNumerologyListField(items: $numerology)
            CustomPairListField(title: "Tarot Associations", labelPlaceholder: "The Star", detailPlaceholder: "Connection description...", items: $tarotAssociations)
            CustomPairListField(title: "Lunar Phase Associated", labelPlaceholder: "Full Moon", detailPlaceholder: "Connection description...", items: $lunarPhases)
            CustomPairListField(title: "Seasons of the Year", labelPlaceholder: "Spring", detailPlaceholder: "Connection description...", items: $seasons)
            CustomPairListField(title: "Days of the Week", labelPlaceholder: "Friday", detailPlaceholder: "Connection description...", items: $daysOfWeek)
            CustomPairListField(title: "Color Correspondences", labelPlaceholder: "Green", detailPlaceholder: "Meaning description...", items: $colorCorrespondences)
        }
    }

    @ViewBuilder
    private var conditionalSpecificFields: some View {
        switch type {
        case .herb: herbSpecificFields
        case .flower: flowerSpecificFields
        case .crystal: crystalSpecificFields
        case .essentialOil: essentialOilSpecificFields
        case .color: colorSpecificFields
        case .planet: planetSpecificFields
        case .zodiacSign: zodiacSignSpecificFields
        case .lunarPhase: lunarPhaseSpecificFields
        case .sabbat: sabbatSpecificFields
        case .season: seasonSpecificFields
        case .dayOfWeek: dayOfWeekSpecificFields
        case .element: elementSpecificFields
        case .tarotCard: tarotCardSpecificFields
        case .deity: deitySpecificFields
        case .spirit: spiritSpecificFields
        case .animal: animalSpecificFields
        case .tool: toolSpecificFields
        case .number: numberSpecificFields
        }
    }

    @ViewBuilder
    private var sabbatSpecificFields: some View {
        if type == .sabbat {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                CustomAddListField(title: "Foods", placeholder: "Add a food...", items: $foods)
                CustomAddListField(title: "Drinks", placeholder: "Add a drink...", items: $drinks)
                CustomAddListField(title: "Ways to Celebrate", placeholder: "Add a way to celebrate...", items: $waysToCelebrate)
                CustomAddListField(title: "Ritual Ideas", placeholder: "Add a ritual idea...", items: $ritualIdeas)
                CustomAddListField(title: "Activities", placeholder: "Add an activity...", items: $activities)
                CustomAddListField(title: "Decorations", placeholder: "Add a decoration...", items: $decorations)
                CustomAddListField(title: "Altar Ideas", placeholder: "Add an altar idea...", items: $altarIdeas)
                CustomAddListField(title: "Herbs & Plants", placeholder: "Add an herb or plant...", items: $herbsAndPlants)
                CustomAddListField(title: "Crystals & Stones", placeholder: "Add a crystal or stone...", items: $crystalsAndStones)
                CustomAddListField(title: "Incense & Scents", placeholder: "Add incense or a scent...", items: $incenseAndScents)
                CustomAddListField(title: "Seasonal Themes", placeholder: "Add a seasonal theme...", items: $seasonalThemes)
            }
        }
    }

    @ViewBuilder
    private var herbSpecificFields: some View {
        if type == .herb {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumTextField(title: "Botanical Family", placeholder: "Add botanical family...", text: $botanicalFamily)
                CustomAddListField(title: "Parts Used", placeholder: "Add a plant part...", items: $partsUsed)
                CustomAddListField(title: "Preparation Methods", placeholder: "Add a preparation method...", items: $preparationMethods)
                AsteriumTextEditor(title: "Harvesting & Storage", placeholder: "Add harvesting and storage information...", text: $harvestingAndStorage)
                CustomAddListField(title: "Common Substitutions", placeholder: "Add a substitute...", items: $commonSubstitutions)
                CustomAddListField(title: "Pairings / Complementary Herbs", placeholder: "Add a complementary herb...", items: $complementaryHerbs)
                CustomAddListField(title: "Smoke / Incense Uses", placeholder: "Add a smoke or incense use...", items: $smokeAndIncenseUses)
            }
        }
    }

    @ViewBuilder
    private var flowerSpecificFields: some View {
        if type == .flower {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumTextField(title: "Botanical Family", placeholder: "Add botanical family...", text: $botanicalFamily)
                CustomAddListField(title: "Blooming Season", placeholder: "Add a blooming season...", items: $bloomingSeason)
                CustomAddListField(title: "Parts Used", placeholder: "Add a flower or plant part...", items: $partsUsed)
                CustomAddListField(title: "Preservation Methods", placeholder: "Add a preservation method...", items: $preservationMethods)
                CustomAddListField(title: "Floral Symbolism", placeholder: "Add floral symbolism...", items: $floralSymbolism)
                CustomAddListField(title: "Traditional Gift Meanings", placeholder: "Add a gift meaning...", items: $traditionalGiftMeanings)
                CustomAddListField(title: "Pairings / Complementary Flowers", placeholder: "Add a complementary flower...", items: $complementaryFlowers)
                CustomAddListField(title: "Common Substitutions", placeholder: "Add a substitute...", items: $commonSubstitutions)
            }
        }
    }

    @ViewBuilder
    private var crystalSpecificFields: some View {
        if type == .crystal {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumTextField(title: "Mineral Family", placeholder: "Add mineral family...", text: $mineralFamily)
                AsteriumTextField(title: "Composition", placeholder: "Add composition...", text: $composition)
                AsteriumTextField(title: "Hardness", placeholder: "Add Mohs hardness or range...", text: $hardness)
                AsteriumTextField(title: "Crystal System", placeholder: "Add crystal system...", text: $crystalSystem)
                CustomAddListField(title: "Common Colors / Varieties", placeholder: "Add a color or variety...", items: $commonColorsAndVarieties)
                CustomAddListField(title: "Cleansing Methods", placeholder: "Add a cleansing method...", items: $cleansingMethods)
                CustomAddListField(title: "Charging Methods", placeholder: "Add a charging method...", items: $chargingMethods)
                CustomAddListField(title: "Common Substitutions", placeholder: "Add a substitute...", items: $commonSubstitutions)
            }
        }
    }

    @ViewBuilder
    private var essentialOilSpecificFields: some View {
        if type == .essentialOil {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumTextField(title: "Source Plant", placeholder: "Add source plant...", text: $sourcePlant)
                AsteriumTextField(title: "Plant Part Used", placeholder: "Add plant part used...", text: $plantPartUsed)
                AsteriumTextEditor(title: "Aroma Profile", placeholder: "Describe the aroma profile...", text: $aromaProfile)
                AsteriumTextEditor(title: "Blending Notes", placeholder: "Add blending notes...", text: $blendingNotes)
                CustomAddListField(title: "Complementary Oils", placeholder: "Add a complementary oil...", items: $complementaryOils)
                CustomAddListField(title: "Common Substitutions", placeholder: "Add a substitute...", items: $commonSubstitutions)
            }
        }
    }

    @ViewBuilder
    private var colorSpecificFields: some View {
        if type == .color {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                CustomAddListField(title: "Shades & Variations", placeholder: "Add a shade or variation...", items: $shadesAndVariations)
                CustomAddListField(title: "Candle Magic Uses", placeholder: "Add a candle magic use...", items: $candleMagicUses)
                CustomAddListField(title: "Visualization Uses", placeholder: "Add a visualization use...", items: $visualizationUses)
            }
        }
    }

    @ViewBuilder
    private var planetSpecificFields: some View {
        if type == .planet {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumTextField(title: "Planetary Day", placeholder: "Add planetary day...", text: $planetaryDay)
                AsteriumTextField(title: "Planetary Hour", placeholder: "Add planetary hour...", text: $planetaryHour)
                AsteriumTextField(title: "Traditional Metal", placeholder: "Add traditional metal...", text: $traditionalMetal)
                CustomAddListField(title: "Associated Herbs", placeholder: "Add associated herbs...", items: $associatedHerbs)
                CustomAddListField(title: "Associated Crystals", placeholder: "Add associated crystals...", items: $associatedCrystals)
                CustomAddListField(title: "Magical Domains", placeholder: "Add magical domains...", items: $magicalDomains)
            }
        }
    }

    @ViewBuilder
    private var zodiacSignSpecificFields: some View {
        if type == .zodiacSign {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumTextField(title: "Modality", placeholder: "Add modality...", text: $modality)
                AsteriumTextField(title: "Polarity", placeholder: "Add polarity...", text: $polarity)
                AsteriumTextField(title: "Ruling Planet", placeholder: "Add ruling planet...", text: $rulingPlanet)
                AsteriumTextField(title: "House Association", placeholder: "Add house association...", text: $houseAssociation)
                AsteriumTextEditor(title: "Symbol/Glyph Meaning", placeholder: "Add symbol/glyph meaning...", text: $symbolMeaning)
                CustomAddListField(title: "Personality/Energetic Qualities", placeholder: "Add personality/energetic qualities...", items: $energeticQualities)
                CustomAddListField(title: "Strengths/Weaknesses", placeholder: "Add strengths/weaknesses...", items: $strengthsAndWeaknesses)
                CustomAddListField(title: "Associated Herbs", placeholder: "Add associated herbs...", items: $associatedHerbs)
                CustomAddListField(title: "Associated Crystals", placeholder: "Add associated crystals...", items: $associatedCrystals)
            }
        }
    }

    @ViewBuilder
    private var lunarPhaseSpecificFields: some View {
        if type == .lunarPhase {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumTextField(title: "Energetic Theme", placeholder: "Add energetic theme...", text: $energeticTheme)
                CustomAddListField(title: "Best Magical Work", placeholder: "Add best magical work...", items: $bestMagicalWork)
                CustomAddListField(title: "Activities", placeholder: "Add activities...", items: $activities)
                CustomAddListField(title: "Herbs", placeholder: "Add herbs...", items: $associatedHerbs)
                CustomAddListField(title: "Crystals", placeholder: "Add crystals...", items: $associatedCrystals)
                CustomAddListField(title: "Altar Ideas", placeholder: "Add altar ideas...", items: $altarIdeas)
            }
        }
    }

    @ViewBuilder
    private var seasonSpecificFields: some View {
        if type == .season {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                CustomAddListField(title: "Seasonal Themes", placeholder: "Add seasonal themes...", items: $seasonalThemes)
                CustomAddListField(title: "Seasonal Foods", placeholder: "Add seasonal foods...", items: $seasonalFoods)
                CustomAddListField(title: "Seasonal Drinks", placeholder: "Add seasonal drinks...", items: $seasonalDrinks)
                CustomAddListField(title: "Seasonal Plants", placeholder: "Add seasonal plants...", items: $seasonalPlants)
                CustomAddListField(title: "Seasonal Animals", placeholder: "Add seasonal animals...", items: $seasonalAnimals)
                CustomAddListField(title: "Seasonal Activities", placeholder: "Add seasonal activities...", items: $seasonalActivities)
                CustomAddListField(title: "Altar Ideas", placeholder: "Add altar ideas...", items: $altarIdeas)
                CustomAddListField(title: "Decorations", placeholder: "Add decorations...", items: $decorations)
            }
        }
    }

    @ViewBuilder
    private var dayOfWeekSpecificFields: some View {
        if type == .dayOfWeek {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumTextField(title: "Ruling Planet", placeholder: "Add ruling planet...", text: $rulingPlanet)
                CustomAddListField(title: "Magical Focus", placeholder: "Add magical focus...", items: $magicalFocus)
                CustomAddListField(title: "Associated Herbs", placeholder: "Add associated herbs...", items: $associatedHerbs)
                CustomAddListField(title: "Associated Crystals", placeholder: "Add associated crystals...", items: $associatedCrystals)
                CustomAddListField(title: "Associated Colors", placeholder: "Add associated colors...", items: $associatedColors)
                CustomAddListField(title: "Deity Associations", placeholder: "Add deity associations...", items: $deityAssociations)
            }
        }
    }

    @ViewBuilder
    private var elementSpecificFields: some View {
        if type == .element {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumTextField(title: "Direction", placeholder: "Add direction...", text: $direction)
                CustomAddListField(title: "Qualities", placeholder: "Add qualities...", items: $qualities)
                CustomAddListField(title: "Magical Domains", placeholder: "Add magical domains...", items: $magicalDomains)
                CustomAddListField(title: "Associated Tools", placeholder: "Add associated tools...", items: $associatedTools)
                CustomAddListField(title: "Associated Herbs", placeholder: "Add associated herbs...", items: $associatedHerbs)
                CustomAddListField(title: "Associated Crystals", placeholder: "Add associated crystals...", items: $associatedCrystals)
                CustomAddListField(title: "Associated Spirits/Elementals", placeholder: "Add associated spirits/elementals...", items: $associatedSpirits)
                CustomAddListField(title: "Associated Weather", placeholder: "Add associated weather...", items: $associatedWeather)
                CustomAddListField(title: "Invocation Methods", placeholder: "Add invocation methods...", items: $invocationMethods)
                AsteriumTextEditor(title: "Altar Representation", placeholder: "Add altar representation...", text: $altarRepresentation)
            }
        }
    }

    @ViewBuilder
    private var tarotCardSpecificFields: some View {
        if type == .tarotCard {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumTextField(title: "Arcana", placeholder: "Add arcana...", text: $arcana)
                AsteriumTextField(title: "Suit", placeholder: "Add suit...", text: $suit)
                AsteriumTextField(title: "Number/Rank", placeholder: "Add number/rank...", text: $numberOrRank)
                AsteriumTextField(title: "Element", placeholder: "Add element...", text: $element)
                AsteriumTextField(title: "Astrological Association", placeholder: "Add astrological association...", text: $astrologicalAssociation)
                AsteriumTextEditor(title: "Upright Meaning", placeholder: "Add upright meaning...", text: $uprightMeaning)
                AsteriumTextEditor(title: "Reversed Meaning", placeholder: "Add reversed meaning...", text: $reversedMeaning)
                CustomAddListField(title: "Keywords", placeholder: "Add keywords...", items: $keywords)
                AsteriumTextEditor(title: "Imagery & Symbolism", placeholder: "Add imagery & symbolism...", text: $imageryAndSymbolism)
                AsteriumTextField(title: "Yes/No Association", placeholder: "Add yes/no association...", text: $yesNoAssociation)
                AsteriumTextField(title: "Timing Association", placeholder: "Add timing association...", text: $timingAssociation)
            }
        }
    }

    @ViewBuilder
    private var deitySpecificFields: some View {
        if type == .deity {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumTextField(title: "Culture/Tradition", placeholder: "Add culture/tradition...", text: $cultureTradition)
                AsteriumTextField(title: "Pantheon", placeholder: "Add pantheon...", text: $pantheon)
                CustomAddListField(title: "Domains", placeholder: "Add domains...", items: $domains)
                CustomAddListField(title: "Epithets/Titles", placeholder: "Add epithets/titles...", items: $epithetsTitles)
                CustomAddListField(title: "Sacred Animals", placeholder: "Add sacred animals...", items: $sacredAnimals)
                CustomAddListField(title: "Sacred Plants", placeholder: "Add sacred plants...", items: $sacredPlants)
                CustomAddListField(title: "Sacred Places", placeholder: "Add sacred places...", items: $sacredPlaces)
                CustomAddListField(title: "Offerings", placeholder: "Add offerings...", items: $offerings)
                CustomAddListField(title: "Devotional Acts", placeholder: "Add devotional acts...", items: $devotionalActs)
                CustomAddListField(title: "Altar Ideas", placeholder: "Add altar ideas...", items: $altarIdeas)
                CustomAddListField(title: "Festivals/Holy Days", placeholder: "Add festivals/holy days...", items: $festivalsHolyDays)
                AsteriumTextEditor(title: "Myths & Stories", placeholder: "Add myths & stories...", text: $mythsAndStories)
                AsteriumTextEditor(title: "Historical Worship", placeholder: "Add historical worship...", text: $historicalWorship)
                CustomAddListField(title: "Modern Devotional Practices", placeholder: "Add modern devotional practices...", items: $modernDevotionalPractices)
            }
        }
    }

    @ViewBuilder
    private var spiritSpecificFields: some View {
        if type == .spirit {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumTextField(title: "Spirit Type", placeholder: "Add spirit type...", text: $spiritType)
                AsteriumTextField(title: "Cultural/Traditional Context", placeholder: "Add cultural/traditional context...", text: $culturalContext)
                CustomAddListField(title: "Domains/Associations", placeholder: "Add domains/associations...", items: $domainsAssociations)
                AsteriumTextEditor(title: "Appearance/Descriptions", placeholder: "Add appearance/descriptions...", text: $appearanceDescriptions)
                CustomAddListField(title: "Signs & Presence", placeholder: "Add signs & presence...", items: $signsAndPresence)
                CustomAddListField(title: "Offerings", placeholder: "Add offerings...", items: $offerings)
                CustomAddListField(title: "Communication Methods", placeholder: "Add communication methods...", items: $communicationMethods)
                CustomAddListField(title: "Altar/Shrine Ideas", placeholder: "Add altar/shrine ideas...", items: $altarIdeas)
                CustomAddListField(title: "Related Spirits/Entities", placeholder: "Add related spirits/entities...", items: $relatedSpirits)
                AsteriumTextEditor(title: "Protective Considerations", placeholder: "Add protective considerations...", text: $protectiveConsiderations)
            }
        }
    }

    @ViewBuilder
    private var animalSpecificFields: some View {
        if type == .animal {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumTextField(title: "Habitat", placeholder: "Add habitat...", text: $habitat)
                CustomAddListField(title: "Behavioral Traits", placeholder: "Add behavioral traits...", items: $behavioralTraits)
                CustomAddListField(title: "Symbolic Traits", placeholder: "Add symbolic traits...", items: $symbolicTraits)
                CustomAddListField(title: "Omens & Signs", placeholder: "Add omens & signs...", items: $omensAndSigns)
                AsteriumTextEditor(title: "Dream Meaning", placeholder: "Add dream meaning...", text: $dreamMeaning)
                AsteriumTextEditor(title: "Encounter Meaning", placeholder: "Add encounter meaning...", text: $encounterMeaning)
                CustomAddListField(title: "Associated Seasons", placeholder: "Add associated seasons...", items: $associatedSeasons)
                AsteriumTextEditor(title: "Animal Spirit/Guide Interpretations", placeholder: "Add animal spirit/guide interpretations...", text: $spiritGuideInterpretations)
                AsteriumTextEditor(title: "Cultural Symbolism", placeholder: "Add cultural symbolism...", text: $culturalSymbolism)
            }
        }
    }

    @ViewBuilder
    private var toolSpecificFields: some View {
        if type == .tool {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumTextField(title: "Tool Type", placeholder: "Add tool type...", text: $toolType)
                AsteriumTextEditor(title: "Traditional Purpose", placeholder: "Add traditional purpose...", text: $traditionalPurpose)
                AsteriumTextEditor(title: "How to Use", placeholder: "Add how to use...", text: $howToUse)
                AsteriumTextEditor(title: "Preparation", placeholder: "Add preparation...", text: $preparation)
                AsteriumTextEditor(title: "Cleansing", placeholder: "Add cleansing...", text: $cleansing)
                AsteriumTextEditor(title: "Consecration", placeholder: "Add consecration...", text: $consecration)
                AsteriumTextEditor(title: "Charging", placeholder: "Add charging...", text: $charging)
                AsteriumTextEditor(title: "Storage", placeholder: "Add storage...", text: $storage)
                CustomAddListField(title: "Materials", placeholder: "Add materials...", items: $materials)
                CustomAddListField(title: "Common Variations", placeholder: "Add common variations...", items: $commonVariations)
                CustomAddListField(title: "Substitutions", placeholder: "Add substitutions...", items: $substitutions)
                CustomAddListField(title: "Ritual Applications", placeholder: "Add ritual applications...", items: $ritualApplications)
                CustomAddListField(title: "Spellwork Applications", placeholder: "Add spellwork applications...", items: $spellworkApplications)
            }
        }
    }

    @ViewBuilder
    private var numberSpecificFields: some View {
        if type == .number {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumTextEditor(title: "Core Meaning", placeholder: "Add core meaning...", text: $coreMeaning)
                AsteriumTextEditor(title: "Positive Expression", placeholder: "Add positive expression...", text: $positiveExpression)
                AsteriumTextEditor(title: "Shadow Expression", placeholder: "Add shadow expression...", text: $shadowExpression)
                AsteriumTextEditor(title: "Repeating Number Meaning", placeholder: "Add repeating number meaning...", text: $repeatingNumberMeaning)
                AsteriumTextEditor(title: "Synchronicity Meaning", placeholder: "Add synchronicity meaning...", text: $synchronicityMeaning)
                AsteriumTextEditor(title: "Manifestation Association", placeholder: "Add manifestation association...", text: $manifestationAssociation)
                AsteriumTextEditor(title: "Divination Meaning", placeholder: "Add divination meaning...", text: $divinationMeaning)
                CustomAddListField(title: "Tarot Connections", placeholder: "Add tarot connections...", items: $tarotConnections)
                CustomAddListField(title: "Astrological Connections", placeholder: "Add astrological connections...", items: $astrologicalConnections)
                AsteriumTextEditor(title: "Sacred Geometry/Symbolism", placeholder: "Add sacred geometry/symbolism...", text: $sacredGeometrySymbolism)
                CustomAddListField(title: "Cultural/Historical Meanings", placeholder: "Add cultural/historical meanings...", items: $culturalHistoricalMeanings)
            }
        }
    }

    private var longTextFields: some View {
        VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
            CustomAddListField(title: "Uses in Spellwork", placeholder: "Add a spellwork use...", items: $usesInSpellwork)
            CustomAddListField(title: "Uses in Ritual", placeholder: "Add a ritual use...", items: $usesInRitual)
            AsteriumTextEditor(title: "Usage of Item", placeholder: "How to prepare, store, handle, or work with it...", text: $usage)
            AsteriumTextEditor(title: "Divination Association", placeholder: "Divinatory symbolism or interpretation...", text: $divinationAssociations)
            CustomAddListField(title: "Spiritual Meanings", placeholder: "Add a spiritual meaning...", items: $spiritualMeanings)
            AsteriumTextEditor(title: "Historical Notes", placeholder: "Historical uses or cultural significance...", text: $historicalNotes)
            AsteriumTextEditor(title: "Folklore Tales", placeholder: "Myths, legends, or folklore...", text: $folklore)
            AsteriumTextEditor(title: "Warnings or Toxicity", placeholder: "Safety concerns, toxicity, contraindications...", text: $warnings)
        }
    }

    private func save() {
        let now = ISO8601DateFormatter().string(from: Date())
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        let entry = CorrespondenceEntryResponse(
            type: type.backendValue,
            name: trimmedName,
            intentions: intentions,
            purposes: purposes,
            alternativeNames: alternativeNames,
            scientificName: scientificName.trimmingCharacters(in: .whitespacesAndNewlines),
            shortDescription: shortDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            planetaryCorrespondences: planetaryCorrespondences,
            zodiacCorrespondences: zodiacCorrespondences,
            elementalCorrespondences: elementalCorrespondences,
            deities: deities,
            chakraAssociations: chakraAssociations.map { CorrespondenceExplanation(name: $0.label, explanation: $0.detail) },
            numerology: numerology.map { CorrespondenceNumerology(number: $0.label, significance: $0.detail) },
            tarotAssociations: tarotAssociations.map { CorrespondenceTarotAssociation(card: $0.label, explanation: $0.detail) },
            sabbats: sabbats,
            lunarPhases: lunarPhases.map { CorrespondenceLunarPhase(phase: $0.label, explanation: $0.detail) },
            seasons: seasons.map { CorrespondenceSeason(season: $0.label, explanation: $0.detail) },
            daysOfWeek: daysOfWeek.map { CorrespondenceDayOfWeek(day: $0.label, explanation: $0.detail) },
            colorCorrespondences: colorCorrespondences.map { CorrespondenceColor(color: $0.label, meaning: $0.detail) },
            symbols: symbols,
            usesInSpellwork: usesInSpellwork,
            usesInRitual: usesInRitual.joined(separator: "\n"),
            usage: usage.trimmingCharacters(in: .whitespacesAndNewlines),
            divinationAssociations: divinationAssociations.trimmingCharacters(in: .whitespacesAndNewlines),
            spiritualMeanings: spiritualMeanings,
            historicalNotes: historicalNotes.trimmingCharacters(in: .whitespacesAndNewlines),
            folklore: folklore.trimmingCharacters(in: .whitespacesAndNewlines),
            warnings: warnings.trimmingCharacters(in: .whitespacesAndNewlines),
            foods: type == .sabbat ? foods : nil,
            drinks: type == .sabbat ? drinks : nil,
            waysToCelebrate: type == .sabbat ? waysToCelebrate : nil,
            ritualIdeas: type == .sabbat ? ritualIdeas : nil,
            activities: (type == .sabbat || type == .lunarPhase) ? activities : nil,
            decorations: (type == .sabbat || type == .season) ? decorations : nil,
            altarIdeas: (type == .sabbat || type == .lunarPhase || type == .season || type == .deity || type == .spirit) ? altarIdeas : nil,
            herbsAndPlants: type == .sabbat ? herbsAndPlants : nil,
            crystalsAndStones: type == .sabbat ? crystalsAndStones : nil,
            incenseAndScents: type == .sabbat ? incenseAndScents : nil,
            seasonalThemes: (type == .sabbat || type == .season) ? seasonalThemes : nil,
            botanicalFamily: (type == .herb || type == .flower) ? botanicalFamily.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            partsUsed: (type == .herb || type == .flower) ? partsUsed : nil,
            preparationMethods: type == .herb ? preparationMethods : nil,
            harvestingAndStorage: type == .herb ? harvestingAndStorage.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            commonSubstitutions: (type == .herb || type == .flower || type == .crystal || type == .essentialOil) ? commonSubstitutions : nil,
            complementaryHerbs: type == .herb ? complementaryHerbs : nil,
            smokeAndIncenseUses: type == .herb ? smokeAndIncenseUses : nil,
            bloomingSeason: type == .flower ? bloomingSeason : nil,
            preservationMethods: type == .flower ? preservationMethods : nil,
            floralSymbolism: type == .flower ? floralSymbolism : nil,
            traditionalGiftMeanings: type == .flower ? traditionalGiftMeanings : nil,
            complementaryFlowers: type == .flower ? complementaryFlowers : nil,
            mineralFamily: type == .crystal ? mineralFamily.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            composition: type == .crystal ? composition.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            hardness: type == .crystal ? hardness.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            crystalSystem: type == .crystal ? crystalSystem.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            commonColorsAndVarieties: type == .crystal ? commonColorsAndVarieties : nil,
            cleansingMethods: type == .crystal ? cleansingMethods : nil,
            chargingMethods: type == .crystal ? chargingMethods : nil,
            sourcePlant: type == .essentialOil ? sourcePlant.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            plantPartUsed: type == .essentialOil ? plantPartUsed.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            aromaProfile: type == .essentialOil ? aromaProfile.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            blendingNotes: type == .essentialOil ? blendingNotes.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            complementaryOils: type == .essentialOil ? complementaryOils : nil,
            shadesAndVariations: type == .color ? shadesAndVariations : nil,
            candleMagicUses: type == .color ? candleMagicUses : nil,
            visualizationUses: type == .color ? visualizationUses : nil,
            planetaryDay: type == .planet ? planetaryDay.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            planetaryHour: type == .planet ? planetaryHour.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            traditionalMetal: type == .planet ? traditionalMetal.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            associatedHerbs: (type == .planet || type == .zodiacSign || type == .lunarPhase || type == .dayOfWeek || type == .element) ? associatedHerbs : nil,
            associatedCrystals: (type == .planet || type == .zodiacSign || type == .lunarPhase || type == .dayOfWeek || type == .element) ? associatedCrystals : nil,
            magicalDomains: (type == .planet || type == .element) ? magicalDomains : nil,
            modality: type == .zodiacSign ? modality.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            polarity: type == .zodiacSign ? polarity.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            rulingPlanet: (type == .zodiacSign || type == .dayOfWeek) ? rulingPlanet.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            houseAssociation: type == .zodiacSign ? houseAssociation.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            symbolMeaning: type == .zodiacSign ? symbolMeaning.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            energeticQualities: type == .zodiacSign ? energeticQualities : nil,
            strengthsAndWeaknesses: type == .zodiacSign ? strengthsAndWeaknesses : nil,
            energeticTheme: type == .lunarPhase ? energeticTheme.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            bestMagicalWork: type == .lunarPhase ? bestMagicalWork : nil,
            seasonalFoods: type == .season ? seasonalFoods : nil,
            seasonalDrinks: type == .season ? seasonalDrinks : nil,
            seasonalPlants: type == .season ? seasonalPlants : nil,
            seasonalAnimals: type == .season ? seasonalAnimals : nil,
            seasonalActivities: type == .season ? seasonalActivities : nil,
            magicalFocus: type == .dayOfWeek ? magicalFocus : nil,
            associatedColors: type == .dayOfWeek ? associatedColors : nil,
            deityAssociations: type == .dayOfWeek ? deityAssociations : nil,
            direction: type == .element ? direction.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            qualities: type == .element ? qualities : nil,
            associatedTools: type == .element ? associatedTools : nil,
            associatedSpirits: type == .element ? associatedSpirits : nil,
            associatedWeather: type == .element ? associatedWeather : nil,
            invocationMethods: type == .element ? invocationMethods : nil,
            altarRepresentation: type == .element ? altarRepresentation.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            arcana: type == .tarotCard ? arcana.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            suit: type == .tarotCard ? suit.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            numberOrRank: type == .tarotCard ? numberOrRank.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            element: type == .tarotCard ? element.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            astrologicalAssociation: type == .tarotCard ? astrologicalAssociation.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            uprightMeaning: type == .tarotCard ? uprightMeaning.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            reversedMeaning: type == .tarotCard ? reversedMeaning.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            keywords: type == .tarotCard ? keywords : nil,
            imageryAndSymbolism: type == .tarotCard ? imageryAndSymbolism.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            yesNoAssociation: type == .tarotCard ? yesNoAssociation.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            timingAssociation: type == .tarotCard ? timingAssociation.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            cultureTradition: type == .deity ? cultureTradition.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            pantheon: type == .deity ? pantheon.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            domains: type == .deity ? domains : nil,
            epithetsTitles: type == .deity ? epithetsTitles : nil,
            sacredAnimals: type == .deity ? sacredAnimals : nil,
            sacredPlants: type == .deity ? sacredPlants : nil,
            sacredPlaces: type == .deity ? sacredPlaces : nil,
            offerings: (type == .deity || type == .spirit) ? offerings : nil,
            devotionalActs: type == .deity ? devotionalActs : nil,
            festivalsHolyDays: type == .deity ? festivalsHolyDays : nil,
            mythsAndStories: type == .deity ? mythsAndStories.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            historicalWorship: type == .deity ? historicalWorship.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            modernDevotionalPractices: type == .deity ? modernDevotionalPractices : nil,
            spiritType: type == .spirit ? spiritType.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            culturalContext: type == .spirit ? culturalContext.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            domainsAssociations: type == .spirit ? domainsAssociations : nil,
            appearanceDescriptions: type == .spirit ? appearanceDescriptions.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            signsAndPresence: type == .spirit ? signsAndPresence : nil,
            communicationMethods: type == .spirit ? communicationMethods : nil,
            relatedSpirits: type == .spirit ? relatedSpirits : nil,
            protectiveConsiderations: type == .spirit ? protectiveConsiderations.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            habitat: type == .animal ? habitat.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            behavioralTraits: type == .animal ? behavioralTraits : nil,
            symbolicTraits: type == .animal ? symbolicTraits : nil,
            omensAndSigns: type == .animal ? omensAndSigns : nil,
            dreamMeaning: type == .animal ? dreamMeaning.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            encounterMeaning: type == .animal ? encounterMeaning.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            associatedSeasons: type == .animal ? associatedSeasons : nil,
            spiritGuideInterpretations: type == .animal ? spiritGuideInterpretations.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            culturalSymbolism: type == .animal ? culturalSymbolism.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            toolType: type == .tool ? toolType.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            traditionalPurpose: type == .tool ? traditionalPurpose.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            howToUse: type == .tool ? howToUse.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            preparation: type == .tool ? preparation.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            cleansing: type == .tool ? cleansing.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            consecration: type == .tool ? consecration.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            charging: type == .tool ? charging.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            storage: type == .tool ? storage.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            materials: type == .tool ? materials : nil,
            commonVariations: type == .tool ? commonVariations : nil,
            substitutions: type == .tool ? substitutions : nil,
            ritualApplications: type == .tool ? ritualApplications : nil,
            spellworkApplications: type == .tool ? spellworkApplications : nil,
            coreMeaning: type == .number ? coreMeaning.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            positiveExpression: type == .number ? positiveExpression.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            shadowExpression: type == .number ? shadowExpression.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            repeatingNumberMeaning: type == .number ? repeatingNumberMeaning.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            synchronicityMeaning: type == .number ? synchronicityMeaning.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            manifestationAssociation: type == .number ? manifestationAssociation.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            divinationMeaning: type == .number ? divinationMeaning.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            tarotConnections: type == .number ? tarotConnections : nil,
            astrologicalConnections: type == .number ? astrologicalConnections : nil,
            sacredGeometrySymbolism: type == .number ? sacredGeometrySymbolism.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            culturalHistoricalMeanings: type == .number ? culturalHistoricalMeanings : nil,
            cached: true,
            source: "custom",
            createdAt: now,
            updatedAt: now
        )

        onSave(entry)
        dismiss()
    }
}

private struct CustomCorrespondencePair: Identifiable, Equatable {
    let id = UUID()
    var label: String
    var detail: String
}

private struct CustomPillInputField: View {
    let title: String
    let placeholder: String
    @Binding var items: [String]
    @State private var draft = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            customFieldLabel(title)

            if items.isEmpty == false {
                CorrespondenceFlowLayout(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        removablePill(item) {
                            items.removeAll { $0 == item }
                        }
                    }
                }
            }

            shortInput(placeholder: placeholder, text: $draft)
                .onSubmit(addDraft)
        }
    }

    private func addDraft() {
        let value = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.isEmpty == false else { return }
        if items.contains(where: { $0.caseInsensitiveCompare(value) == .orderedSame }) == false {
            items.append(value)
        }
        draft = ""
    }
}

private struct CustomDropdownListInputField: View {
    let title: String
    let placeholder: String
    @Binding var items: [String]
    @State private var draft = ""
    @State private var isExpanded = false

    private var displayText: String {
        items.isEmpty ? "No items yet" : "\(items.count) item\(items.count == 1 ? "" : "s")"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            customFieldLabel(title)

            shortInput(placeholder: placeholder, text: $draft)
                .onSubmit(addDraft)

            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                    isExpanded.toggle()
                }
            } label: {
                GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                    HStack {
                        Text(displayText)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(items.isEmpty ? LColors.textSecondary : LColors.textPrimary)

                        Spacer()

                        Image(isExpanded ? "chevup" : "chevdown")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(LGradients.header)
                    }
                    .padding(14)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                GlassCard(cornerRadius: LSpacing.inputRadius, padding: 8) {
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            if items.isEmpty {
                                Text("Add items above")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(LColors.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                            } else {
                                ForEach(items, id: \.self) { item in
                                    removableDropdownRow(item) {
                                        items.removeAll { $0 == item }
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 240)
                    .scrollIndicators(.visible)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
            }
        }
    }

    private func addDraft() {
        let value = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.isEmpty == false else { return }
        if items.contains(where: { $0.caseInsensitiveCompare(value) == .orderedSame }) == false {
            items.append(value)
        }
        draft = ""
        withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
            isExpanded = true
        }
    }
}

private struct CustomPairListField: View {
    let title: String
    let labelPlaceholder: String
    let detailPlaceholder: String
    @Binding var items: [CustomCorrespondencePair]
    @State private var labelDraft = ""
    @State private var detailDraft = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            customFieldLabel(title)

            pairList

            VStack(spacing: 10) {
                shortInput(placeholder: labelPlaceholder, text: $labelDraft)
                HStack(spacing: 10) {
                    shortInput(placeholder: detailPlaceholder, text: $detailDraft)
                        .onSubmit(addPair)

                    addButton(action: addPair)
                }
            }
        }
    }

    private var pairList: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items) { item in
                pairCard(item) {
                    items.removeAll { $0.id == item.id }
                }
            }
        }
    }

    private func addPair() {
        let label = labelDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        let detail = detailDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard label.isEmpty == false || detail.isEmpty == false else { return }
        items.append(CustomCorrespondencePair(label: label, detail: detail))
        labelDraft = ""
        detailDraft = ""
    }
}

private struct CustomNumerologyListField: View {
    @Binding var items: [CustomCorrespondencePair]
    @State private var numberDraft = ""
    @State private var detailDraft = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            customFieldLabel("Numerology")

            VStack(alignment: .leading, spacing: 8) {
                ForEach(items) { item in
                    pairCard(item) {
                        items.removeAll { $0.id == item.id }
                    }
                }
            }

            HStack(spacing: 10) {
                shortInput(placeholder: "7", text: $numberDraft)
                    .frame(maxWidth: 82)
                    .onChange(of: numberDraft) { _, newValue in
                        if newValue.count > 4 {
                            numberDraft = String(newValue.prefix(4))
                        }
                    }

                shortInput(placeholder: "Significance...", text: $detailDraft)
                    .onSubmit(addPair)

                addButton(action: addPair)
            }
        }
    }

    private func addPair() {
        let number = numberDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        let detail = detailDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard number.isEmpty == false || detail.isEmpty == false else { return }
        items.append(CustomCorrespondencePair(label: number, detail: detail))
        numberDraft = ""
        detailDraft = ""
    }
}

private struct CustomAddListField: View {
    let title: String
    let placeholder: String
    @Binding var items: [String]
    @State private var draft = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            customFieldLabel(title)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    removableListRow(item) {
                        items.removeAll { $0 == item }
                    }
                }
            }

            HStack(spacing: 10) {
                shortInput(placeholder: placeholder, text: $draft)
                    .onSubmit(addDraft)

                addButton(action: addDraft)
            }
        }
    }

    private func addDraft() {
        let value = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.isEmpty == false else { return }
        items.append(value)
        draft = ""
    }
}

private func customFieldLabel(_ title: String) -> some View {
    Text(title.uppercased())
        .font(.system(size: 13, weight: .black, design: .rounded))
        .foregroundStyle(LColors.textSecondary)
}

private func shortInput(placeholder: String, text: Binding<String>) -> some View {
    GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
        TextField(placeholder, text: text)
            .lineLimit(1)
            .submitLabel(.done)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(LColors.textPrimary)
            .padding(14)
    }
}

private func addButton(action: @escaping () -> Void) -> some View {
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

private func removablePill(_ title: String, onRemove: @escaping () -> Void) -> some View {
    Button(action: onRemove) {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .black, design: .rounded))

            Image("xmarkwavy")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 10)
        }
        .foregroundStyle(LColors.textPrimary)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(LGradients.tag.opacity(0.55), in: Capsule(style: .continuous))
        .overlay {
            Capsule(style: .continuous)
                .strokeBorder(LColors.glassBorder, lineWidth: 1)
        }
    }
    .buttonStyle(.plain)
}

private func removableDropdownRow(_ title: String, onRemove: @escaping () -> Void) -> some View {
    HStack {
        Text(title)
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(LColors.textPrimary)

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
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
    .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 12))
}

private func removableListRow(_ title: String, onRemove: @escaping () -> Void) -> some View {
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

private func pairCard(_ item: CustomCorrespondencePair, onRemove: @escaping () -> Void) -> some View {
    GlassCard(cornerRadius: LSpacing.inputRadius, padding: 12) {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                if item.label.isEmpty == false {
                    Text(item.label)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(LGradients.header)
                }

                if item.detail.isEmpty == false {
                    Text(item.detail)
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

private struct CorrespondenceEntryDetailView: View {
    let type: CorrespondenceType
    let onSave: (CorrespondenceEntryResponse) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var entry: CorrespondenceEntryResponse
    @State private var showingEditForm = false

    init(
        type: CorrespondenceType,
        entry: CorrespondenceEntryResponse,
        onSave: @escaping (CorrespondenceEntryResponse) -> Void = { _ in }
    ) {
        self.type = type
        self.onSave = onSave
        _entry = State(initialValue: entry)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                header

                detailOverview

                listSection(title: "Intentions", icon: "startarget", values: entry.intentions)
                listSection(title: "Purposes", icon: "wand", values: entry.purposes)
                listSection(title: "Alternative Names", icon: "tagsparkle", values: entry.alternativeNames)
                textSection(title: "Scientific Name", icon: "flower", text: entry.scientificName)
                listSection(title: "Planets", icon: "planet", values: entry.planetaryCorrespondences)
                listSection(title: "Zodiac Signs", icon: "starchart", values: entry.zodiacCorrespondences)
                listSection(title: "Elements", icon: "sparklesstarflag", values: entry.elementalCorrespondences)
                listSection(title: "Deities", icon: "starchalice", values: entry.deities)
                explanationSection(title: "Chakras", icon: "galaxysparkle", values: entry.chakraAssociations)
                numerologySection
                tarotSection
                listSection(title: "Sabbats", icon: "ringstarcal", values: entry.sabbats)
                lunarSection
                seasonSection
                daySection
                colorSection
                listSection(title: "Symbols", icon: "sparklecircle", values: entry.symbols)
                conditionalDetailSections
                paragraphListSection(title: "Uses in Spellwork", icon: "potionsparkle", values: entry.usesInSpellwork)
                textSection(title: "Uses in Ritual", icon: "candleslit", text: entry.usesInRitual)
                textSection(title: "Usage", icon: "handbook", text: entry.usage)
                textSection(title: "Divination", icon: "tarot", text: entry.divinationAssociations)
                paragraphListSection(title: "Spiritual Meanings", icon: "starsparklesbox", values: entry.spiritualMeanings)
                textSection(title: "Historical Notes", icon: "timebook", text: entry.historicalNotes)
                textSection(title: "Folklore", icon: "openbook", text: entry.folklore)
                textSection(title: "Warnings", icon: "warnwavy", text: entry.warnings)
            }
            .padding(.horizontal, LSpacing.pageHorizontal)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background { AsteriumBackground() }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await refreshIncompleteEssentialOil()
        }
        .asteriumAdaptivePresentation(isPresented: $showingEditForm) {
            CustomCorrespondenceEntryForm(type: type, existing: entry) { editedEntry in
                entry = editedEntry
                onSave(editedEntry)
            }
        }
    }

    private func refreshIncompleteEssentialOil() async {
        guard type == .essentialOil,
              entry.source.caseInsensitiveCompare("custom") != .orderedSame,
              entry.sourcePlant?.isEmpty != false ||
              entry.plantPartUsed?.isEmpty != false ||
              entry.aromaProfile?.isEmpty != false ||
              entry.blendingNotes?.isEmpty != false ||
              entry.complementaryOils?.isEmpty != false ||
              entry.commonSubstitutions?.isEmpty != false else { return }

        let service = CorrespondenceEngineService()
        guard let cached = try? await service.cachedEntry(type: type, name: entry.name),
              cached.sourcePlant?.isEmpty == false,
              cached.plantPartUsed?.isEmpty == false,
              cached.aromaProfile?.isEmpty == false,
              cached.blendingNotes?.isEmpty == false,
              cached.complementaryOils?.isEmpty == false,
              cached.commonSubstitutions?.isEmpty == false,
              entry.source.caseInsensitiveCompare("custom") != .orderedSame else { return }

        entry = cached
        onSave(cached)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(type.title.uppercased())
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)

                Text(entry.name)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
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

    private var detailOverview: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Image(type.icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(LGradients.header)

                Text(entry.shortDescription)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var conditionalDetailSections: some View {
        switch type {
        case .herb: herbDetailSections
        case .flower: flowerDetailSections
        case .crystal: crystalDetailSections
        case .essentialOil: essentialOilDetailSections
        case .color: colorDetailSections
        case .planet: planetDetailSections
        case .zodiacSign: zodiacSignDetailSections
        case .lunarPhase: lunarPhaseDetailSections
        case .sabbat: sabbatDetailSections
        case .season: seasonDetailSections
        case .dayOfWeek: dayOfWeekDetailSections
        case .element: elementDetailSections
        case .tarotCard: tarotCardDetailSections
        case .deity: deityDetailSections
        case .spirit: spiritDetailSections
        case .animal: animalDetailSections
        case .tool: toolDetailSections
        case .number: numberDetailSections
        }
    }

    @ViewBuilder
    private var sabbatDetailSections: some View {
        if type == .sabbat {
            listSection(title: "Foods", icon: "foodbox", values: entry.foods ?? [])
            listSection(title: "Drinks", icon: "teapot", values: entry.drinks ?? [])
            paragraphListSection(title: "Ways to Celebrate", icon: "partyballoons", values: entry.waysToCelebrate ?? [])
            paragraphListSection(title: "Ritual Ideas", icon: "candleslit", values: entry.ritualIdeas ?? [])
            paragraphListSection(title: "Activities", icon: "wand", values: entry.activities ?? [])
            listSection(title: "Decorations", icon: "partyfavorbag", values: entry.decorations ?? [])
            paragraphListSection(title: "Altar Ideas", icon: "candlebra", values: entry.altarIdeas ?? [])
            listSection(title: "Herbs & Plants", icon: "flower", values: entry.herbsAndPlants ?? [])
            listSection(title: "Crystals & Stones", icon: "crystalball", values: entry.crystalsAndStones ?? [])
            listSection(title: "Incense & Scents", icon: "lovesmokes", values: entry.incenseAndScents ?? [])
            listSection(title: "Seasonal Themes", icon: "treeoutside", values: entry.seasonalThemes ?? [])
        }
    }

    @ViewBuilder
    private var herbDetailSections: some View {
        if type == .herb {
            textSection(title: "Botanical Family", icon: "seedling", text: entry.botanicalFamily ?? "")
            listSection(title: "Parts Used", icon: "flowerfilled", values: entry.partsUsed ?? [])
            paragraphListSection(title: "Preparation Methods", icon: "cauldron", values: entry.preparationMethods ?? [])
            textSection(title: "Harvesting & Storage", icon: "basketflowers", text: entry.harvestingAndStorage ?? "")
            listSection(title: "Common Substitutions", icon: "repeatarrows", values: entry.commonSubstitutions ?? [])
            listSection(title: "Pairings / Complementary Herbs", icon: "flowersegg", values: entry.complementaryHerbs ?? [])
            paragraphListSection(title: "Smoke / Incense Uses", icon: "lovesmokes", values: entry.smokeAndIncenseUses ?? [])
        }
    }

    @ViewBuilder
    private var flowerDetailSections: some View {
        if type == .flower {
            textSection(title: "Botanical Family", icon: "seedling", text: entry.botanicalFamily ?? "")
            listSection(title: "Blooming Season", icon: "sunflower", values: entry.bloomingSeason ?? [])
            listSection(title: "Parts Used", icon: "flowerfilled", values: entry.partsUsed ?? [])
            paragraphListSection(title: "Preservation Methods", icon: "basketflowers", values: entry.preservationMethods ?? [])
            paragraphListSection(title: "Floral Symbolism", icon: "flowersheart", values: entry.floralSymbolism ?? [])
            paragraphListSection(title: "Traditional Gift Meanings", icon: "stargift", values: entry.traditionalGiftMeanings ?? [])
            listSection(title: "Pairings / Complementary Flowers", icon: "flowersegg", values: entry.complementaryFlowers ?? [])
            listSection(title: "Common Substitutions", icon: "repeatarrows", values: entry.commonSubstitutions ?? [])
        }
    }

    @ViewBuilder
    private var crystalDetailSections: some View {
        if type == .crystal {
            textSection(title: "Mineral Family", icon: "objects", text: entry.mineralFamily ?? "")
            textSection(title: "Composition", icon: "threeboxes", text: entry.composition ?? "")
            textSection(title: "Hardness", icon: "weight", text: entry.hardness ?? "")
            textSection(title: "Crystal System", icon: "blocks", text: entry.crystalSystem ?? "")
            listSection(title: "Common Colors / Varieties", icon: "colorpicker", values: entry.commonColorsAndVarieties ?? [])
            paragraphListSection(title: "Cleansing Methods", icon: "bubbles", values: entry.cleansingMethods ?? [])
            paragraphListSection(title: "Charging Methods", icon: "bolt", values: entry.chargingMethods ?? [])
            listSection(title: "Common Substitutions", icon: "repeatarrows", values: entry.commonSubstitutions ?? [])
        }
    }

    @ViewBuilder
    private var essentialOilDetailSections: some View {
        if type == .essentialOil {
            textSection(title: "Source Plant", icon: "seedling", text: entry.sourcePlant ?? "")
            textSection(title: "Plant Part Used", icon: "flowerfilled", text: entry.plantPartUsed ?? "")
            textSection(title: "Aroma Profile", icon: "perfume", text: entry.aromaProfile ?? "")
            textSection(title: "Blending Notes", icon: "linedpages", text: entry.blendingNotes ?? "")
            listSection(title: "Complementary Oils", icon: "dropper", values: entry.complementaryOils ?? [])
            listSection(title: "Common Substitutions", icon: "repeatarrows", values: entry.commonSubstitutions ?? [])
        }
    }

    @ViewBuilder
    private var colorDetailSections: some View {
        if type == .color {
            listSection(title: "Shades & Variations", icon: "colorpicker", values: entry.shadesAndVariations ?? [])
            paragraphListSection(title: "Candle Magic Uses", icon: "candleslit", values: entry.candleMagicUses ?? [])
            paragraphListSection(title: "Visualization Uses", icon: "eye", values: entry.visualizationUses ?? [])
        }
    }

    @ViewBuilder
    private var planetDetailSections: some View {
        if type == .planet {
            textSection(title: "Planetary Day", icon: "dotscal", text: entry.planetaryDay ?? "")
            textSection(title: "Planetary Hour", icon: "clockwavy", text: entry.planetaryHour ?? "")
            textSection(title: "Traditional Metal", icon: "coinssparkle", text: entry.traditionalMetal ?? "")
            listSection(title: "Associated Herbs", icon: "seedling", values: entry.associatedHerbs ?? [])
            listSection(title: "Associated Crystals", icon: "crystalball", values: entry.associatedCrystals ?? [])
            paragraphListSection(title: "Magical Domains", icon: "starshield", values: entry.magicalDomains ?? [])
        }
    }

    @ViewBuilder
    private var zodiacSignDetailSections: some View {
        if type == .zodiacSign {
            textSection(title: "Modality", icon: "balancewavy", text: entry.modality ?? "")
            textSection(title: "Polarity", icon: "bolt", text: entry.polarity ?? "")
            textSection(title: "Ruling Planet", icon: "planet", text: entry.rulingPlanet ?? "")
            textSection(title: "House Association", icon: "houseoutline", text: entry.houseAssociation ?? "")
            textSection(title: "Symbol/Glyph Meaning", icon: "starchart", text: entry.symbolMeaning ?? "")
            paragraphListSection(title: "Personality/Energetic Qualities", icon: "galaxysparkle", values: entry.energeticQualities ?? [])
            paragraphListSection(title: "Strengths/Weaknesses", icon: "balancewavy", values: entry.strengthsAndWeaknesses ?? [])
            listSection(title: "Associated Herbs", icon: "seedling", values: entry.associatedHerbs ?? [])
            listSection(title: "Associated Crystals", icon: "crystalball", values: entry.associatedCrystals ?? [])
        }
    }

    @ViewBuilder
    private var lunarPhaseDetailSections: some View {
        if type == .lunarPhase {
            textSection(title: "Energetic Theme", icon: "sparkle", text: entry.energeticTheme ?? "")
            paragraphListSection(title: "Best Magical Work", icon: "potionsparkle", values: entry.bestMagicalWork ?? [])
            paragraphListSection(title: "Activities", icon: "wand", values: entry.activities ?? [])
            listSection(title: "Herbs", icon: "seedling", values: entry.associatedHerbs ?? [])
            listSection(title: "Crystals", icon: "crystalball", values: entry.associatedCrystals ?? [])
            paragraphListSection(title: "Altar Ideas", icon: "candlebra", values: entry.altarIdeas ?? [])
        }
    }

    @ViewBuilder
    private var seasonDetailSections: some View {
        if type == .season {
            listSection(title: "Seasonal Themes", icon: "treeoutside", values: entry.seasonalThemes ?? [])
            listSection(title: "Seasonal Foods", icon: "foodbox", values: entry.seasonalFoods ?? [])
            listSection(title: "Seasonal Drinks", icon: "teapot", values: entry.seasonalDrinks ?? [])
            listSection(title: "Seasonal Plants", icon: "flower", values: entry.seasonalPlants ?? [])
            listSection(title: "Seasonal Animals", icon: "paw", values: entry.seasonalAnimals ?? [])
            paragraphListSection(title: "Seasonal Activities", icon: "wand", values: entry.seasonalActivities ?? [])
            paragraphListSection(title: "Altar Ideas", icon: "candlebra", values: entry.altarIdeas ?? [])
            listSection(title: "Decorations", icon: "partyfavorbag", values: entry.decorations ?? [])
        }
    }

    @ViewBuilder
    private var dayOfWeekDetailSections: some View {
        if type == .dayOfWeek {
            textSection(title: "Ruling Planet", icon: "planet", text: entry.rulingPlanet ?? "")
            paragraphListSection(title: "Magical Focus", icon: "startarget", values: entry.magicalFocus ?? [])
            listSection(title: "Associated Herbs", icon: "seedling", values: entry.associatedHerbs ?? [])
            listSection(title: "Associated Crystals", icon: "crystalball", values: entry.associatedCrystals ?? [])
            listSection(title: "Associated Colors", icon: "paintdrop", values: entry.associatedColors ?? [])
            listSection(title: "Deity Associations", icon: "starchalice", values: entry.deityAssociations ?? [])
        }
    }

    @ViewBuilder
    private var elementDetailSections: some View {
        if type == .element {
            textSection(title: "Direction", icon: "arrowscircle", text: entry.direction ?? "")
            paragraphListSection(title: "Qualities", icon: "sparklesstarflag", values: entry.qualities ?? [])
            paragraphListSection(title: "Magical Domains", icon: "starshield", values: entry.magicalDomains ?? [])
            listSection(title: "Associated Tools", icon: "wand", values: entry.associatedTools ?? [])
            listSection(title: "Associated Herbs", icon: "seedling", values: entry.associatedHerbs ?? [])
            listSection(title: "Associated Crystals", icon: "crystalball", values: entry.associatedCrystals ?? [])
            listSection(title: "Associated Spirits/Elementals", icon: "ghost", values: entry.associatedSpirits ?? [])
            listSection(title: "Associated Weather", icon: "cloudie", values: entry.associatedWeather ?? [])
            paragraphListSection(title: "Invocation Methods", icon: "candleslit", values: entry.invocationMethods ?? [])
            textSection(title: "Altar Representation", icon: "candlebra", text: entry.altarRepresentation ?? "")
        }
    }

    @ViewBuilder
    private var tarotCardDetailSections: some View {
        if type == .tarotCard {
            textSection(title: "Arcana", icon: "tarotcards", text: entry.arcana ?? "")
            textSection(title: "Suit", icon: "tarot", text: entry.suit ?? "")
            textSection(title: "Number/Rank", icon: "numcal", text: entry.numberOrRank ?? "")
            textSection(title: "Element", icon: "sparklesstarflag", text: entry.element ?? "")
            textSection(title: "Astrological Association", icon: "starchart", text: entry.astrologicalAssociation ?? "")
            textSection(title: "Upright Meaning", icon: "openbook", text: entry.uprightMeaning ?? "")
            textSection(title: "Reversed Meaning", icon: "repeatarrows", text: entry.reversedMeaning ?? "")
            listSection(title: "Keywords", icon: "tagsparkle", values: entry.keywords ?? [])
            textSection(title: "Imagery & Symbolism", icon: "eye", text: entry.imageryAndSymbolism ?? "")
            textSection(title: "Yes/No Association", icon: "checkwavy", text: entry.yesNoAssociation ?? "")
            textSection(title: "Timing Association", icon: "clockwavy", text: entry.timingAssociation ?? "")
        }
    }

    @ViewBuilder
    private var deityDetailSections: some View {
        if type == .deity {
            textSection(title: "Culture/Tradition", icon: "openbook", text: entry.cultureTradition ?? "")
            textSection(title: "Pantheon", icon: "starchalice", text: entry.pantheon ?? "")
            listSection(title: "Domains", icon: "starshield", values: entry.domains ?? [])
            listSection(title: "Epithets/Titles", icon: "quote", values: entry.epithetsTitles ?? [])
            listSection(title: "Sacred Animals", icon: "paw", values: entry.sacredAnimals ?? [])
            listSection(title: "Sacred Plants", icon: "seedling", values: entry.sacredPlants ?? [])
            listSection(title: "Sacred Places", icon: "starlocation", values: entry.sacredPlaces ?? [])
            listSection(title: "Offerings", icon: "stargift", values: entry.offerings ?? [])
            paragraphListSection(title: "Devotional Acts", icon: "meditate", values: entry.devotionalActs ?? [])
            paragraphListSection(title: "Altar Ideas", icon: "candlebra", values: entry.altarIdeas ?? [])
            listSection(title: "Festivals/Holy Days", icon: "ringstarcal", values: entry.festivalsHolyDays ?? [])
            textSection(title: "Myths & Stories", icon: "openbook", text: entry.mythsAndStories ?? "")
            textSection(title: "Historical Worship", icon: "timebook", text: entry.historicalWorship ?? "")
            paragraphListSection(title: "Modern Devotional Practices", icon: "candleslit", values: entry.modernDevotionalPractices ?? [])
        }
    }

    @ViewBuilder
    private var spiritDetailSections: some View {
        if type == .spirit {
            textSection(title: "Spirit Type", icon: "ghost", text: entry.spiritType ?? "")
            textSection(title: "Cultural/Traditional Context", icon: "openbook", text: entry.culturalContext ?? "")
            listSection(title: "Domains/Associations", icon: "starshield", values: entry.domainsAssociations ?? [])
            textSection(title: "Appearance/Descriptions", icon: "eye", text: entry.appearanceDescriptions ?? "")
            paragraphListSection(title: "Signs & Presence", icon: "sparkle", values: entry.signsAndPresence ?? [])
            listSection(title: "Offerings", icon: "stargift", values: entry.offerings ?? [])
            paragraphListSection(title: "Communication Methods", icon: "chatsparkle", values: entry.communicationMethods ?? [])
            paragraphListSection(title: "Altar/Shrine Ideas", icon: "candlebra", values: entry.altarIdeas ?? [])
            listSection(title: "Related Spirits/Entities", icon: "galaxysparkle", values: entry.relatedSpirits ?? [])
            textSection(title: "Protective Considerations", icon: "starshield", text: entry.protectiveConsiderations ?? "")
        }
    }

    @ViewBuilder
    private var animalDetailSections: some View {
        if type == .animal {
            textSection(title: "Habitat", icon: "treeoutside", text: entry.habitat ?? "")
            paragraphListSection(title: "Behavioral Traits", icon: "paw", values: entry.behavioralTraits ?? [])
            paragraphListSection(title: "Symbolic Traits", icon: "sparklecircle", values: entry.symbolicTraits ?? [])
            paragraphListSection(title: "Omens & Signs", icon: "eye", values: entry.omensAndSigns ?? [])
            textSection(title: "Dream Meaning", icon: "themoon", text: entry.dreamMeaning ?? "")
            textSection(title: "Encounter Meaning", icon: "feetprints", text: entry.encounterMeaning ?? "")
            listSection(title: "Associated Seasons", icon: "treeoutside", values: entry.associatedSeasons ?? [])
            textSection(title: "Animal Spirit/Guide Interpretations", icon: "galaxysparkle", text: entry.spiritGuideInterpretations ?? "")
            textSection(title: "Cultural Symbolism", icon: "openbook", text: entry.culturalSymbolism ?? "")
        }
    }

    @ViewBuilder
    private var toolDetailSections: some View {
        if type == .tool {
            textSection(title: "Tool Type", icon: "wand", text: entry.toolType ?? "")
            textSection(title: "Traditional Purpose", icon: "openbook", text: entry.traditionalPurpose ?? "")
            textSection(title: "How to Use", icon: "handbook", text: entry.howToUse ?? "")
            textSection(title: "Preparation", icon: "cauldron", text: entry.preparation ?? "")
            textSection(title: "Cleansing", icon: "bubbles", text: entry.cleansing ?? "")
            textSection(title: "Consecration", icon: "candleslit", text: entry.consecration ?? "")
            textSection(title: "Charging", icon: "bolt", text: entry.charging ?? "")
            textSection(title: "Storage", icon: "threeboxes", text: entry.storage ?? "")
            listSection(title: "Materials", icon: "objects", values: entry.materials ?? [])
            listSection(title: "Common Variations", icon: "repeatarrows", values: entry.commonVariations ?? [])
            listSection(title: "Substitutions", icon: "repeatfill", values: entry.substitutions ?? [])
            paragraphListSection(title: "Ritual Applications", icon: "candleslit", values: entry.ritualApplications ?? [])
            paragraphListSection(title: "Spellwork Applications", icon: "potionsparkle", values: entry.spellworkApplications ?? [])
        }
    }

    @ViewBuilder
    private var numberDetailSections: some View {
        if type == .number {
            textSection(title: "Core Meaning", icon: "numcal", text: entry.coreMeaning ?? "")
            textSection(title: "Positive Expression", icon: "sparkle", text: entry.positiveExpression ?? "")
            textSection(title: "Shadow Expression", icon: "eyeslash", text: entry.shadowExpression ?? "")
            textSection(title: "Repeating Number Meaning", icon: "repeatarrows", text: entry.repeatingNumberMeaning ?? "")
            textSection(title: "Synchronicity Meaning", icon: "sparklecircle", text: entry.synchronicityMeaning ?? "")
            textSection(title: "Manifestation Association", icon: "starsparklesbox", text: entry.manifestationAssociation ?? "")
            textSection(title: "Divination Meaning", icon: "tarot", text: entry.divinationMeaning ?? "")
            listSection(title: "Tarot Connections", icon: "tarotcards", values: entry.tarotConnections ?? [])
            listSection(title: "Astrological Connections", icon: "starchart", values: entry.astrologicalConnections ?? [])
            textSection(title: "Sacred Geometry/Symbolism", icon: "sparklesstarflag", text: entry.sacredGeometrySymbolism ?? "")
            paragraphListSection(title: "Cultural/Historical Meanings", icon: "timebook", values: entry.culturalHistoricalMeanings ?? [])
        }
    }

    @ViewBuilder
    private var numerologySection: some View {
        if entry.numerology.isEmpty == false {
            sectionContainer(title: "Numerology", icon: "numcal") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(entry.numerology, id: \.self) { item in
                        detailLine(title: item.number, body: item.significance)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var tarotSection: some View {
        if entry.tarotAssociations.isEmpty == false {
            sectionContainer(title: "Tarot", icon: "tarotcards") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(entry.tarotAssociations, id: \.self) { item in
                        detailLine(title: item.card, body: item.explanation)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var lunarSection: some View {
        if entry.lunarPhases.isEmpty == false {
            sectionContainer(title: "Lunar Phases", icon: "themoon") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(entry.lunarPhases, id: \.self) { item in
                        detailLine(title: item.phase, body: item.explanation)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var seasonSection: some View {
        if entry.seasons.isEmpty == false {
            sectionContainer(title: "Seasons", icon: "treeoutside") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(entry.seasons, id: \.self) { item in
                        detailLine(title: item.season, body: item.explanation)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var daySection: some View {
        if entry.daysOfWeek.isEmpty == false {
            sectionContainer(title: "Days of the Week", icon: "dotscal") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(entry.daysOfWeek, id: \.self) { item in
                        detailLine(title: item.day, body: item.explanation)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var colorSection: some View {
        if entry.colorCorrespondences.isEmpty == false {
            sectionContainer(title: "Colors", icon: "paintdrop") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(entry.colorCorrespondences, id: \.self) { item in
                        detailLine(title: item.color, body: item.meaning)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func listSection(title: String, icon: String, values: [String]) -> some View {
        if values.isEmpty == false {
            sectionContainer(title: title, icon: icon) {
                CorrespondenceFlowLayout(spacing: 8) {
                    ForEach(values, id: \.self) { value in
                        Text(value)
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(
                                LColors.glassSurface,
                                in: Capsule(style: .continuous)
                            )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func explanationSection(
        title: String,
        icon: String,
        values: [CorrespondenceExplanation]
    ) -> some View {
        if values.isEmpty == false {
            sectionContainer(title: title, icon: icon) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(values, id: \.self) { item in
                        detailLine(title: item.name, body: item.explanation)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func paragraphListSection(
        title: String,
        icon: String,
        values: [String]
    ) -> some View {
        if values.isEmpty == false {
            sectionContainer(title: title, icon: icon) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(values, id: \.self) { value in
                        Text(value)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(LColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func textSection(title: String, icon: String, text: String) -> some View {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedText.isEmpty == false {
            sectionContainer(title: title, icon: icon) {
                Text(trimmedText)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
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
}

private struct CorrespondenceFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let width = proposal.width ?? UIScreen.main.bounds.width - 72
        let rows = rows(for: subviews, in: width)
        return CGSize(width: width, height: rows)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(
                    width: size.width,
                    height: size.height
                )
            )

            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }

    private func rows(for subviews: Subviews, in width: CGFloat) -> CGFloat {
        var x: CGFloat = 0
        var totalHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x > 0, x + size.width > width {
                totalHeight += rowHeight + spacing
                x = 0
                rowHeight = 0
            }

            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return totalHeight + rowHeight
    }
}
