import Foundation

struct GenerationPlan: Sendable {
    let algorithm: PresentationAlgorithm
    let graph: PresentationGraph
    let sourcePath: String
    let directionPath: String
    let algorithmPath: String
    let graphPath: String
}
