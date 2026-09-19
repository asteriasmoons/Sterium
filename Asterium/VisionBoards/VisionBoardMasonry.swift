//
//  VisionBoardMasonry.swift
//  Sterium
//
//  Pinterest-style staggered masonry. Item heights come from each image's
//  stored width/height, so column distribution needs no image decoding.
//

import SwiftUI

struct VisionBoardMasonry: View {
    let images: [VisionBoardImage]
    var columns: Int = 2
    var spacing: CGFloat = 12
    let onTap: (VisionBoardImage) -> Void

    @State private var containerWidth: CGFloat = 0

    private var columnWidth: CGFloat {
        guard containerWidth > 0 else { return 0 }
        return max(1, (containerWidth - spacing * CGFloat(columns - 1)) / CGFloat(columns))
    }

    private var distributed: [[VisionBoardImage]] {
        var buckets = Array(repeating: [VisionBoardImage](), count: columns)
        var heights = Array(repeating: CGFloat(0), count: columns)
        for image in images {
            let index = heights.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            buckets[index].append(image)
            heights[index] += columnWidth / CGFloat(image.aspectRatio) + spacing
        }
        return buckets
    }

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            if columnWidth > 0 {
                ForEach(0..<columns, id: \.self) { column in
                    LazyVStack(spacing: spacing) {
                        ForEach(distributed[column]) { image in
                            VisionBoardImageCell(image: image, width: columnWidth) {
                                onTap(image)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(widthReader)
    }

    private var widthReader: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear { containerWidth = proxy.size.width }
                .onChange(of: proxy.size.width) { _, newValue in containerWidth = newValue }
        }
    }
}

struct VisionBoardImageCell: View {
    let image: VisionBoardImage
    let width: CGFloat
    let onTap: () -> Void

    @Environment(\.displayScale) private var displayScale
    @State private var thumbnail: UIImage?

    private var height: CGFloat { width / CGFloat(image.aspectRatio) }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if let thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                } else {
                    LColors.glassSurface
                }
            }
            .frame(width: width, height: max(1, height))
            .clipShape(RoundedRectangle(cornerRadius: LSpacing.cardRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: LSpacing.cardRadius, style: .continuous)
                    .strokeBorder(LColors.glassBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .task(id: image.id) {
            thumbnail = await VisionBoardImageLoader.shared.thumbnail(
                for: image.id,
                data: image.imageData,
                maxPixel: width * displayScale
            )
        }
    }
}
