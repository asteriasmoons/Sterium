//
//  ReleaseNotesView.swift
//  Sterium
//

import SwiftUI

struct ReleaseNotesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedIds: Set<String>

    init() {
        _expandedIds = State(
            initialValue: Set([ReleaseNotesLibrary.latest?.id].compactMap { $0 })
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                header
                whatChangedCard

                ForEach(ReleaseNotesLibrary.all) { note in
                    versionCard(note)
                }
            }
            .padding(.horizontal, LSpacing.pageHorizontal)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background { AsteriumBackground() }
        .onAppear {
            ReleaseNotesTracker.markLatestSeen()
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Release Notes")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Everything new, collected in one place.")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
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

    private var whatChangedCard: some View {
        GlassCard(cornerRadius: 24) {
            HStack(spacing: 14) {
                Image("timebook")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(LGradients.header)
                    .frame(width: 54, height: 54)
                    .background(LColors.glassSurface, in: Circle())
                    .overlay {
                        Circle().strokeBorder(LColors.glassBorder, lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text("What changed")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)

                    Text("Open any update to see the highlights in the app's glass style.")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func versionCard(_ note: ReleaseNote) -> some View {
        let isExpanded = expandedIds.contains(note.id)

        return GlassCard(cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(note.version)
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)

                        Text(note.build)
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(LGradients.header)

                        Text(note.date)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(LColors.textSecondary)
                    }

                    Spacer()

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.84)) {
                            if isExpanded {
                                expandedIds.remove(note.id)
                            } else {
                                expandedIds.insert(note.id)
                            }
                        }
                    } label: {
                        ZStack {
                            ScallopedSeal()
                                .fill(LGradients.header)
                                .frame(width: 34, height: 34)

                            Image(isExpanded ? "chevup" : "chevdown")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 13, height: 13)
                                .foregroundStyle(LColors.bg)
                        }
                    }
                    .buttonStyle(.plain)
                }

                Text(note.summary)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if isExpanded {
                    DottedLine()
                        .stroke(
                            LColors.glassBorder,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [1, 9])
                        )
                        .frame(height: 3)
                        .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(Array(note.highlights.enumerated()), id: \.offset) { _, highlight in
                            HStack(alignment: .top, spacing: 12) {
                                Circle()
                                    .fill(LGradients.header)
                                    .frame(width: 8, height: 8)
                                    .padding(.top, 6)

                                Text(highlight)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(LColors.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct ScallopedSeal: Shape {
    var bumps: Int = 12
    var depth: CGFloat = 0.08

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2
        let amplitude = baseRadius * depth
        let steps = max(bumps * 14, 56)

        var path = Path()
        for index in 0...steps {
            let progress = CGFloat(index) / CGFloat(steps)
            let angle = progress * 2 * .pi
            let radius = baseRadius - amplitude + amplitude * cos(CGFloat(bumps) * angle)
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )

            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

private struct DottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}
