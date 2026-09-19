//
//  ShareImageLoader.swift
//  SteriumShare
//
//  Robust NSItemProvider handling: obtains the actual image bytes and copies
//  them into memory immediately so nothing depends on a temporary provider URL.
//

import Foundation
import UniformTypeIdentifiers
import ImageIO
import UIKit

struct LoadedShareImage {
    let data: Data
    let width: Double
    let height: Double
    let contentType: String?
    let filename: String?
    let sourceURL: String?
}

enum ShareLoadError: LocalizedError {
    case noImage
    case providerFailed
    case decodeFailed

    var errorDescription: String? {
        switch self {
        case .noImage: return "That share didn't include an image Sterium can import."
        case .providerFailed: return "Sterium couldn't read the shared image."
        case .decodeFailed: return "The shared image could not be decoded."
        }
    }
}

enum ShareImageLoader {
    static func loadImage(from providers: [NSItemProvider]) async throws -> LoadedShareImage {
        let sourceURL = await loadSourceURL(from: providers)

        // Instagram often includes a cropped image payload alongside the actual post URL.
        // Prefer resolving the post page first so Sterium stores the full post image instead.
        if let urlString = sourceURL,
           let pageURL = URL(string: urlString),
           isInstagramURL(pageURL) {
            let resolved = try await resolveInstagramImageData(from: pageURL)

            guard let size = pixelSize(of: resolved.data) else {
                throw ShareLoadError.decodeFailed
            }

            return LoadedShareImage(
                data: resolved.data,
                width: Double(size.width),
                height: Double(size.height),
                contentType: contentType(of: resolved.data),
                filename: resolved.imageURL.lastPathComponent,
                sourceURL: urlString
            )
        }

        // 1. A direct image payload (Photos, Files, Safari "Share Image", etc.).
        if let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }) {
            let data = try await loadData(from: provider)

            guard let size = pixelSize(of: data) else {
                throw ShareLoadError.decodeFailed
            }

            return LoadedShareImage(
                data: data,
                width: Double(size.width),
                height: Double(size.height),
                contentType: contentType(of: data),
                filename: provider.suggestedName,
                sourceURL: sourceURL
            )
        }

        // 2. A web-URL payload (Safari page share, Pinterest, etc.). A shared URL
        //    usually points to an HTML page, not directly to image bytes. Resolve the
        //    page's social-preview image, then copy those image bytes into Sterium.
        if let urlString = sourceURL, let pageURL = URL(string: urlString) {
            let resolved = try await resolveImageData(from: pageURL)

            guard let size = pixelSize(of: resolved.data) else {
                throw ShareLoadError.decodeFailed
            }

            return LoadedShareImage(
                data: resolved.data,
                width: Double(size.width),
                height: Double(size.height),
                contentType: contentType(of: resolved.data),
                filename: resolved.imageURL.lastPathComponent,
                sourceURL: urlString
            )
        }

        throw ShareLoadError.noImage
    }

    static func isInstagramURL(_ url: URL) -> Bool {
        guard let host = url.host?.lowercased() else { return false }
        return host == "instagram.com" ||
               host.hasSuffix(".instagram.com") ||
               host == "instagr.am" ||
               host.hasSuffix(".instagr.am")
    }

    private static func resolveInstagramImageData(from pageURL: URL) async throws -> (data: Data, imageURL: URL) {
        let canonicalURL = instagramCanonicalURL(from: pageURL)
        let pageURLs = canonicalURL == pageURL ? [pageURL] : [canonicalURL, pageURL]

        for candidatePageURL in pageURLs {
            guard let html = try? await loadInstagramHTML(from: candidatePageURL) else { continue }
            let imageURLs = extractInstagramImageURLs(from: html)

            for imageURL in imageURLs {
                if let imageData = try? await downloadInstagramImageData(from: imageURL, pageURL: candidatePageURL) {
                    return (imageData, imageURL)
                }
            }
        }

        throw ShareLoadError.providerFailed
    }

    private static func loadInstagramHTML(from pageURL: URL) async throws -> String {
        var request = URLRequest(url: pageURL)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 Version/26.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,*/*;q=0.8", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) == false {
            throw ShareLoadError.providerFailed
        }
        guard let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
            throw ShareLoadError.providerFailed
        }
        return html
    }

    private static func instagramCanonicalURL(from url: URL) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
        components.query = nil
        components.fragment = nil
        return components.url ?? url
    }

    private static func extractInstagramImageURLs(from html: String) -> [URL] {
        guard let marker = html.range(of: #"image_versions2":{"candidates":["#) else { return [] }
        let remainder = html[marker.upperBound...]
        guard let end = remainder.firstIndex(of: "]") else { return [] }
        let block = String(remainder[..<end])

        guard let regex = try? NSRegularExpression(pattern: #"\"url\":\"([^\"]+)\""#) else { return [] }
        let range = NSRange(block.startIndex..<block.endIndex, in: block)

        return regex.matches(in: block, range: range).compactMap { match in
            guard let valueRange = Range(match.range(at: 1), in: block) else { return nil }
            var value = String(block[valueRange])
            value = value.replacingOccurrences(of: #"\/"#, with: "/")
                         .replacingOccurrences(of: #"\u00253D"#, with: "%3D")
                         .replacingOccurrences(of: #"\u0026"#, with: "&")
                         .replacingOccurrences(of: "&amp;", with: "&")
            return URL(string: value)
        }
    }

    private static func downloadInstagramImageData(from url: URL, pageURL: URL) async throws -> Data {
        let referers: [String?] = [nil, "https://www.instagram.com/", pageURL.absoluteString]

        for referer in referers {
            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 Version/26.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
            request.setValue("image/avif,image/webp,image/*,*/*;q=0.8", forHTTPHeaderField: "Accept")
            if let referer { request.setValue(referer, forHTTPHeaderField: "Referer") }

            guard let (data, response) = try? await URLSession.shared.data(for: request),
                  let http = response as? HTTPURLResponse,
                  (200..<300).contains(http.statusCode),
                  data.isEmpty == false,
                  pixelSize(of: data) != nil
            else { continue }

            return data
        }

        throw ShareLoadError.providerFailed
    }

    private static func resolveImageData(from pageURL: URL) async throws -> (data: Data, imageURL: URL) {
        var request = URLRequest(url: pageURL)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 Version/26.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,image/avif,image/webp,image/*,*/*;q=0.8", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) == false {
            throw ShareLoadError.providerFailed
        }

        // Some apps do share a direct image URL. Keep that fast path.
        if pixelSize(of: data) != nil {
            return (data, pageURL)
        }

        guard let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1),
              let imageURL = extractPreviewImageURL(from: html, relativeTo: pageURL)
        else {
            throw ShareLoadError.noImage
        }

        let imageData = try await downloadDirectImageData(from: imageURL, referer: pageURL)
        return (imageData, imageURL)
    }

    private static func downloadDirectImageData(from url: URL, referer: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 Version/26.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue(referer.absoluteString, forHTTPHeaderField: "Referer")
        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) == false {
            throw ShareLoadError.providerFailed
        }
        guard data.isEmpty == false, pixelSize(of: data) != nil else {
            throw ShareLoadError.noImage
        }
        return data
    }

    private static func extractPreviewImageURL(from html: String, relativeTo pageURL: URL) -> URL? {
        let patterns = [
            #"<meta[^>]+(?:property|name)=[\"']og:image(?::secure_url)?[\"'][^>]+content=[\"']([^\"']+)[\"']"#,
            #"<meta[^>]+content=[\"']([^\"']+)[\"'][^>]+(?:property|name)=[\"']og:image(?::secure_url)?[\"']"#,
            #"<meta[^>]+(?:property|name)=[\"']twitter:image(?::src)?[\"'][^>]+content=[\"']([^\"']+)[\"']"#,
            #"<meta[^>]+content=[\"']([^\"']+)[\"'][^>]+(?:property|name)=[\"']twitter:image(?::src)?[\"']"#,
            #"<link[^>]+rel=[\"']image_src[\"'][^>]+href=[\"']([^\"']+)[\"']"#
        ]

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { continue }
            let range = NSRange(html.startIndex..., in: html)
            guard let match = regex.firstMatch(in: html, range: range), match.numberOfRanges > 1,
                  let valueRange = Range(match.range(at: 1), in: html) else { continue }

            var value = String(html[valueRange])
            value = value.replacingOccurrences(of: "&amp;", with: "&")
                         .replacingOccurrences(of: "&#x2F;", with: "/")
                         .replacingOccurrences(of: "&#47;", with: "/")
            if let absolute = URL(string: value, relativeTo: pageURL)?.absoluteURL {
                return absolute
            }
        }
        return nil
    }

    // MARK: - Byte acquisition

    private static func loadData(from provider: NSItemProvider) async throws -> Data {
        let typeID = bestImageTypeIdentifier(for: provider)

        if let data = try? await loadDataRepresentation(provider, typeID) {
            return data
        }
        if let data = try? await loadFileData(provider, typeID) {
            return data
        }
        if let data = try await loadUIImageData(provider) {
            return data
        }
        throw ShareLoadError.providerFailed
    }

    private static func bestImageTypeIdentifier(for provider: NSItemProvider) -> String {
        let preferred: [UTType] = [.png, .jpeg, .heic, .heif, .gif, .tiff, .webP]
        let registered = provider.registeredTypeIdentifiers
        for type in preferred where registered.contains(type.identifier) {
            return type.identifier
        }
        for id in registered {
            if let type = UTType(id), type.conforms(to: .image) {
                return id
            }
        }
        return UTType.image.identifier
    }

    private static func loadDataRepresentation(_ provider: NSItemProvider, _ typeID: String) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadDataRepresentation(forTypeIdentifier: typeID) { data, error in
                if let data, data.isEmpty == false {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: error ?? ShareLoadError.providerFailed)
                }
            }
        }
    }

    private static func loadFileData(_ provider: NSItemProvider, _ typeID: String) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadFileRepresentation(forTypeIdentifier: typeID) { url, error in
                // The URL is only valid inside this callback — copy the bytes now.
                if let url, let data = try? Data(contentsOf: url), data.isEmpty == false {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: error ?? ShareLoadError.providerFailed)
                }
            }
        }
    }

    private static func loadUIImageData(_ provider: NSItemProvider) async throws -> Data? {
        guard provider.canLoadObject(ofClass: UIImage.self) else { return nil }
        let image: UIImage = try await withCheckedThrowingContinuation { continuation in
            provider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: error ?? ShareLoadError.providerFailed)
                }
            }
        }
        return image.jpegData(compressionQuality: 0.95) ?? image.pngData()
    }

    static func loadSourceURL(from providers: [NSItemProvider]) async -> String? {
        var fallbackURL: String?
        let preferredTypeIDs = [
            UTType.url.identifier,
            UTType.plainText.identifier,
            UTType.text.identifier
        ]

        for provider in providers {
            var typeIDs = preferredTypeIDs.filter {
                provider.hasItemConformingToTypeIdentifier($0)
            }

            for registeredID in provider.registeredTypeIdentifiers {
                guard !typeIDs.contains(registeredID),
                      let type = UTType(registeredID),
                      type.conforms(to: .url) || type.conforms(to: .text)
                else { continue }
                typeIDs.append(registeredID)
            }

            for typeID in typeIDs {
                guard let candidate = await loadURLCandidate(from: provider, typeIdentifier: typeID),
                      let url = URL(string: candidate)
                else { continue }

                // If Instagram supplied its post URL as text instead of public.url,
                // make sure that URL wins before its cropped image attachment can.
                if isInstagramURL(url) {
                    return url.absoluteString
                }
                if fallbackURL == nil {
                    fallbackURL = url.absoluteString
                }
            }
        }

        return fallbackURL
    }

    private static func loadURLCandidate(from provider: NSItemProvider, typeIdentifier: String) async -> String? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { item, error in
                guard error == nil else {
                    continuation.resume(returning: nil)
                    return
                }

                let rawValue: String?
                if let url = item as? URL {
                    rawValue = url.absoluteString
                } else if let string = item as? String {
                    rawValue = string
                } else if let string = item as? NSString {
                    rawValue = string as String
                } else if let data = item as? Data {
                    rawValue = String(data: data, encoding: .utf8)
                } else {
                    rawValue = nil
                }

                continuation.resume(returning: rawValue.flatMap(extractURLString(from:)))
            }
        }
    }

    private static func extractURLString(from text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let url = URL(string: trimmed),
           let scheme = url.scheme?.lowercased(),
           scheme == "http" || scheme == "https" {
            return url.absoluteString
        }

        let punctuation = CharacterSet(charactersIn: "<>\"'()[]{}.,;")
        for token in trimmed.components(separatedBy: .whitespacesAndNewlines) {
            let candidate = token.trimmingCharacters(in: punctuation)
            guard let url = URL(string: candidate),
                  let scheme = url.scheme?.lowercased(),
                  scheme == "http" || scheme == "https"
            else { continue }
            return url.absoluteString
        }
        return nil
    }

    // MARK: - Metadata (no full decode)

    private static func pixelSize(of data: Data) -> CGSize? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        else { return nil }
        let width = (props[kCGImagePropertyPixelWidth] as? NSNumber)?.doubleValue ?? 0
        let height = (props[kCGImagePropertyPixelHeight] as? NSNumber)?.doubleValue ?? 0
        guard width > 0, height > 0 else { return nil }
        return CGSize(width: width, height: height)
    }

    private static func contentType(of data: Data) -> String? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let uti = CGImageSourceGetType(source)
        else { return nil }
        return uti as String
    }
}
