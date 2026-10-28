import Foundation

struct GenerationPlan: Sendable {
    let algorithm: PresentationAlgorithm
    let graph: PresentationGraph
    let sourcePath: String
    let directionPath: String
    let algorithmPath: String
    let graphPath: String
    let grammarPath: String
    let factsPath: String
    let componentsPath: String
    let themesPath: String
    let components: [ComponentDefinition]
    let themes: [ThemeDefinition]
    let facts: [FactRecord]
    let grammar: VisualGrammar
}
