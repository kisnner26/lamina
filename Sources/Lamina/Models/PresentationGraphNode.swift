import Foundation

struct PresentationGraphNode: Codable, Identifiable, Sendable {
    let id: String
    let role: String
    let objective: String
    let sourceSections: [Int]
    let mechanism: String
    let next: [String]
}
