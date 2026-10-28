import Foundation

struct PresentationGraphBuilder: Sendable {
    func build(request: GenerationRequest, algorithm: PresentationAlgorithm) -> PresentationGraph {
        let sectionCount = max(sourceSections(from: request.sourceText).count, 1)
        let nodes = algorithm.slideRoles.enumerated().map { index, role in
            let nextID = index + 1 < algorithm.slideRoles.count ? ["slide-\(index + 2)"] : []
            return PresentationGraphNode(
                id: "slide-\(index + 1)",
                role: role,
                objective: objective(for: role, position: index, total: algorithm.slideRoles.count),
                sourceSections: [min(index + 1, sectionCount)],
                mechanism: algorithm.mechanisms[index % algorithm.mechanisms.count],
                next: nextID
            )
        }

        return PresentationGraph(
            version: 1,
            title: request.normalizedTitle,
            algorithm: algorithm.id,
            sourceFile: "source.md",
            nodes: nodes
        )
    }

    func sourceSections(from source: String) -> [String] {
        let paragraphs = source
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return paragraphs.isEmpty ? [source] : paragraphs
    }

    private func objective(for role: String, position: Int, total: Int) -> String {
        switch position {
        case 0: "create immediate curiosity through the \(role)"
        case total - 1: "resolve the narrative with a memorable \(role)"
        default: "advance the explanation through the \(role)"
        }
    }
}
