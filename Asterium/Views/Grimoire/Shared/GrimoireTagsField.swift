
//
//  GrimoireTagsField.swift
//  Asterium
//

import SwiftUI

struct GrimoireTagsField: View {
    @Binding var tags: [String]
    @State private var newTag: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TAGS")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            if !tags.isEmpty {
                GrimoireFlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        tagPill(tag)
                    }
                }
            }

            HStack(spacing: 10) {
                TextField("Add tag...", text: $newTag)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .onSubmit {
                        addTag()
                    }
            }
            .padding(14)
            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.inputRadius))
            .overlay {
                RoundedRectangle(cornerRadius: LSpacing.inputRadius)
                    .strokeBorder(LColors.glassBorder, lineWidth: 1)
            }
        }
    }

    @ViewBuilder
    private func tagPill(_ tag: String) -> some View {
        HStack(spacing: 6) {
            Text("#\(tag)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(LColors.textPrimary)

            Button {
                tags.removeAll { $0 == tag }
            } label: {
                Text("\u{2715}")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(LColors.glassSurface)
        )
        .overlay {
            Capsule()
                .strokeBorder(LGradients.tag, lineWidth: 1)
        }
    }

    private func addTag() {
        let trimmed = newTag
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        guard !trimmed.isEmpty, !tags.contains(trimmed) else {
            newTag = ""
            return
        }
        tags.append(trimmed)
        newTag = ""
    }
}

// MARK: - Flow Layout

struct GrimoireFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var height: CGFloat = 0
        for (index, row) in rows.enumerated() {
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            height += rowHeight
            if index < rows.count - 1 {
                height += spacing
            }
        }
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubviews.Element]] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [[LayoutSubviews.Element]] = [[]]
        var currentRowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentRowWidth + size.width + spacing > maxWidth, !rows[rows.count - 1].isEmpty {
                rows.append([])
                currentRowWidth = 0
            }
            rows[rows.count - 1].append(subview)
            currentRowWidth += size.width + spacing
        }
        return rows
    }
}
