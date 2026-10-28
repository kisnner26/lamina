import Foundation

struct DeckIR: Codable, Sendable {
    let version: Int
    let title: String
    let subtitle: String?
    let theme: String
    let slides: [DeckSlide]
}
