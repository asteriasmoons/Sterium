//
//  InstagramCarouselResolver.swift
//  SteriumShare
//
//  Separate Instagram carousel path. The existing single-image resolver stays
//  responsible for ordinary posts; this only returns when a real sidecar exists.
//

import Foundation
import ImageIO

private struct InstagramCarouselItem {
    let imageURL: URL
}

enum InstagramCarouselResolver {
    static func resolve(
        from pageURL: URL,
        sourceURLString: String
    ) async throws -> [LoadedShareImage]? {
        guard let embedURL = embedURL(from: pageURL) else { return nil }
        let html = try await loadEmbedHTML(from: embedURL)
        let itemURLs = extractCarouselImageURLs(from: html)
        guard itemURLs.count > 1 else { return nil }

        var images: [LoadedShareImage] = []
        images.reserveCapacity(itemURLs.count)
        for imageURL in itemURLs {
            let data = try await downloadImage(
                from: imageURL,
                referer: embedURL
            )
            guard let size = pixelSize(of: data) else {
                throw ShareLoadError.decodeFailed
            }

            images.append(
                LoadedShareImage(
                    data: data,
                    width: Double(size.width),
                    height: Double(size.height),
                    contentType: contentType(of: data),
                    filename: imageURL.lastPathComponent,
                    sourceURL: sourceURLString
                )
            )
        }

        return images
    }

    private static func embedURL(from pageURL: URL) -> URL? {
        guard var components = URLComponents(url: pageURL, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.query = nil
        components.fragment = nil
        var path = components.path
        if !path.hasSuffix("/") { path += "/" }
        components.path = path + "embed/"
        return components.url
    }

    private static func loadEmbedHTML(from url: URL) async throws -> String {
        var request = URLRequest(url: url)
        request.timeoutInterval = 8
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 Version/26.0 Mobile/15E148 Safari/604.1",
            forHTTPHeaderField: "User-Agent"
        )
        request.setValue("text/html,*/*;q=0.8", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode),
              let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1)
        else {
            throw ShareLoadError.providerFailed
        }
        return html
    }
    private static func extractCarouselImageURLs(from html: String) -> [URL] {
        guard let marker = html.range(of: "edge_sidecar_to_children") else { return [] }
        let prefix = html[..<marker.lowerBound]
        guard let handle = prefix.range(of: "s.handle(", options: .backwards),
              let jsonString = balancedJSONObject(in: html, startingAt: handle.upperBound),
              let data = jsonString.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data),
              let edges = findSidecarEdges(in: object)
        else { return [] }

        return edges.compactMap { edge in
            guard let node = edge["node"] as? [String: Any],
                  (node["is_video"] as? Bool) != true,
                  let value = node["display_url"] as? String
            else { return nil }
            return URL(string: value)
        }
    }

    private static func findSidecarEdges(in value: Any) -> [[String: Any]]? {
        if let dictionary = value as? [String: Any] {
            if let sidecar = dictionary["edge_sidecar_to_children"] as? [String: Any],
               let edges = sidecar["edges"] as? [[String: Any]] {
                return edges
            }
            for child in dictionary.values {
                if let found = findSidecarEdges(in: child) { return found }
            }
            return nil
        }

        if let array = value as? [Any] {
            for child in array {
                if let found = findSidecarEdges(in: child) { return found }
            }
            return nil
        }

        if let string = value as? String,
           string.contains("edge_sidecar_to_children"),
           let data = string.data(using: .utf8),
           let nested = try? JSONSerialization.jsonObject(with: data) {
            return findSidecarEdges(in: nested)
        }

        return nil
    }

    private static func balancedJSONObject(
        in text: String,
        startingAt start: String.Index
    ) -> String? {
        var index = start
        var objectStart: String.Index?
        var depth = 0
        var inString = false
        var escaped = false

        while index < text.endIndex {
            let character = text[index]

            if inString {
                if escaped {
                    escaped = false
                } else if character == "\\" {
                    escaped = true
                } else if character == "\"" {
                    inString = false
                }
            } else if character == "\"" {
                inString = true
            } else if character == "{" {
                if objectStart == nil { objectStart = index }
                depth += 1
            } else if character == "}", objectStart != nil {
                depth -= 1
                if depth == 0, let objectStart {
                    return String(text[objectStart...index])
                }
            }

            index = text.index(after: index)
        }

        return nil
    }

    private static func downloadImage(from url: URL, referer: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 Version/26.0 Mobile/15E148 Safari/604.1",
            forHTTPHeaderField: "User-Agent"
        )
        request.setValue("image/avif,image/webp,image/*,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue(referer.absoluteString, forHTTPHeaderField: "Referer")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode),
              !data.isEmpty,
              pixelSize(of: data) != nil
        else {
            throw ShareLoadError.providerFailed
        }
        return data
    }

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
