import Foundation

enum GenerationMode: String, CaseIterable, Codable, Identifiable, Sendable {
    case graph
    case fullBrief

    var id: Self { self }

    var title: String {
        switch self {
        case .graph: "graph plan"
        case .fullBrief: "full brief"
        }
    }

    var detail: String {
        switch self {
        case .graph: "reuses a local algorithm and sends a compact slide graph"
        case .fullBrief: "lets the agent design the narrative from the complete brief"
        }
    }
}
