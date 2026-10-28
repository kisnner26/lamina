import Foundation

struct PresentationAlgorithm: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let summary: String
    let keywords: [String]
    let slideRoles: [String]
    let mechanisms: [String]
    let constraints: [String]
}
