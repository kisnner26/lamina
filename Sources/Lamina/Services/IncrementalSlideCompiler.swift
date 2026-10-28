import CryptoKit
import Foundation

struct IncrementalSlideCompiler: Sendable {
    private let renderer = SlideRenderer()

    func compile(slides: [DeckSlide], facts: [FactRecord], in directory: URL) throws -> [String] {
        let cache = directory.appending(path: ".lamina-cache", directoryHint: .isDirectory)
        let fragments = cache.appending(path: "fragments", directoryHint: .isDirectory)
        let manifestURL = cache.appending(path: "manifest.json")
        try FileManager.default.createDirectory(at: fragments, withIntermediateDirectories: true)
        let previous = (try? Data(contentsOf: manifestURL))
            .flatMap { try? JSONDecoder().decode(DeckBuildManifest.self, from: $0) }
        var hashes: [String: String] = [:]

        let html = try slides.enumerated().map { index, slide in
            let cacheKey = "slide-\(index + 1)"
            let relatedFacts = facts.filter { slide.factIDs?.contains($0.id) == true }
            let hash = try digest(slide: slide, facts: relatedFacts)
            let fragmentURL = fragments.appending(path: "\(cacheKey).html")
            hashes[cacheKey] = hash
            if previous?.slideHashes[cacheKey] == hash,
               let cached = try? String(contentsOf: fragmentURL, encoding: .utf8) {
                return cached
            }
            let rendered = renderer.render(slide: slide, index: index, total: slides.count, facts: facts)
            try rendered.write(to: fragmentURL, atomically: true, encoding: .utf8)
            return rendered
        }

        let manifest = DeckBuildManifest(slideHashes: hashes)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        try encoder.encode(manifest).write(to: manifestURL, options: .atomic)
        return html
    }

    private func digest(slide: DeckSlide, facts: [FactRecord]) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        var data = try encoder.encode(slide)
        data.append(try encoder.encode(facts))
        return Data(SHA256.hash(data: data)).base64EncodedString()
    }
}
