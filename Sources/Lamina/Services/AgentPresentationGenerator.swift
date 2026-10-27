import Foundation

actor AgentPresentationGenerator {
    private let locator: ExecutableLocator
    private let runner: ProcessRunner
    private let workspaceManager: WorkspaceManager
    private let promptBuilder: PresentationPromptBuilder
    private let validator: DeckValidator

    init(
        locator: ExecutableLocator = ExecutableLocator(),
        runner: ProcessRunner = ProcessRunner(),
        workspaceManager: WorkspaceManager = WorkspaceManager(),
        promptBuilder: PresentationPromptBuilder = PresentationPromptBuilder(),
        validator: DeckValidator = DeckValidator()
    ) {
        self.locator = locator
        self.runner = runner
        self.workspaceManager = workspaceManager
        self.promptBuilder = promptBuilder
        self.validator = validator
    }

    func makeWorkspace(title: String) async throws -> URL {
        try await workspaceManager.createWorkspace(title: title)
    }

    func generate(_ request: GenerationRequest) async throws -> PresentationProject {
        guard !request.sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !request.images.isEmpty else {
            throw GenerationError.emptySource
        }
        guard let executable = locator.locate(request.provider) else {
            throw GenerationError.missingExecutable(request.provider)
        }

        let stagedImages = try await workspaceManager.stageImages(request.images, in: request.outputDirectory)
        let prompt = promptBuilder.build(request: request, stagedImages: stagedImages)
        let result = try await runAgent(
            request.provider,
            executable: executable,
            prompt: prompt,
            images: stagedImages,
            directory: request.outputDirectory
        )

        guard result.exitCode == 0 else {
            let details = result.standardError.isEmpty ? result.standardOutput : result.standardError
            throw GenerationError.agentFailed(
                provider: request.provider,
                details: String(details.suffix(900)).trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }

        try validator.validate(directory: request.outputDirectory)
        return PresentationProject(title: request.normalizedTitle, directory: request.outputDirectory)
    }

    private func runAgent(
        _ provider: AIProvider,
        executable: URL,
        prompt: String,
        images: [URL],
        directory: URL
    ) async throws -> ProcessResult {
        switch provider {
        case .codex:
            var arguments = [
                "exec",
                "--skip-git-repo-check",
                "--ephemeral",
                "--sandbox", "workspace-write",
                "--color", "never",
                "-C", directory.path
            ]
            for image in images {
                arguments.append(contentsOf: ["--image", image.path])
            }
            arguments.append("-")
            return try await runner.run(
                executable: executable,
                arguments: arguments,
                currentDirectory: directory,
                standardInput: prompt
            )

        case .claude:
            let arguments = [
                "--print",
                "--no-session-persistence",
                "--permission-mode", "acceptEdits",
                "--tools", "Read,Write,Edit",
                "--add-dir", directory.path,
                "--output-format", "text",
                prompt
            ]
            return try await runner.run(
                executable: executable,
                arguments: arguments,
                currentDirectory: directory
            )
        }
    }
}
