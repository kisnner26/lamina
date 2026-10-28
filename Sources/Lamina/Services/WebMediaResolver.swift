import Foundation

actor WebMediaResolver {
    func resolve(
        deck: DeckIR,
        in directory: URL,
        budget: GenerationBudget
    ) async -> DeckIR {
        var resolvedDeck = deck
        var credits: [WebMediaAsset] = []
        let limit = switch budget {
        case .economy: 2
        case .balanced: 4
        case .original: 7
        }
        var downloaded = 0

        for slideIndex in resolvedDeck.slides.indices {
            guard downloaded < limit else { break }
            for query in resolvedDeck.slides[slideIndex].mediaQueries ?? [] where downloaded < limit {
                guard let asset = try? await searchAndDownload(
                    query: query,
                    ordinal: downloaded + 1,
                    directory: directory
                ) else { continue }
                resolvedDeck.slides[slideIndex].media = (resolvedDeck.slides[slideIndex].media ?? []) + [asset.localPath]
                credits.append(asset)
                downloaded += 1
            }
        }

        if !credits.isEmpty { try? writeCredits(credits, in: directory) }
        return resolvedDeck
    }

    private func searchAndDownload(
        query: WebMediaQuery,
        ordinal: Int,
        directory: URL
    ) async throws -> WebMediaAsset {
        let searchModifier = switch query.type {
        case .image: "filetype:bitmap -filemime:image/gif"
        case .gif: "filemime:image/gif"
        case .video: "filetype:video"
        }
        var components = URLComponents(string: "https://commons.wikimedia.org/w/api.php")
        components?.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "generator", value: "search"),
            URLQueryItem(name: "gsrsearch", value: "\(query.query) \(searchModifier)"),
            URLQueryItem(name: "gsrnamespace", value: "6"),
            URLQueryItem(name: "gsrlimit", value: "8"),
            URLQueryItem(name: "prop", value: "imageinfo"),
            URLQueryItem(name: "iiprop", value: "url|mime|extmetadata"),
            URLQueryItem(name: "iiurlwidth", value: "1920"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "formatversion", value: "2"),
            URLQueryItem(name: "origin", value: "*")
        ]
        guard let url = components?.url else { throw GenerationError.fileOperation("Consulta multimedia inválida.") }
        var request = URLRequest(url: url)
        request.setValue("Lamina/1.0 (https://github.com/kisnner26/lamina)", forHTTPHeaderField: "User-Agent")
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let queryObject = root["query"] as? [String: Any],
              let pages = queryObject["pages"] as? [[String: Any]] else {
            throw GenerationError.fileOperation("Wikimedia no devolvió medios.")
        }

        for page in pages {
            guard let info = (page["imageinfo"] as? [[String: Any]])?.first,
                  let mime = info["mime"] as? String,
                  accepts(mime: mime, type: query.type),
                  let rawURL = preferredURL(info: info, type: query.type),
                  let mediaURL = URL(string: rawURL) else { continue }
            let (mediaData, response) = try await URLSession.shared.data(from: mediaURL)
            guard mediaData.count <= 30_000_000 else { continue }
            let extensionName = fileExtension(mime: mime, response: response, url: mediaURL)
            let folder = directory.appending(path: "assets/web", directoryHint: .isDirectory)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let destination = folder.appending(path: "media-\(ordinal).\(extensionName)")
            try mediaData.write(to: destination, options: .atomic)
            let metadata = info["extmetadata"] as? [String: Any] ?? [:]
            return WebMediaAsset(
                localPath: "assets/web/\(destination.lastPathComponent)",
                title: page["title"] as? String ?? query.query,
                creator: metadataValue("Artist", from: metadata),
                license: metadataValue("LicenseShortName", from: metadata),
                licenseURL: metadataValue("LicenseUrl", from: metadata),
                sourceURL: info["descriptionurl"] as? String ?? rawURL
            )
        }
        throw GenerationError.fileOperation("No se encontró un medio compatible.")
    }

    private func accepts(mime: String, type: WebMediaType) -> Bool {
        switch type {
        case .image: mime.hasPrefix("image/") && mime != "image/gif"
        case .gif: mime == "image/gif"
        case .video: mime.hasPrefix("video/")
        }
    }

    private func preferredURL(info: [String: Any], type: WebMediaType) -> String? {
        if type == .image, let thumbnail = info["thumburl"] as? String { return thumbnail }
        return info["url"] as? String
    }

    private func fileExtension(mime: String, response: URLResponse, url: URL) -> String {
        if !url.pathExtension.isEmpty { return url.pathExtension.lowercased() }
        if let suggested = response.suggestedFilename, !URL(fileURLWithPath: suggested).pathExtension.isEmpty {
            return URL(fileURLWithPath: suggested).pathExtension.lowercased()
        }
        return switch mime {
        case "image/gif": "gif"
        case "video/webm": "webm"
        case "video/ogg": "ogv"
        case "image/png": "png"
        default: "jpg"
        }
    }

    private func metadataValue(_ key: String, from metadata: [String: Any]) -> String {
        guard let item = metadata[key] as? [String: Any], let value = item["value"] as? String else { return "unknown" }
        return value.replacing(/<[^>]+>/, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func writeCredits(_ assets: [WebMediaAsset], in directory: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try encoder.encode(assets).write(to: directory.appending(path: "credits.json"), options: .atomic)
        let markdown = assets.map { asset in
            "- \(asset.title) — \(asset.creator) — \(asset.license) — \(asset.sourceURL)"
        }.joined(separator: "\n")
        try markdown.write(to: directory.appending(path: "CREDITS.md"), atomically: true, encoding: .utf8)
    }
}
