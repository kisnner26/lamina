import Foundation

struct VisualGrammarLibrary: Sendable {
    func loadAll() throws -> [VisualGrammar] {
        let directory = Bundle.module.resourceURL?.appending(path: "Grammars", directoryHint: .isDirectory)
        guard let directory else { throw GenerationError.missingVisualGrammar }
        let urls = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        let decoder = JSONDecoder()
        return try urls
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .map { try decoder.decode(VisualGrammar.self, from: Data(contentsOf: $0)) }
    }

    func select(for request: GenerationRequest) throws -> VisualGrammar {
        let material = "\(request.title) \(request.sourceText) \(request.instructions)".lowercased()
        let grammars = try loadAll()
        guard let grammar = grammars.max(by: { score($0, material) < score($1, material) }) else {
            throw GenerationError.missingVisualGrammar
        }
        return grammar
    }

    private func score(_ grammar: VisualGrammar, _ material: String) -> Int {
        grammar.keywords.count(where: material.localizedStandardContains)
    }
}
