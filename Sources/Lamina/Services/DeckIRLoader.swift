import Foundation

struct DeckIRLoader: Sendable {
    func load(from directory: URL) throws -> DeckIR {
        let url = directory.appending(path: "deck.json")
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw GenerationError.invalidDeck("Falta deck.json.")
        }
        do {
            return try JSONDecoder().decode(DeckIR.self, from: Data(contentsOf: url))
        } catch {
            throw GenerationError.invalidDeck("deck.json no cumple el formato de Lamina: \(error.localizedDescription)")
        }
    }
}
