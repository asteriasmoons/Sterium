//
//  GrimoireNewEntryPicker.swift
//  Sterium
//

import SwiftUI
import SwiftData

struct GrimoireNewEntryPicker: View {
    let onSelect: (GrimoireEntryType) -> Void
    let onSelectCustom: (CustomGrimoireTemplate) -> Void
    let onManageCustom: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CustomGrimoireTemplate.updatedAt, order: .reverse) private var customTemplates: [CustomGrimoireTemplate]

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

                    HStack {
                        AsteriumSectionHeader(title: "Custom Entry Types")
                        Spacer()
                        Button {
                            onManageCustom()
                            dismiss()
                        } label: {
                            Image("cogwavy")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 21, height: 21)
                                .foregroundStyle(LGradients.header)
                                .frame(width: 36, height: 36)
                        }
                        .buttonStyle(.plain)
                    }

                    let activeCustomTemplates = customTemplates.filter { !$0.isArchived }
                    if activeCustomTemplates.isEmpty {
                        Button {
                            onManageCustom()
                            dismiss()
                        } label: {
                            GlassCard {
                                HStack(spacing: 12) {
                                    Image("addwavy")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 22, height: 22)
                                        .foregroundStyle(LGradients.header)
                                    Text("Build a Custom Entry Type")
                                        .font(.system(size: 14, weight: .black, design: .rounded))
                                        .foregroundStyle(LColors.textPrimary)
                                    Spacer()
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(activeCustomTemplates) { template in
                                Button {
                                    onSelectCustom(template)
                                    dismiss()
                                } label: {
                                    customEntryTypeCard(template)
                                }
                                .buttonStyle(.plain)
                            }
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
    private func customEntryTypeCard(_ template: CustomGrimoireTemplate) -> some View {
        GlassCard(cornerRadius: LSpacing.cardRadius, padding: LSpacing.cardPadding) {
            VStack(spacing: 12) {
                Image(template.iconName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(LGradients.header)

                Text(template.name)
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
