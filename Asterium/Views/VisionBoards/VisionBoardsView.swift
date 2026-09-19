//
//  VisionBoardsView.swift
//  Sterium
//

import SwiftUI
import SwiftData

struct VisionBoardsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \VisionBoard.updatedAt, order: .reverse)
    private var boards: [VisionBoard]

    @State private var showingCreate = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    HStack(alignment: .center) {
                        AsteriumPageHeader(eyebrow: "YOUR", title: "Vision Boards")
                        Spacer()
                        Button { showingCreate = true } label: {
                            Image("addwavy")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(LGradients.header)
                        }
                        .buttonStyle(.plain)
                    }

                    if boards.isEmpty {
                        emptyState
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(boards) { board in
                                NavigationLink {
                                    VisionBoardDetailView(board: board)
                                } label: {
                                    VisionBoardCard(board: board)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
            .asteriumAdaptivePresentation(isPresented: $showingCreate) {
                VisionBoardCreateEditView()
            }
        }
    }

    private var emptyState: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image("artboard")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .foregroundStyle(LGradients.header)

                Text("Start a visual collection")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)

                Text("Create a vision board to gather images that inspire your practice. You can add images here or share them straight into Sterium from Pinterest, Safari, Photos, and more.")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                AsteriumPrimaryButton(title: "Create Board", asset: "addwavy") {
                    showingCreate = true
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
}

private struct VisionBoardCard: View {
    let board: VisionBoard

    var body: some View {
        GlassCard(cornerRadius: 18, padding: 12) {
            VStack(alignment: .leading, spacing: 10) {
                VisionBoardCover(images: Array(board.sortedImages.prefix(4)))
                    .frame(height: 150)

                Text(board.name.isEmpty ? "Untitled Board" : board.name)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .lineLimit(1)

                Text("\(board.imageCount) image\(board.imageCount == 1 ? "" : "s")")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(LGradients.header)

                if board.boardDescription.isEmpty == false {
                    Text(board.boardDescription)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct VisionBoardCover: View {
    let images: [VisionBoardImage]

    var body: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 4
            let cell = (proxy.size.width - spacing) / 2
            if images.isEmpty {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(LColors.glassSurface)
                    .overlay {
                        Image("artboard")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(LColors.textSecondary)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(LColors.glassBorder, lineWidth: 1)
                    }
            } else {
                LazyVGrid(
                    columns: [GridItem(.fixed(cell), spacing: spacing), GridItem(.fixed(cell), spacing: spacing)],
                    spacing: spacing
                ) {
                    ForEach(images) { image in
                        VisionBoardSquareThumbnail(image: image, side: cell)
                    }
                }
            }
        }
    }
}

struct VisionBoardSquareThumbnail: View {
    let image: VisionBoardImage
    let side: CGFloat

    @Environment(\.displayScale) private var displayScale
    @State private var thumbnail: UIImage?

    var body: some View {
        ZStack {
            if let thumbnail {
                Image(uiImage: thumbnail).resizable().scaledToFill()
            } else {
                LColors.glassSurface
            }
        }
        .frame(width: side, height: side)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .task(id: image.id) {
            thumbnail = await VisionBoardImageLoader.shared.thumbnail(
                for: image.id,
                data: image.imageData,
                maxPixel: side * displayScale
            )
        }
    }
}
