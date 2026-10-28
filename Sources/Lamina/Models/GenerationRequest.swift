import Foundation

struct GenerationRequest: Sendable {
    let title: String
    let sourceText: String
    let instructions: String
    let images: [SourceImage]
    let provider: AIProvider
    let mode: GenerationMode
    let outputDirectory: URL

    var normalizedTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Untitled Presentation" : trimmed
    }
}
