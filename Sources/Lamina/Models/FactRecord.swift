import Foundation

struct FactRecord: Codable, Identifiable, Sendable {
    let id: String
    let section: Int
    let text: String
}
