import Foundation

struct GenerationPlanWriter: Sendable {
    private let graphBuilder = PresentationGraphBuilder()
    private let componentLibrary = ComponentLibrary()
    private let themeLibrary = ThemeLibrary()
    private let factLedgerBuilder = FactLedgerBuilder()
    private let grammarLibrary = VisualGrammarLibrary()

    func write(
        request: GenerationRequest,
        algorithm: PresentationAlgorithm,
        preferredComponentIDs: [String] = []
    ) throws -> GenerationPlan {
        let folder = request.outputDirectory.appending(path: "planning", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        let sourceURL = folder.appending(path: "source.md")
        let directionURL = folder.appending(path: "direction.txt")
        let algorithmURL = folder.appending(path: "algorithm.json")
        let graphURL = folder.appending(path: "presentation-graph.json")
        let factsURL = folder.appending(path: "facts.json")
        let componentsURL = folder.appending(path: "components.json")
        let themesURL = folder.appending(path: "themes.json")
        let grammarURL = folder.appending(path: "visual-grammar.json")
        let graph = graphBuilder.build(request: request, algorithm: algorithm)
        let facts = factLedgerBuilder.build(from: request.sourceText)
        let components = try componentLibrary.select(
            for: request,
            algorithm: algorithm,
            preferredIDs: preferredComponentIDs
        )
        let themes = try themeLibrary.select(for: request)
        let grammar = try grammarLibrary.select(for: request)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]

        let numberedSource = graphBuilder.sourceSections(from: request.sourceText).enumerated()
            .map { "## section \($0.offset + 1)\n\($0.element)" }
            .joined(separator: "\n\n")

        try Data(numberedSource.utf8).write(to: sourceURL, options: .atomic)
        try Data(request.instructions.utf8).write(to: directionURL, options: .atomic)
        try encoder.encode(algorithm).write(to: algorithmURL, options: .atomic)
        try encoder.encode(graph).write(to: graphURL, options: .atomic)
        try encoder.encode(facts).write(to: factsURL, options: .atomic)
        try encoder.encode(components).write(to: componentsURL, options: .atomic)
        try encoder.encode(themes).write(to: themesURL, options: .atomic)
        try encoder.encode(grammar).write(to: grammarURL, options: .atomic)

        return GenerationPlan(
            algorithm: algorithm,
            graph: graph,
            sourcePath: "planning/source.md",
            directionPath: "planning/direction.txt",
            algorithmPath: "planning/algorithm.json",
            graphPath: "planning/presentation-graph.json",
            grammarPath: "planning/visual-grammar.json",
            factsPath: "planning/facts.json",
            componentsPath: "planning/components.json",
            themesPath: "planning/themes.json",
            components: components,
            themes: themes,
            facts: facts,
            grammar: grammar
        )
    }
}
