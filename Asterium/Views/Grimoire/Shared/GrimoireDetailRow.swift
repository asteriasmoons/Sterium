//
//  GrimoireDetailRow.swift
//  Sterium
//

import SwiftUI
import SwiftData

// MARK: - Detail Header

struct GrimoireDetailHeader: View {
    @Environment(\.dismiss) private var dismiss

    let eyebrow: String
    let title: String
    let onEdit: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            AsteriumPageHeader(eyebrow: eyebrow, title: title)

            Spacer(minLength: 12)

            HStack(spacing: 18) {
                Button(action: onEdit) {
                    Image("pencil")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(LGradients.header)
                }
                .buttonStyle(.plain)

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
        }
    }
}

// MARK: - Detail Scaffold

struct GrimoireDetailScaffold<Content: View>: View {
    let eyebrow: String
    let title: String
    let onEdit: () -> Void
    @ViewBuilder let content: Content

    init(
        eyebrow: String,
        title: String,
        onEdit: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.onEdit = onEdit
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
            GrimoireDetailHeader(eyebrow: eyebrow, title: title, onEdit: onEdit)
                .padding(.horizontal, LSpacing.pageHorizontal)

            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    content
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background { AsteriumBackground() }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Detail Row

struct GrimoireDetailRow: View {
    let label: String
    let value: String
    var usesFrostedTile = false
    var usesGradientValue = false

    var body: some View {
        if !value.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(LColors.textSecondary)
                Text(value)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(usesGradientValue ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.textPrimary))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, usesFrostedTile ? 14 : 0)
            .padding(.vertical, usesFrostedTile ? 12 : 0)
            .background {
                if usesFrostedTile {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LColors.glassSurface)
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(LColors.glassBorder, lineWidth: 1)
                        }
                }
            }
        }
    }
}

// MARK: - Detail Section

struct GrimoireDetailSection<Content: View>: View {
    let title: String?
    @ViewBuilder let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                AsteriumSectionHeader(title: title)
            }
            GlassCard {
                VStack(alignment: .leading, spacing: 18) {
                    content
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Detail Chips

struct GrimoireDetailChips: View {
    let label: String
    let items: [String]
    var showsLabel = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showsLabel {
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(LColors.textSecondary)
            }

            if items.isEmpty {
                Text("No \(label.lowercased())")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                Capsule().fill(LGradients.tag.opacity(0.55))
                            )
                            .overlay {
                                Capsule()
                                    .strokeBorder(LColors.glassBorder, lineWidth: 1)
                            }
                    }
                }
            }
        }
    }
}

// MARK: - Status Badge

struct GrimoireStatusBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(LGradients.tag)
            )
    }
}

// MARK: - Importance Dots

struct GrimoireImportanceDots: View {
    let value: Int
    var showsLabel = true

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if showsLabel {
                Text("IMPORTANCE")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(LColors.textSecondary)
            }

            HStack(spacing: 6) {
                ForEach(1...5, id: \.self) { i in
                    Circle()
                        .fill(i <= value ? AnyShapeStyle(LGradients.tag) : AnyShapeStyle(LColors.glassSurface))
                        .frame(width: 12, height: 12)
                        .overlay {
                            Circle()
                                .strokeBorder(i <= value ? Color.clear : LColors.glassBorder, lineWidth: 1)
                        }
                }
            }
        }
    }
}

// MARK: - Related Entries List

struct GrimoireRelatedEntriesList: View {
    let entries: [GrimoireRelatedEntry]
    var showsLabel = true

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

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if showsLabel {
                AsteriumSectionHeader(title: "Related Entries")
            }

