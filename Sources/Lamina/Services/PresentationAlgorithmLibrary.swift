import Foundation

struct PresentationAlgorithmLibrary: Sendable {
    func loadAll() throws -> [PresentationAlgorithm] {
        let directory = Bundle.module.resourceURL?.appending(path: "Algorithms", directoryHint: .isDirectory)
        guard let directory else { throw GenerationError.missingAlgorithmLibrary }

        let urls = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        )
        let decoder = JSONDecoder()
        let algorithms = try urls
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .map { try decoder.decode(PresentationAlgorithm.self, from: Data(contentsOf: $0)) }
        return algorithms.filter { !$0.slideRoles.isEmpty && !$0.mechanisms.isEmpty }
    }

    func select(for request: GenerationRequest) throws -> PresentationAlgorithm {
        let algorithms = try loadAll()
        guard let fallback = algorithms.first(where: { $0.id == "narrative-arc" }) ?? algorithms.first else {
            throw GenerationError.missingAlgorithmLibrary
        }

        let material = "\(request.title) \(request.sourceText) \(request.instructions)".lowercased()
        let ranked = algorithms.map { algorithm in
            let score = algorithm.keywords.count { material.localizedStandardContains($0) }
            return (algorithm, score)
        }
        return ranked.max { lhs, rhs in lhs.1 < rhs.1 }.flatMap { $0.1 > 0 ? $0.0 : nil } ?? fallback
    }
}
