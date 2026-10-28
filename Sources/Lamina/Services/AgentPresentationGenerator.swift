import Foundation

actor AgentPresentationGenerator {
    private let locator: ExecutableLocator
    private let runner: ProcessRunner
    private let workspaceManager: WorkspaceManager
    private let promptBuilder: PresentationPromptBuilder
    private let validator: DeckValidator
    private let algorithmLibrary: PresentationAlgorithmLibrary
    private let planWriter: GenerationPlanWriter
    private let irLoader: DeckIRLoader
    private let irValidator: DeckIRValidator
    private let compiler: DeckCompiler
    private let memoryStore: GenerationMemoryStore
    private var plans: [String: GenerationPlan] = [:]

    init(
        locator: ExecutableLocator = ExecutableLocator(),
        runner: ProcessRunner = ProcessRunner(),
        workspaceManager: WorkspaceManager = WorkspaceManager(),
        promptBuilder: PresentationPromptBuilder = PresentationPromptBuilder(),
        validator: DeckValidator = DeckValidator(),
        algorithmLibrary: PresentationAlgorithmLibrary = PresentationAlgorithmLibrary(),
        planWriter: GenerationPlanWriter = GenerationPlanWriter(),
        irLoader: DeckIRLoader = DeckIRLoader(),
        irValidator: DeckIRValidator = DeckIRValidator(),
        compiler: DeckCompiler = DeckCompiler(),
        memoryStore: GenerationMemoryStore = GenerationMemoryStore()
    ) {
        self.locator = locator
        self.runner = runner
        self.workspaceManager = workspaceManager
        self.promptBuilder = promptBuilder
        self.validator = validator
        self.algorithmLibrary = algorithmLibrary
        self.planWriter = planWriter
        self.irLoader = irLoader
        self.irValidator = irValidator
        self.compiler = compiler
        self.memoryStore = memoryStore
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
        let algorithm = try algorithmLibrary.select(for: request)
        let preferredComponents = await memoryStore.preferredComponentIDs(for: algorithm.id)
        let plan = try planWriter.write(
            request: request,
            algorithm: algorithm,
            preferredComponentIDs: preferredComponents
        )
        plans[request.outputDirectory.path] = plan
        let prompt = promptBuilder.build(request: request, stagedImages: stagedImages, plan: plan)
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

        let deck = try irLoader.load(from: request.outputDirectory)
        let audit = irValidator.audit(
            deck: deck,
            components: plan.components,
            themes: plan.themes,
            facts: plan.facts
        )
        guard audit.passed else { throw GenerationError.invalidDeck(audit.issues.joined(separator: " ")) }
        try compiler.compile(deck: deck, facts: plan.facts, in: request.outputDirectory)
        try validator.validate(directory: request.outputDirectory)
        let project = PresentationProject(
            title: deck.title,
            directory: request.outputDirectory,
            slideCount: deck.slides.count
        )
        await memoryStore.record(project: project, plan: plan, deck: deck, budget: request.budget)
        return project
    }

    func regenerateSlide(
        _ index: Int,
        project: PresentationProject,
        request: GenerationRequest
    ) async throws -> PresentationProject {
        guard let plan = plans[project.directory.path] else {
            throw GenerationError.invalidDeck("El plan de esta sesión ya no está disponible.")
        }
        guard index >= 0, index < project.slideCount else {
            throw GenerationError.invalidDeck("La diapositiva seleccionada no existe.")
        }
        guard let executable = locator.locate(request.provider) else {
            throw GenerationError.missingExecutable(request.provider)
        }

        let result = try await runAgent(
            request.provider,
            executable: executable,
            prompt: promptBuilder.repair(slideIndex: index, request: request, plan: plan),
            images: [],
            directory: project.directory
        )
        guard result.exitCode == 0 else {
            let details = result.standardError.isEmpty ? result.standardOutput : result.standardError
            throw GenerationError.agentFailed(provider: request.provider, details: String(details.suffix(900)))
        }

        let deck = try irLoader.load(from: project.directory)
        let audit = irValidator.audit(deck: deck, components: plan.components, themes: plan.themes, facts: plan.facts)
        guard audit.passed else { throw GenerationError.invalidDeck(audit.issues.joined(separator: " ")) }
        try compiler.compile(deck: deck, facts: plan.facts, in: project.directory)
        try validator.validate(directory: project.directory)
        return PresentationProject(
            id: project.id,
            title: deck.title,
            directory: project.directory,
            createdAt: project.createdAt,
            slideCount: deck.slides.count
        )
    }

    func rate(_ project: PresentationProject, positive: Bool) async {
        await memoryStore.rate(project: project, positive: positive)
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
                "--ignore-user-config",
                "--ignore-rules",
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
