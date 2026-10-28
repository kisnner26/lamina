import Foundation

struct GenerationPlanWriter: Sendable {
    private let graphBuilder = PresentationGraphBuilder()

    func write(request: GenerationRequest, algorithm: PresentationAlgorithm) throws -> GenerationPlan {
        let folder = request.outputDirectory.appending(path: "planning", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        let sourceURL = folder.appending(path: "source.md")
        let directionURL = folder.appending(path: "direction.txt")
        let algorithmURL = folder.appending(path: "algorithm.json")
        let graphURL = folder.appending(path: "presentation-graph.json")
        let graph = graphBuilder.build(request: request, algorithm: algorithm)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]

        let numberedSource = graphBuilder.sourceSections(from: request.sourceText).enumerated()
            .map { "## section \($0.offset + 1)\n\($0.element)" }
            .joined(separator: "\n\n")

        try Data(numberedSource.utf8).write(to: sourceURL, options: .atomic)
        try Data(request.instructions.utf8).write(to: directionURL, options: .atomic)
        try encoder.encode(algorithm).write(to: algorithmURL, options: .atomic)
        try encoder.encode(graph).write(to: graphURL, options: .atomic)

        return GenerationPlan(
            algorithm: algorithm,
            graph: graph,
            sourcePath: "planning/source.md",
            directionPath: "planning/direction.txt",
            algorithmPath: "planning/algorithm.json",
            graphPath: "planning/presentation-graph.json"
        )
    }
}
