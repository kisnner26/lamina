import Foundation

enum AIProvider: String, CaseIterable, Codable, Identifiable, Sendable {
    case codex
    case claude

    var id: Self { self }

    var displayName: String {
        switch self {
        case .codex: "Codex"
        case .claude: "Claude"
        }
    }

    var commandName: String { rawValue }
}