            if entries.isEmpty {
                Text("No related entries")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
            } else {
                ForEach(entries, id: \.id) { relation in
                    if hasRelatedDestination(for: relation) {
                        NavigationLink {
                            relatedDestination(for: relation)
                        } label: {
                            relatedEntryRow(relation, isMissing: false)
                        }
                        .buttonStyle(.plain)
                    } else {
                        relatedEntryRow(relation, isMissing: true)
                    }
                }
            }
        }
    }

    private func relatedEntryRow(_ relation: GrimoireRelatedEntry, isMissing: Bool) -> some View {
        GlassCard(padding: 0) {
            HStack(spacing: 14) {
                Image(relation.relatedEntryType.icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(isMissing ? AnyShapeStyle(LColors.textSecondary) : AnyShapeStyle(LGradients.header))
                    .frame(width: 32, height: 32)
                    .background(LColors.glassSurface, in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(relation.relatedEntryTitle)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(isMissing ? LColors.textSecondary : LColors.textPrimary)
                        .lineLimit(1)

                    Text(isMissing ? "Linked entry unavailable" : relation.relatedEntryType.singularName)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                }

                Spacer()

                if isMissing == false {
                    Image("rightwavy")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(LGradients.header)
                }
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
    }

    private func hasRelatedDestination(for relation: GrimoireRelatedEntry) -> Bool {
        switch relation.relatedEntryType {
        case .journal:
            return journals.contains { $0.id == relation.relatedEntryID }
        case .experience:
            return experiences.contains { $0.id == relation.relatedEntryID }
        case .workingDocument:
            return workingDocuments.contains { $0.id == relation.relatedEntryID }
        case .workingResult:
            return workingResults.contains { $0.id == relation.relatedEntryID }
        case .dream:
            return dreams.contains { $0.id == relation.relatedEntryID }
        case .synchronicity:
            return synchronicities.contains { $0.id == relation.relatedEntryID }
        case .pathwork:
            return pathworks.contains { $0.id == relation.relatedEntryID }
        case .moonPhase:
            return moonPhases.contains { $0.id == relation.relatedEntryID }
        case .deityDevotion:
            return deityDevotions.contains { $0.id == relation.relatedEntryID }
        case .divination:
            return divinations.contains { $0.id == relation.relatedEntryID }
        case .meditation:
            return meditations.contains { $0.id == relation.relatedEntryID }
        case .shadowWork:
            return shadowWorks.contains { $0.id == relation.relatedEntryID }
        case .manifestation:
            return manifestations.contains { $0.id == relation.relatedEntryID }
        }
    }

    @ViewBuilder
    private func relatedDestination(for relation: GrimoireRelatedEntry) -> some View {
        switch relation.relatedEntryType {
        case .journal:
            if let entry = journals.first(where: { $0.id == relation.relatedEntryID }) {
                JournalEntryDetail(entry: entry)
            } else {
                EmptyView()
            }
        case .experience:
            if let entry = experiences.first(where: { $0.id == relation.relatedEntryID }) {
                ExperienceEntryDetail(entry: entry)
            } else {
                EmptyView()
            }
        case .workingDocument:
            if let entry = workingDocuments.first(where: { $0.id == relation.relatedEntryID }) {
                WorkingDocumentEntryDetail(entry: entry)
            } else {
                EmptyView()
            }
        case .workingResult:
            if let entry = workingResults.first(where: { $0.id == relation.relatedEntryID }) {
                WorkingResultEntryDetail(entry: entry)
            } else {
                EmptyView()
            }
        case .dream:
            if let entry = dreams.first(where: { $0.id == relation.relatedEntryID }) {
                DreamEntryDetail(entry: entry)
            } else {
                EmptyView()
            }
        case .synchronicity:
            if let entry = synchronicities.first(where: { $0.id == relation.relatedEntryID }) {
                SynchronicityEntryDetail(entry: entry)
            } else {
                EmptyView()
            }
        case .pathwork:
            if let entry = pathworks.first(where: { $0.id == relation.relatedEntryID }) {
                PathworkEntryDetail(entry: entry)
            } else {
                EmptyView()
            }
        case .moonPhase:
            if let entry = moonPhases.first(where: { $0.id == relation.relatedEntryID }) {
                MoonPhaseEntryDetail(entry: entry)
            } else {
                EmptyView()
            }
        case .deityDevotion:
            if let entry = deityDevotions.first(where: { $0.id == relation.relatedEntryID }) {
                DeityDevotionEntryDetail(entry: entry)
            } else {
                EmptyView()
            }
        case .divination:
            if let entry = divinations.first(where: { $0.id == relation.relatedEntryID }) {
                DivinationEntryDetail(entry: entry)
            } else {
                EmptyView()
            }
        case .meditation:
            if let entry = meditations.first(where: { $0.id == relation.relatedEntryID }) {
                MeditationEntryDetail(entry: entry)
            } else {
                EmptyView()
            }
        case .shadowWork:
            if let entry = shadowWorks.first(where: { $0.id == relation.relatedEntryID }) {
                ShadowWorkEntryDetail(entry: entry)
            } else {
                EmptyView()
            }
        case .manifestation:
            if let entry = manifestations.first(where: { $0.id == relation.relatedEntryID }) {
                ManifestationEntryDetail(entry: entry)
            } else {
                EmptyView()
            }
        }
    }
}

// MARK: - Universal Detail Footer

struct GrimoireDetailFooter: View {
    let importance: Int
    let tags: [String]
    var attachments: [GrimoireAttachment] = []
    let relatedEntries: [GrimoireRelatedEntry]
    let additionalNotes: String
    private var trimmedAdditionalNotes: String {
        additionalNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        Group {
            GrimoireDetailSection(title: "Importance") {
                GrimoireImportanceDots(value: importance, showsLabel: false)
            }

            GrimoireDetailSection(title: "Tags") {
                GrimoireDetailChips(label: "Tags", items: tags, showsLabel: false)
            }

            if !attachments.isEmpty {
                GrimoireDetailSection(title: "Attachments") {
                    GrimoireAttachmentGallery(attachments: attachments)
                }
            }

            GrimoireRelatedEntriesList(entries: relatedEntries)

            GrimoireDetailSection(title: "Additional Notes") {
                Text(trimmedAdditionalNotes.isEmpty ? "No additional notes" : trimmedAdditionalNotes)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(trimmedAdditionalNotes.isEmpty ? LColors.textSecondary : LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: ProposedViewSize(width: bounds.width, height: bounds.height), subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalHeight = y + rowHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}
