
//
//  GrimoireDetailRow.swift
//  Asterium
//

import SwiftUI

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

    var body: some View {
        if !value.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(LColors.textSecondary)
                Text(value)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
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

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(LColors.textSecondary)

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

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("IMPORTANCE")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(LColors.textSecondary)

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

    var body: some View {
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("RELATED ENTRIES")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(LColors.textSecondary)

                ForEach(entries, id: \.id) { relation in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(relation.relatedEntryType.color)
                            .frame(width: 8, height: 8)
                        Text(relation.relatedEntryTitle)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                        Spacer()
                        Text(relation.relatedEntryType.displayName)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(LColors.textSecondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

// MARK: - Universal Detail Footer

struct GrimoireDetailFooter: View {
    let importance: Int
    let tags: [String]
    let relatedEntries: [GrimoireRelatedEntry]
    let additionalNotes: String

    var body: some View {
        let hasContent = importance > 0 || !tags.isEmpty || !relatedEntries.isEmpty || !additionalNotes.isEmpty
        if hasContent {
            GrimoireDetailSection {
                GrimoireImportanceDots(value: importance)
                GrimoireDetailChips(label: "Tags", items: tags)
                GrimoireRelatedEntriesList(entries: relatedEntries)
                GrimoireDetailRow(label: "Additional Notes", value: additionalNotes)
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
