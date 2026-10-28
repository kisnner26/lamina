import Foundation

struct DeckBuildManifest: Codable, Sendable {
    let slideHashes: [String: String]
}
