import Foundation

struct PresentationGraph: Codable, Sendable {
    let version: Int
    let title: String
    let algorithm: String
    let sourceFile: String
    let nodes: [PresentationGraphNode]
}
