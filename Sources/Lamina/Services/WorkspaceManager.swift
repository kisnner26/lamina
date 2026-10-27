import Foundation

actor WorkspaceManager {
    private let fileManager = FileManager.default

    func createWorkspace(title: String) throws -> URL {
        let root = URL.documentsDirectory.appending(path: "Lamina Presentations", directoryHint: .isDirectory)
        let folder = "\(slug(title))-\(UUID().uuidString.prefix(8).lowercased())"
        let workspace = root.appending(path: folder, directoryHint: .isDirectory)

        do {
            try fileManager.createDirectory(at: workspace, withIntermediateDirectories: true)
            return workspace
        } catch {
            throw GenerationError.fileOperation(error.localizedDescription)
        }
    }

    func stageImages(_ images: [SourceImage], in workspace: URL) throws -> [URL] {
        guard !images.isEmpty else { return [] }
        let destination = workspace.appending(path: "assets/source", directoryHint: .isDirectory)

        do {
            try fileManager.createDirectory(at: destination, withIntermediateDirectories: true)
            return try images.enumerated().map { index, image in
                let extensionName = image.url.pathExtension.isEmpty ? "png" : image.url.pathExtension
                let output = destination.appending(path: "source-\(index + 1).\(extensionName)")
                if fileManager.fileExists(atPath: output.path) {
                    try fileManager.removeItem(at: output)
                }
                try fileManager.copyItem(at: image.url, to: output)
                return output
            }
        } catch {
            throw GenerationError.fileOperation(error.localizedDescription)
        }
    }

    private func slug(_ input: String) -> String {
        let folded = input.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        let allowed = folded.lowercased().map { character in
            character.isLetter || character.isNumber ? character : "-"
        }
        let value = String(allowed)
            .replacing(/-+/, with: "-")
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return value.isEmpty ? "presentation" : String(value.prefix(52))
    }
}
