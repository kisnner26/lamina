import Foundation

struct ComponentDefinition: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let purpose: String
    let keywords: [String]
    let budgets: [GenerationBudget]
}
