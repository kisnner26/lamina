import Foundation

struct GenerationMemoryEntry: Codable, Identifiable, Sendable {
    let id: UUID
    let projectPath: String
    let algorithm: String
    let components: [String]
    let theme: String
    let budget: GenerationBudget
    let createdAt: Date
    var rating: Int?
    let passedValidation: Bool
}
