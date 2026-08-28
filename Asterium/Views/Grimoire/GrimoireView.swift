
//
//  GrimoireView.swift
//  Asterium
//

import SwiftUI
import SwiftData

// MARK: - Unified List Item

struct GrimoireListItem: Identifiable {
    let id: UUID
    let title: String
    let type: GrimoireEntryType
    let createdAt: Date
}

// MARK: - Grimoire View

struct GrimoireView: View {
    @Environment(\.modelContext) private var modelContext

    // MARK: Queries (one per model type)

    @Query(sort: \JournalEntry.createdAt, order: .reverse)
    private var journals: [JournalEntry]

    @Query(sort: \ExperienceEntry.createdAt, order: .reverse)
    private var experiences: [ExperienceEntry]

    @Query(sort: \WorkingDocumentEntry.createdAt, order: .reverse)
    private var workingDocuments: [WorkingDocumentEntry]

    @Query(sort: \WorkingResultEntry.createdAt, order: .reverse)
    private var workingResults: [WorkingResultEntry]

    @Query(sort: \DreamEntry.createdAt, order: .reverse)
    private var dreams: [DreamEntry]

    @Query(sort: \SynchronicityEntry.createdAt, order: .reverse)
    private var synchronicities: [SynchronicityEntry]

    @Query(sort: \PathworkEntry.createdAt, order: .reverse)
    private var pathworks: [PathworkEntry]

    @Query(sort: \MoonPhaseEntry.createdAt, order: .reverse)
    private var moonPhases: [MoonPhaseEntry]

    @Query(sort: \DeityDevotionEntry.createdAt, order: .reverse)
    private var deityDevotions: [DeityDevotionEntry]

    @Query(sort: \DivinationEntry.createdAt, order: .reverse)
    private var divinations: [DivinationEntry]

    @Query(sort: \MeditationEntry.createdAt, order: .reverse)
    private var meditations: [MeditationEntry]

    @Query(sort: \ShadowWorkEntry.createdAt, order: .reverse)
    private var shadowWorks: [ShadowWorkEntry]

    @Query(sort: \ManifestationEntry.createdAt, order: .reverse)
    private var manifestations: [ManifestationEntry]

    // MARK: State

    @State private var searchText = ""
    @State private var selectedFilter: GrimoireEntryType?
    @State private var showingNewEntryPicker = false
    @State private var showingNewEntryForm = false
    @State private var selectedNewEntryType: GrimoireEntryType?

    // MARK: Computed

    private var allItems: [GrimoireListItem] {
        var items: [GrimoireListItem] = []

        for e in journals {
            items.append(GrimoireListItem(id: e.id, title: e.title, type: .journal, createdAt: e.createdAt))
        }
        for e in experiences {
            items.append(GrimoireListItem(id: e.id, title: e.title, type: .experience, createdAt: e.createdAt))
        }
        for e in workingDocuments {
            items.append(GrimoireListItem(id: e.id, title: e.title, type: .workingDocument, createdAt: e.createdAt))
        }
        for e in workingResults {
            items.append(GrimoireListItem(id: e.id, title: e.title, type: .workingResult, createdAt: e.createdAt))
        }
        for e in dreams {
            items.append(GrimoireListItem(id: e.id, title: e.title, type: .dream, createdAt: e.createdAt))
        }
        for e in synchronicities {
            items.append(GrimoireListItem(id: e.id, title: e.title, type: .synchronicity, createdAt: e.createdAt))
        }
        for e in pathworks {
            items.append(GrimoireListItem(id: e.id, title: e.chapterTitle, type: .pathwork, createdAt: e.createdAt))
        }
        for e in moonPhases {
            items.append(GrimoireListItem(id: e.id, title: e.title, type: .moonPhase, createdAt: e.createdAt))
        }
        for e in deityDevotions {
            items.append(GrimoireListItem(id: e.id, title: e.title, type: .deityDevotion, createdAt: e.createdAt))
        }
        for e in divinations {
            items.append(GrimoireListItem(id: e.id, title: e.title, type: .divination, createdAt: e.createdAt))
        }
        for e in meditations {
            items.append(GrimoireListItem(id: e.id, title: e.title, type: .meditation, createdAt: e.createdAt))
        }
        for e in shadowWorks {
            items.append(GrimoireListItem(id: e.id, title: e.title, type: .shadowWork, createdAt: e.createdAt))
        }
        for e in manifestations {
            items.append(GrimoireListItem(id: e.id, title: e.title, type: .manifestation, createdAt: e.createdAt))
        }

        return items
    }

