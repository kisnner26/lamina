import Foundation

struct DeckEditMessage: Sendable {
    let slide: Int
    let field: String
    let value: String?
    let x: Double?
    let y: Double?
    let scale: Double?
    let rotation: Double?
}
