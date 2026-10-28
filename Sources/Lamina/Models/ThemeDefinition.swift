import Foundation

struct ThemeDefinition: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let keywords: [String]
    let background: String
    let surface: String
    let foreground: String
    let muted: String
    let accent: String
    let displayFont: String
    let bodyFont: String
}
