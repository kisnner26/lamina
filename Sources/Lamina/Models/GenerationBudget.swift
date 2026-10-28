import Foundation

enum GenerationBudget: String, CaseIterable, Codable, Identifiable, Sendable {
    case economy
    case balanced
    case original

    var id: Self { self }

    var title: String { rawValue }

    var detail: String {
        switch self {
        case .economy: "existing components only"
        case .balanced: "components plus custom svg"
        case .original: "maximum creative freedom"
        }
    }

    var componentLimit: Int {
        switch self {
        case .economy: 4
        case .balanced: 6
        case .original: 9
        }
    }
}
