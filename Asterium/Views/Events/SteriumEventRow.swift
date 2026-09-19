//
//  SteriumEventRow.swift
//  Sterium
//
//  Shared event building blocks: the gradient-bordered frost tile, the
//  iconized section header, the event row, and the empty state.
//

import SwiftUI

// MARK: - Frost tile (gradient-bordered glass)

struct SteriumFrostTile<Content: View>: View {
    var cornerRadius: CGFloat = 18
    var padding: CGFloat = 14
    var alignment: Alignment = .leading
    @ViewBuilder var content: Content

    var body: some View {
        GlassCard(cornerRadius: cornerRadius, padding: padding) {
            content
                .frame(maxWidth: .infinity, alignment: alignment)
        }
    }
}

// MARK: - Section header (icon + title)

struct SteriumEventSectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(LGradients.header)
            Text(title)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 6)
    }
}

// MARK: - Event row

struct SteriumEventRow: View {
    let occurrence: SteriumEventOccurrence
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            SteriumFrostTile(cornerRadius: 20, padding: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.10))
                            .frame(width: 44, height: 44)
                        Image(occurrence.iconName)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundStyle(LGradients.header)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text(occurrence.title.isEmpty ? "Untitled Event" : occurrence.title)
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 6) {
                            Circle()
                                .fill(LGradients.header)
                                .frame(width: 7, height: 7)
                            Text(occurrence.timeSubtitle)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(LColors.textSecondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer(minLength: 8)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Empty state

struct SteriumEventsEmptyState: View {
    let title: String
    let subtitle: String

    var body: some View {
        SteriumFrostTile(cornerRadius: 18, padding: 18, alignment: .center) {
            VStack(spacing: 8) {
                Image("starcal")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)
                    .foregroundStyle(LGradients.header)
                Text(title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
