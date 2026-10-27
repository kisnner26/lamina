import SwiftUI

enum DesignTokens {
    static let accent = Color(red: 0.24, green: 0.55, blue: 1)
    static let canvas = Color(red: 0.045, green: 0.055, blue: 0.075)
    static let elevated = Color(red: 0.085, green: 0.1, blue: 0.13)
    static let hairline = Color.white.opacity(0.1)
    static let panelRadius = 22.0
    static let controlRadius = 12.0
    static let standardSpacing = 16.0
    static let compactSpacing = 10.0

    static let displayFont = Font.custom(
        "Avenir Next Condensed",
        size: 34,
        relativeTo: .largeTitle
    )
}
