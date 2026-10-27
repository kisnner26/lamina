import Foundation

enum GenerationStatus: Equatable, Sendable {
    case idle
    case preparing
    case generating(AIProvider)
    case validating
    case ready
    case failed(String)

    var isRunning: Bool {
        switch self {
        case .preparing, .generating, .validating: true
        case .idle, .ready, .failed: false
        }
    }
}
