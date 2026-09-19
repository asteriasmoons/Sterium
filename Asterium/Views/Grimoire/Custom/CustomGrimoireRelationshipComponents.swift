//
// CustomGrimoireRelationshipComponents.swift
// Sterium
//

import SwiftUI
import SwiftData

struct CustomRelatedEntriesInput: View {
    let title: String
    @Binding var references: [CustomEntryReference]
    let allowsMultiple: Bool
    @State private var showingPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            ForEach(references) { reference in
                HStack(spacing: 12) {
                    Image(reference.iconName)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(LGradients.header)
                        .frame(width: 32, height: 32)
                        .background(LColors.glassSurface, in: Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(reference.title)
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                        Text(reference.typeName)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(LColors.textSecondary)
                    }

                    Spacer()

                    Button { references.removeAll { $0.id == reference.id } } label: {
                        Image("xmarkwavy")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(LGradients.header)
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.inputRadius))
                .overlay { RoundedRectangle(cornerRadius: LSpacing.inputRadius).strokeBorder(LColors.glassBorder, lineWidth: 1) }
            }

            Button { showingPicker = true } label: {
                HStack(spacing: 10) {
                    Text(allowsMultiple ? "Add Related Entry" : "Choose Entry")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Spacer()
                    Image("addwavy")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                }
                .foregroundStyle(LGradients.header)
                .padding(14)
                .frame(maxWidth: .infinity)
                .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.inputRadius))
                .overlay { RoundedRectangle(cornerRadius: LSpacing.inputRadius).strokeBorder(LColors.glassBorder, lineWidth: 1) }
            }
            .buttonStyle(.plain)
        }
        .asteriumAdaptivePresentation(isPresented: $showingPicker) {
            CustomEntryReferencePicker { reference in
                if allowsMultiple {
                    guard !references.contains(where: { $0.targetID == reference.targetID }) else { return }
                    references.append(reference)
                } else {
                    references = [reference]
                }
            }
        }
    }
}

private struct CustomEntryReferencePicker: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (CustomEntryReference) -> Void

    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var journals: [JournalEntry]
    @Query(sort: \ExperienceEntry.createdAt, order: .reverse) private var experiences: [ExperienceEntry]
    @Query(sort: \WorkingDocumentEntry.createdAt, order: .reverse) private var workingDocuments: [WorkingDocumentEntry]
    @Query(sort: \WorkingResultEntry.createdAt, order: .reverse) private var workingResults: [WorkingResultEntry]
    @Query(sort: \DreamEntry.createdAt, order: .reverse) private var dreams: [DreamEntry]
    @Query(sort: \SynchronicityEntry.createdAt, order: .reverse) private var synchronicities: [SynchronicityEntry]
    @Query(sort: \PathworkEntry.createdAt, order: .reverse) private var pathworks: [PathworkEntry]
    @Query(sort: \MoonPhaseEntry.createdAt, order: .reverse) private var moonPhases: [MoonPhaseEntry]
    @Query(sort: \DeityDevotionEntry.createdAt, order: .reverse) private var deityDevotions: [DeityDevotionEntry]
    @Query(sort: \DivinationEntry.createdAt, order: .reverse) private var divinations: [DivinationEntry]
    @Query(sort: \MeditationEntry.createdAt, order: .reverse) private var meditations: [MeditationEntry]
    @Query(sort: \ShadowWorkEntry.createdAt, order: .reverse) private var shadowWorks: [ShadowWorkEntry]
    @Query(sort: \ManifestationEntry.createdAt, order: .reverse) private var manifestations: [ManifestationEntry]
    @Query(sort: \CustomGrimoireEntry.createdAt, order: .reverse) private var customEntries: [CustomGrimoireEntry]

    private var candidates: [CustomEntryReference] {
        var values: [CustomEntryReference] = []
        values += journals.map { reference($0.id, $0.title, .journal) }
        values += experiences.map { reference($0.id, $0.title, .experience) }
        values += workingDocuments.map { reference($0.id, $0.title, .workingDocument) }
        values += workingResults.map { reference($0.id, $0.title, .workingResult) }
        values += dreams.map { reference($0.id, $0.title, .dream) }
        values += synchronicities.map { reference($0.id, $0.title, .synchronicity) }
        values += pathworks.map { reference($0.id, $0.chapterTitle, .pathwork) }
        values += moonPhases.map { reference($0.id, $0.title, .moonPhase) }
        values += deityDevotions.map { reference($0.id, $0.title, .deityDevotion) }
        values += divinations.map { reference($0.id, $0.title, .divination) }
        values += meditations.map { reference($0.id, $0.title, .meditation) }
        values += shadowWorks.map { reference($0.id, $0.title, .shadowWork) }
        values += manifestations.map { reference($0.id, $0.title, .manifestation) }
        values += customEntries.map {
            CustomEntryReference(
                targetID: $0.id,
                targetKindRawValue: "custom",
                title: $0.title,
                typeName: $0.templateName,
                iconName: $0.templateIconName
            )
        }
        return values
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                HStack {
                    AsteriumPageHeader(eyebrow: "Grimoire", title: "Choose Entry")
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

                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(candidates) { candidate in
                            Button {
                                onSelect(candidate)
                                dismiss()
                            } label: {
                                GlassCard(padding: 0) {
                                    HStack(spacing: 12) {
                                        Image(candidate.iconName)
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .foregroundStyle(LGradients.header)
                                            .frame(width: 36, height: 36)
                                            .background(LColors.glassSurface, in: Circle())
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(candidate.title.isEmpty ? "Untitled" : candidate.title)
                                                .font(.system(size: 15, weight: .black, design: .rounded))
                                                .foregroundStyle(LColors.textPrimary)
                                            Text(candidate.typeName)
                                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                                .foregroundStyle(LColors.textSecondary)
                                        }
                                        Spacer()
                                        Image("rightwavy")
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 14, height: 14)
                                            .foregroundStyle(LGradients.header)
                                    }
                                    .padding(14)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, LSpacing.pageHorizontal)
            .padding(.bottom, 40)
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func reference(_ id: UUID, _ title: String, _ type: GrimoireEntryType) -> CustomEntryReference {
        CustomEntryReference(
            targetID: id,
            targetKindRawValue: type.rawValue,
            title: title,
            typeName: type.singularName,
            iconName: type.icon
        )
    }
}
