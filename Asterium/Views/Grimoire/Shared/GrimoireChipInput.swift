
//
//  GrimoireChipInput.swift
//  Asterium
//

import SwiftUI

struct GrimoireChipInput: View {
    let title: String
    let placeholder: String
    @Binding var items: [String]
    @State private var newItem: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            if !items.isEmpty {
                GrimoireFlowLayout(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        chipPill(item)
                    }
                }
            }

            HStack(spacing: 10) {
                TextField(placeholder, text: $newItem)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .onSubmit {
                        addItem()
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
    private func chipPill(_ item: String) -> some View {
        HStack(spacing: 6) {
            Text(item)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(LColors.textPrimary)

            Button {
                items.removeAll { $0 == item }
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

    private func addItem() {
        let trimmed = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !items.contains(trimmed) else {
            newItem = ""
            return
        }
        items.append(trimmed)
        newItem = ""
    }
}
