import Foundation

struct DeckSlide: Codable, Identifiable, Sendable {
    var id: String
    var pattern: String
    var kicker: String?
    var title: String
    var body: String?
    var bullets: [String]?
    var factIDs: [String]?
    var media: [String]?
    var mediaQueries: [WebMediaQuery]? = nil
    var accent: String?
    var notes: String?
    var layout: SlideLayout? = nil
}
