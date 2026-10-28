import Foundation

struct DeckIR: Codable, Sendable {
    var version: Int
    var title: String
    var subtitle: String?
    var theme: String
    var artDirection: DeckArtDirection? = nil
    var slides: [DeckSlide]
}
