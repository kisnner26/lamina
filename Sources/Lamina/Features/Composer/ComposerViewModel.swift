import Foundation
import Observation

@MainActor
@Observable
final class ComposerViewModel {
    var title = ""
    var sourceText = ""
    var instructions = ""
    var provider: AIProvider = .codex
    var generationMode: GenerationMode = .graph
    var budget: GenerationBudget = .balanced
    var images: [SourceImage] = []
    var status: GenerationStatus = .idle
    var project: PresentationProject?
    var isImporterPresented = false
    var isShowingError = false
    var errorMessage = ""
    var projectRating: Bool?
    var layoutIssueSlides: [Int] = []

    private let generator: AgentPresentationGenerator
    private let locator: ExecutableLocator
    private var lastRequest: GenerationRequest?

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
                    mode: generationMode,
                    budget: budget,
                    outputDirectory: workspace
                )
                lastRequest = request
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
        projectRating = nil
        layoutIssueSlides = []
        lastRequest = nil
    }

    func regenerateSlide(_ index: Int) {
        guard let project, let request = lastRequest, !status.isRunning else { return }
        Task {
            do {
                status = .generating(request.provider)
                self.project = try await generator.regenerateSlide(index, project: project, request: request)
                status = .ready
            } catch {
                status = .failed(error.localizedDescription)
                present(error)
            }
        }
    }

    func rateProject(positive: Bool) {
        guard let project else { return }
        projectRating = positive
        Task { await generator.rate(project, positive: positive) }
    }

    func updateLayoutIssues(_ slides: [Int]) {
        layoutIssueSlides = Array(Set(slides)).sorted()
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
