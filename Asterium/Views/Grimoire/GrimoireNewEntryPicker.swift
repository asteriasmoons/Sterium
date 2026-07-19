
//
//  GrimoireNewEntryPicker.swift
//  Asterium
//

import SwiftUI

struct GrimoireNewEntryPicker: View {
    let onSelect: (GrimoireEntryType) -> Void
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            AsteriumBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    HStack(alignment: .center) {
                        AsteriumPageHeader(eyebrow: "Grimoire", title: "New Entry")

                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Image("xmarkwavy")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(LGradients.header)
                        }
                        .buttonStyle(.plain)
                    }

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(GrimoireEntryType.allCases, id: \.self) { type in
                            Button {
                                onSelect(type)
                                dismiss()
                            } label: {
                                entryTypeCard(type)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 40)
            }
        }
        .presentationBackground(LColors.bg)
    }

    @ViewBuilder
    private func entryTypeCard(_ type: GrimoireEntryType) -> some View {
        GlassCard(cornerRadius: LSpacing.cardRadius, padding: LSpacing.cardPadding) {
            VStack(spacing: 12) {
                Image(type.icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(LGradients.header)

                Text(type.displayName)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 80)
        }
    }
}
