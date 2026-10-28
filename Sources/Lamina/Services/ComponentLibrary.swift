import Foundation

struct ComponentLibrary: Sendable {
    func loadAll() throws -> [ComponentDefinition] {
        let directory = Bundle.module.resourceURL?.appending(path: "Components", directoryHint: .isDirectory)
        guard let directory else { throw GenerationError.missingComponentLibrary }
        let urls = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        let decoder = JSONDecoder()
        return try urls
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .map { try decoder.decode(ComponentDefinition.self, from: Data(contentsOf: $0)) }
    }

    func select(
        for request: GenerationRequest,
        algorithm: PresentationAlgorithm,
        preferredIDs: [String] = []
    ) throws -> [ComponentDefinition] {
        let available = try loadAll().filter { $0.budgets.contains(request.budget) }
        let material = "\(request.title) \(request.sourceText) \(request.instructions) \(algorithm.mechanisms.joined(separator: " "))".lowercased()
        let anchors = available.filter { ["hero", "full-bleed", "closing"].contains($0.id) }
        var scored: [(component: ComponentDefinition, score: Int)] = []
        for component in available where !anchors.contains(where: { $0.id == component.id }) {
            let memoryBoost = preferredIDs.firstIndex(of: component.id).map { max(1, 4 - $0) } ?? 0
            scored.append((component, matchCount(component.keywords, in: material) + memoryBoost))
        }
        scored.sort { lhs, rhs in
            lhs.score == rhs.score ? lhs.component.id < rhs.component.id : lhs.score > rhs.score
        }
        let ranked = scored.map(\.component)

        return Array((anchors + ranked).prefix(request.budget.componentLimit))
    }

    private func matchCount(_ keywords: [String], in material: String) -> Int {
        keywords.count(where: material.localizedStandardContains)
    }
}
