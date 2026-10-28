import Foundation

struct DeckAuditReport: Sendable {
    let issues: [String]

    var passed: Bool { issues.isEmpty }
}
