//
//  VisionBoardStore.swift
//  Sterium
//
//  Image utility helpers shared between the main app and the SteriumShare
//  extension. Vision Boards now live in Sterium's single shared SwiftData
//  store (see SteriumShared) — there is no separate Vision Board database.
//

import Foundation
import CoreGraphics
import ImageIO

enum VisionBoardStore {
    /// Pixel dimensions of encoded image data without a full decode.
    static func pixelSize(of data: Data) -> CGSize? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        else { return nil }
        let width = (props[kCGImagePropertyPixelWidth] as? NSNumber)?.doubleValue ?? 0
        let height = (props[kCGImagePropertyPixelHeight] as? NSNumber)?.doubleValue ?? 0
        guard width > 0, height > 0 else { return nil }
        return CGSize(width: width, height: height)
    }

    /// Best-effort UTType identifier for encoded image data.
    static func contentType(of data: Data) -> String? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let uti = CGImageSourceGetType(source)
        else { return nil }
        return uti as String
    }
}
