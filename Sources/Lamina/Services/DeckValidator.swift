import Foundation

struct DeckValidator: Sendable {
    func validate(directory: URL) throws {
        let indexURL = directory.appending(path: "index.html")
        guard FileManager.default.fileExists(atPath: indexURL.path) else {
            throw GenerationError.invalidDeck("Falta index.html.")
        }

        let html: String
        do {
            html = try String(contentsOf: indexURL, encoding: .utf8)
        } catch {
            throw GenerationError.invalidDeck("No se pudo leer index.html.")
        }

        guard html.localizedStandardContains("<html") else {
            throw GenerationError.invalidDeck("index.html no contiene un documento HTML.")
        }
        guard html.localizedStandardContains("slide") || html.localizedStandardContains("section") else {
            throw GenerationError.invalidDeck("No se detectaron diapositivas.")
        }
        guard !html.localizedStandardContains("http://") && !html.localizedStandardContains("https://") else {
            throw GenerationError.invalidDeck("Contiene recursos remotos; el proyecto debe funcionar sin conexión.")
        }
    }
}
