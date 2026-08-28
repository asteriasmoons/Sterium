//
//  CorrespondencesView.swift
//  Asterium
//

import SwiftUI

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
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var generatedEntry: CorrespondenceEntryResponse?
    @State private var savedEntries: [CorrespondenceEntryResponse] = []

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

                if let generatedEntry {
                    VStack(alignment: .leading, spacing: 12) {
                        AsteriumSectionHeader(title: "Generated")
                        NavigationLink {
                            CorrespondenceEntryDetailView(
                                type: type,
                                entry: generatedEntry
                            )
                        } label: {
                            correspondenceEntryRow(generatedEntry)
                        }
                        .buttonStyle(.plain)
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
            savedEntries = service.savedEntries(for: type)
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
                Image(type.icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(LGradients.header)

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
                        CorrespondenceEntryDetailView(type: type, entry: entry)
                    } label: {
                        correspondenceEntryRow(entry)
                    }
                    .buttonStyle(.plain)
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

    private func generate() async {
        let trimmedName = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.isEmpty == false, isLoading == false else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let entry = try await service.generate(type: type, name: trimmedName)
            generatedEntry = entry
            savedEntries = service.savedEntries(for: type)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

private struct CorrespondenceEntryDetailView: View {
    let type: CorrespondenceType
    let entry: CorrespondenceEntryResponse

    @Environment(\.dismiss) private var dismiss

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
