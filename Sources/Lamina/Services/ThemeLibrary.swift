import Foundation

struct ThemeLibrary: Sendable {
    func loadAll() throws -> [ThemeDefinition] {
        let directory = Bundle.module.resourceURL?.appending(path: "Themes", directoryHint: .isDirectory)
        guard let directory else { throw GenerationError.missingThemeLibrary }
        let urls = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        let decoder = JSONDecoder()
        return try urls
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .map { try decoder.decode(ThemeDefinition.self, from: Data(contentsOf: $0)) }
    }

    func select(for request: GenerationRequest) throws -> [ThemeDefinition] {
        let material = "\(request.title) \(request.sourceText) \(request.instructions)".lowercased()
        let themes = try loadAll()
        var scored: [(theme: ThemeDefinition, score: Int)] = []
        for theme in themes {
            scored.append((theme, matchCount(theme.keywords, in: material)))
        }
        scored.sort { lhs, rhs in
            lhs.score == rhs.score ? lhs.theme.id < rhs.theme.id : lhs.score > rhs.score
        }
        return Array(scored.prefix(3).map(\.theme))
    }

    func theme(id: String) throws -> ThemeDefinition {
        let themes = try loadAll()
        guard let theme = themes.first(where: { $0.id == id }) ?? themes.first else {
            throw GenerationError.missingThemeLibrary
        }
        return theme
    }

    private func matchCount(_ keywords: [String], in material: String) -> Int {
        keywords.count(where: material.localizedStandardContains)
    }
}
