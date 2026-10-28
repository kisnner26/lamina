import Foundation

struct VisualGrammar: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let keywords: [String]
    let principles: [String]
    let compositionRules: [String]
    let motionRules: [String]
    let mediaRules: [String]
}
