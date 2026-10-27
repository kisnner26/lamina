import Foundation
import Observation

@MainActor
@Observable
final class ComposerViewModel {
    var title = ""
    var sourceText = ""
    var instructions = ""
    var provider: AIProvider = .codex
    var images: [SourceImage] = []
    var status: GenerationStatus = .idle
    var project: PresentationProject?
    var isImporterPresented = false
    var isShowingError = false
    var errorMessage = ""

    private let generator: AgentPresentationGenerator
    private let locator: ExecutableLocator

    init(
        generator: AgentPresentationGenerator = AgentPresentationGenerator(),
        locator: ExecutableLocator = ExecutableLocator()
    ) {
        self.generator = generator
        self.locator = locator
    }

    var canGenerate: Bool {
        !status.isRunning && (!sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !images.isEmpty)
    }

    func isProviderAvailable(_ provider: AIProvider) -> Bool {
        locator.isAvailable(provider)
    }

    func importImages(from urls: [URL]) {
        do {
            let imported = try urls.map(copyImportedImage)
            images.append(contentsOf: imported.filter { !images.contains($0) })
        } catch {
            present(error)
        }
    }

    func removeImage(_ image: SourceImage) {
        images.removeAll { $0.id == image.id }
    }

    func generate() {
        guard canGenerate else { return }

        Task {
            do {
                status = .preparing
                let workspace = try await generator.makeWorkspace(title: normalizedTitle)
                status = .generating(provider)
                let request = GenerationRequest(
                    title: normalizedTitle,
                    sourceText: sourceText,
                    instructions: instructions,
                    images: images,
                    provider: provider,
                    outputDirectory: workspace
                )
                let generatedProject = try await generator.generate(request)
                status = .ready
                project = generatedProject
            } catch {
                status = .failed(error.localizedDescription)
                present(error)
            }
        }
    }

    func reset() {
        title = ""
        sourceText = ""
        instructions = ""
        images = []
        project = nil
        status = .idle
    }

    private var normalizedTitle: String {
        let value = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? "Untitled Presentation" : value
    }

    private func copyImportedImage(_ source: URL) throws -> SourceImage {
        let hasAccess = source.startAccessingSecurityScopedResource()
        defer {
            if hasAccess { source.stopAccessingSecurityScopedResource() }
        }

        let root = URL.applicationSupportDirectory
            .appending(path: "Lamina/Imports", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let filename = "\(UUID().uuidString)-\(source.lastPathComponent)"
        let destination = root.appending(path: filename)
        try FileManager.default.copyItem(at: source, to: destination)
        return SourceImage(url: destination)
    }

    private func present(_ error: Error) {
        errorMessage = error.localizedDescription
        isShowingError = true
    }
}
