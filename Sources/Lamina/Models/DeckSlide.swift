import Foundation

struct DeckSlide: Codable, Identifiable, Sendable {
    let id: String
    let pattern: String
    let kicker: String?
    let title: String
    let body: String?
    let bullets: [String]?
    let factIDs: [String]?
    let media: [String]?
    let accent: String?
    let notes: String?
}
