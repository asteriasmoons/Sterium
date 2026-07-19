
//
//  GrimoireRelatedEntriesField.swift
//  Asterium
//

import SwiftUI
import SwiftData

struct GrimoireRelatedEntriesField: View {
    @Binding var relatedEntries: [GrimoireRelatedEntry]
    @State private var showingPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RELATED ENTRIES")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            if !relatedEntries.isEmpty {
                VStack(spacing: 8) {
                    ForEach(relatedEntries, id: \.id) { entry in
                        relatedEntryCard(entry)
                    }
                }
            }

            Button {
                showingPicker = true
            } label: {
                HStack(spacing: 10) {
                    Image("grimoire")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)

                    Text("Add Related Entry")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(LColors.textPrimary)
                .padding(14)
                .frame(maxWidth: .infinity)
                .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.inputRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: LSpacing.inputRadius)
                        .strokeBorder(LColors.glassBorder, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showingPicker) {
                GrimoireRelatedEntryPickerSheet(
                    relatedEntries: $relatedEntries,
                    isPresented: $showingPicker
                )
            }
        }
    }

    @ViewBuilder
    private func relatedEntryCard(_ entry: GrimoireRelatedEntry) -> some View {
        GlassCard(cornerRadius: LSpacing.inputRadius, padding: 12) {
            HStack(spacing: 10) {
                Image(entry.relatedEntryType.icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(entry.relatedEntryType.color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.relatedEntryTitle)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                        .lineLimit(1)

                    Text(entry.relatedEntryType.displayName)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                }

                Spacer()

                Button {
                    relatedEntries.removeAll { $0.id == entry.id }
                } label: {
                    Text("\u{2715}")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Related Entry Picker Sheet

private struct GrimoireRelatedEntryPickerSheet: View {
    @Binding var relatedEntries: [GrimoireRelatedEntry]
    @Binding var isPresented: Bool
    @Environment(\.modelContext) private var modelContext

    @State private var selectedType: GrimoireEntryType = .journal
    @State private var fetchedEntries: [(id: UUID, title: String)] = []

    var body: some View {
        NavigationStack {
            ZStack {
                AsteriumBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                        // Type picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ENTRY TYPE")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(LColors.textSecondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(GrimoireEntryType.allCases, id: \.self) { type in
                                        Button {
                                            selectedType = type
                                            fetchEntries(for: type)
                                        } label: {
                                            Text(type.displayName)
                                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                                .foregroundStyle(selectedType == type ? LColors.bg : LColors.textPrimary)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 8)
                                                .background(
                                                    Capsule()
                                                        .fill(selectedType == type ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassSurface))
                                                )
                                                .overlay {
                                                    Capsule()
                                                        .strokeBorder(
                                                            selectedType == type ? AnyShapeStyle(Color.clear) : AnyShapeStyle(LColors.glassBorder),
                                                            lineWidth: 1
                                                        )
                                                }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        // Entries list
                        if fetchedEntries.isEmpty {
                            Text("No entries found for this type.")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(LColors.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 20)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(fetchedEntries, id: \.id) { entry in
                                    Button {
                                        addRelatedEntry(id: entry.id, title: entry.title, type: selectedType)
                                    } label: {
                                        GlassCard(cornerRadius: LSpacing.inputRadius, padding: 12) {
                                            HStack(spacing: 10) {
                                                Image(selectedType.icon)
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 16, height: 16)
                                                    .foregroundStyle(selectedType.color)

                                                Text(entry.title.isEmpty ? "Untitled" : entry.title)
                                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                                    .foregroundStyle(LColors.textPrimary)
                                                    .lineLimit(1)

                                                Spacer()
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, LSpacing.pageHorizontal)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Related Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                }
            }
            .onAppear {
                fetchEntries(for: selectedType)
            }
        }
        .presentationBackground(LColors.bg)
    }

    private func addRelatedEntry(id: UUID, title: String, type: GrimoireEntryType) {
        let alreadyAdded = relatedEntries.contains { $0.relatedEntryID == id }
        guard !alreadyAdded else { return }

        let related = GrimoireRelatedEntry(
            relatedEntryID: id,
            relatedEntryType: type,
            relatedEntryTitle: title
        )
        relatedEntries.append(related)
        isPresented = false
    }

    private func fetchEntries(for type: GrimoireEntryType) {
        fetchedEntries = []

        switch type {
        case .journal:
            let descriptor = FetchDescriptor<JournalEntry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            if let results = try? modelContext.fetch(descriptor) {
                fetchedEntries = results.map { (id: $0.id, title: $0.title) }
            }
        case .workingDocument:
            let descriptor = FetchDescriptor<WorkingDocumentEntry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            if let results = try? modelContext.fetch(descriptor) {
                fetchedEntries = results.map { (id: $0.id, title: $0.title) }
            }
        case .workingResult:
            let descriptor = FetchDescriptor<WorkingResultEntry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            if let results = try? modelContext.fetch(descriptor) {
                fetchedEntries = results.map { (id: $0.id, title: $0.title) }
            }
        case .dream:
            let descriptor = FetchDescriptor<DreamEntry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            if let results = try? modelContext.fetch(descriptor) {
                fetchedEntries = results.map { (id: $0.id, title: $0.title) }
            }
        case .synchronicity:
            let descriptor = FetchDescriptor<SynchronicityEntry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            if let results = try? modelContext.fetch(descriptor) {
                fetchedEntries = results.map { (id: $0.id, title: $0.title) }
            }
        case .pathwork:
            let descriptor = FetchDescriptor<PathworkEntry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            if let results = try? modelContext.fetch(descriptor) {
                fetchedEntries = results.map { (id: $0.id, title: $0.chapterTitle) }
            }
        case .moonPhase:
            let descriptor = FetchDescriptor<MoonPhaseEntry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            if let results = try? modelContext.fetch(descriptor) {
                fetchedEntries = results.map { (id: $0.id, title: $0.title) }
            }
        case .deityDevotion:
            let descriptor = FetchDescriptor<DeityDevotionEntry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            if let results = try? modelContext.fetch(descriptor) {
                fetchedEntries = results.map { (id: $0.id, title: $0.title) }
            }
        case .divination:
            let descriptor = FetchDescriptor<DivinationEntry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            if let results = try? modelContext.fetch(descriptor) {
                fetchedEntries = results.map { (id: $0.id, title: $0.title) }
            }
        case .meditation:
            let descriptor = FetchDescriptor<MeditationEntry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            if let results = try? modelContext.fetch(descriptor) {
                fetchedEntries = results.map { (id: $0.id, title: $0.title) }
            }
        case .shadowWork:
            let descriptor = FetchDescriptor<ShadowWorkEntry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            if let results = try? modelContext.fetch(descriptor) {
                fetchedEntries = results.map { (id: $0.id, title: $0.title) }
            }
        case .manifestation:
            let descriptor = FetchDescriptor<ManifestationEntry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            if let results = try? modelContext.fetch(descriptor) {
                fetchedEntries = results.map { (id: $0.id, title: $0.title) }
            }
        case .experience:
            let descriptor = FetchDescriptor<ExperienceEntry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            if let results = try? modelContext.fetch(descriptor) {
                fetchedEntries = results.map { (id: $0.id, title: $0.title) }
            }
        }
    }
}
