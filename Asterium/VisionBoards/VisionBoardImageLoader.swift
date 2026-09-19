//
//  VisionBoardImageLoader.swift
//  Sterium
//
//  Off-main-thread image downsampling with an in-memory cache so the masonry
//  grid never decodes full-resolution image data on the UI thread.
//

import UIKit
import ImageIO

final class VisionBoardImageLoader {
    static let shared = VisionBoardImageLoader()

    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 300
    }

    func thumbnail(for id: UUID, data: Data, maxPixel: CGFloat) async -> UIImage? {
        let key = "\(id.uuidString)@\(Int(maxPixel))" as NSString
        if let cached = cache.object(forKey: key) { return cached }

        let image = await Task.detached(priority: .utility) {
            Self.downsample(data: data, maxPixel: maxPixel)
        }.value

        if let image { cache.setObject(image, forKey: key) }
        return image
    }

    func fullImage(data: Data) async -> UIImage? {
        await Task.detached(priority: .userInitiated) {
            UIImage(data: data)
        }.value
    }

    private static func downsample(data: Data, maxPixel: CGFloat) -> UIImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else {
            return UIImage(data: data)
        }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: max(1, maxPixel)
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return UIImage(data: data)
        }
        return UIImage(cgImage: cgImage)
    }
}
