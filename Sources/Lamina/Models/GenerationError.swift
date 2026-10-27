import Foundation

enum GenerationError: LocalizedError, Equatable {
    case missingExecutable(AIProvider)
    case emptySource
    case agentFailed(provider: AIProvider, details: String)
    case invalidDeck(String)
    case fileOperation(String)

    var errorDescription: String? {
        switch self {
        case .missingExecutable(let provider):
            "No se encontró \(provider.displayName). Instala su CLI e inicia sesión antes de generar."
        case .emptySource:
            "Agrega texto o al menos una imagen como fuente."
        case .agentFailed(let provider, let details):
            "\(provider.displayName) no pudo terminar la presentación. \(details)"
        case .invalidDeck(let reason):
            "La presentación generada no es válida. \(reason)"
        case .fileOperation(let details):
            "No se pudo preparar el proyecto. \(details)"
        }
    }
}