    private var filteredItems: [GrimoireListItem] {
        var items = allItems

        if let filter = selectedFilter {
            items = items.filter { $0.type == filter }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            items = items.filter { $0.title.lowercased().contains(query) }
        }

        return items.sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    HStack(alignment: .center) {
                        AsteriumPageHeader(eyebrow: "YOUR", title: "Grimoire")

                        Spacer()

                        Button {
                            showingNewEntryPicker = true
                        } label: {
                            Image("addwavy")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(LGradients.header)
                        }
                        .buttonStyle(.plain)
                    }

                    searchBar

                    filterChips

                    if filteredItems.isEmpty {
                        emptyState
                    } else {
                        entryList
                    }
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
            .asteriumAdaptivePresentation(isPresented: $showingNewEntryPicker) {
                GrimoireNewEntryPicker { type in
                    selectedNewEntryType = type
                }
            }
            .asteriumAdaptivePresentation(isPresented: $showingNewEntryForm) {
                newEntryFormView
            }
            .onChange(of: showingNewEntryPicker) { _, isShowing in
                if !isShowing, selectedNewEntryType != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        showingNewEntryForm = true
                    }
                }
            }
            .onChange(of: showingNewEntryForm) { _, isShowing in
                if !isShowing {
                    selectedNewEntryType = nil
                }
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image("grimoire")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(LColors.textSecondary)

            TextField("Search entries...", text: $searchText)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
        }
        .padding(14)
        .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.inputRadius))
        .overlay {
            RoundedRectangle(cornerRadius: LSpacing.inputRadius)
                .strokeBorder(LColors.glassBorder, lineWidth: 1)
        }
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "All", isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                }

                ForEach(GrimoireEntryType.allCases, id: \.self) { type in
                    filterChip(label: type.displayName, isSelected: selectedFilter == type) {
                        selectedFilter = type
                    }
                }
            }
        }
    }

    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(isSelected ? LColors.bg : LColors.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        Capsule(style: .continuous)
                            .fill(LGradients.header)
                    } else {
                        Capsule(style: .continuous)
                            .fill(LColors.glassSurface)
                            .overlay {
                                Capsule(style: .continuous)
                                    .strokeBorder(LColors.glassBorder, lineWidth: 1)
                            }
                    }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Entry List

    private var entryList: some View {
        LazyVStack(spacing: 10) {
            ForEach(filteredItems) { item in
                entryRow(item)
            }
        }
    }

    private func entryRow(_ item: GrimoireListItem) -> some View {
        GlassCard(cornerRadius: LSpacing.cardRadius, padding: LSpacing.cardPadding) {
            HStack(alignment: .top, spacing: 12) {
                NavigationLink {
                    destinationView(for: item)
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        Image(item.type.icon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                            .foregroundStyle(LGradients.header)
                            .frame(width: 44, height: 44)
                            .background(LColors.glassSurface, in: Circle())

                        VStack(alignment: .leading, spacing: 5) {
                            Text(item.title.isEmpty ? "Untitled" : item.title)
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                                .lineLimit(1)

                            Text(item.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(LColors.textSecondary)

                            Text(item.type.singularName)
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(LGradients.header)
                        }

                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button {
                    deleteEntry(item)
                } label: {
                    Image("trash")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(LGradients.header)
                        .frame(width: 36, height: 36)
                        .background(LColors.glassSurface, in: Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func deleteEntry(_ item: GrimoireListItem) {
        switch item.type {
        case .journal:
            if let entry = journals.first(where: { $0.id == item.id }) {
                modelContext.delete(entry)
            }
        case .experience:
            if let entry = experiences.first(where: { $0.id == item.id }) {
                modelContext.delete(entry)
            }
        case .workingDocument:
            if let entry = workingDocuments.first(where: { $0.id == item.id }) {
                modelContext.delete(entry)
            }
        case .workingResult:
            if let entry = workingResults.first(where: { $0.id == item.id }) {
                modelContext.delete(entry)
            }
        case .dream:
            if let entry = dreams.first(where: { $0.id == item.id }) {
                modelContext.delete(entry)
            }
        case .synchronicity:
            if let entry = synchronicities.first(where: { $0.id == item.id }) {
                modelContext.delete(entry)
            }
        case .pathwork:
            if let entry = pathworks.first(where: { $0.id == item.id }) {
                modelContext.delete(entry)
            }
        case .moonPhase:
            if let entry = moonPhases.first(where: { $0.id == item.id }) {
                modelContext.delete(entry)
            }
        case .deityDevotion:
            if let entry = deityDevotions.first(where: { $0.id == item.id }) {
                modelContext.delete(entry)
            }
        case .divination:
            if let entry = divinations.first(where: { $0.id == item.id }) {
                modelContext.delete(entry)
            }
        case .meditation:
            if let entry = meditations.first(where: { $0.id == item.id }) {
                modelContext.delete(entry)
            }
        case .shadowWork:
            if let entry = shadowWorks.first(where: { $0.id == item.id }) {
                modelContext.delete(entry)
            }
        case .manifestation:
            if let entry = manifestations.first(where: { $0.id == item.id }) {
                modelContext.delete(entry)
            }
        }

        try? modelContext.save()
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("No entries yet")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(LColors.textPrimary)

            Text("Tap the add button to create your first entry")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(LColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: - Navigation Destinations

    @ViewBuilder
    private func destinationView(for item: GrimoireListItem) -> some View {
        switch item.type {
        case .journal:
            if let entry = journals.first(where: { $0.id == item.id }) {
                JournalEntryDetail(entry: entry)
            }
        case .experience:
            if let entry = experiences.first(where: { $0.id == item.id }) {
                ExperienceEntryDetail(entry: entry)
            }
        case .workingDocument:
            if let entry = workingDocuments.first(where: { $0.id == item.id }) {
                WorkingDocumentEntryDetail(entry: entry)
            }
        case .workingResult:
            if let entry = workingResults.first(where: { $0.id == item.id }) {
                WorkingResultEntryDetail(entry: entry)
            }
        case .dream:
            if let entry = dreams.first(where: { $0.id == item.id }) {
                DreamEntryDetail(entry: entry)
            }
        case .synchronicity:
            if let entry = synchronicities.first(where: { $0.id == item.id }) {
                SynchronicityEntryDetail(entry: entry)
            }
        case .pathwork:
            if let entry = pathworks.first(where: { $0.id == item.id }) {
                PathworkEntryDetail(entry: entry)
            }
        case .moonPhase:
            if let entry = moonPhases.first(where: { $0.id == item.id }) {
                MoonPhaseEntryDetail(entry: entry)
            }
        case .deityDevotion:
            if let entry = deityDevotions.first(where: { $0.id == item.id }) {
                DeityDevotionEntryDetail(entry: entry)
            }
        case .divination:
            if let entry = divinations.first(where: { $0.id == item.id }) {
                DivinationEntryDetail(entry: entry)
            }
        case .meditation:
            if let entry = meditations.first(where: { $0.id == item.id }) {
                MeditationEntryDetail(entry: entry)
            }
        case .shadowWork:
            if let entry = shadowWorks.first(where: { $0.id == item.id }) {
                ShadowWorkEntryDetail(entry: entry)
            }
        case .manifestation:
            if let entry = manifestations.first(where: { $0.id == item.id }) {
                ManifestationEntryDetail(entry: entry)
            }
        }
    }

    // MARK: - New Entry Form

    @ViewBuilder
    private var newEntryFormView: some View {
        switch selectedNewEntryType {
        case .journal:
            JournalEntryForm()
        case .experience:
            ExperienceEntryForm()
        case .workingDocument:
            WorkingDocumentEntryForm()
        case .workingResult:
            WorkingResultEntryForm()
        case .dream:
            DreamEntryForm()
        case .synchronicity:
            SynchronicityEntryForm()
        case .pathwork:
            PathworkEntryForm()
        case .moonPhase:
            MoonPhaseEntryForm()
        case .deityDevotion:
            DeityDevotionEntryForm()
        case .divination:
            DivinationEntryForm()
        case .meditation:
            MeditationEntryForm()
        case .shadowWork:
            ShadowWorkEntryForm()
        case .manifestation:
            ManifestationEntryForm()
        case nil:
            EmptyView()
        }
    }
}
