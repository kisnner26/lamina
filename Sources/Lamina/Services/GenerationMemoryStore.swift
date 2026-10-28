import Foundation

actor GenerationMemoryStore {
    private let fileURL: URL

    init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? URL.applicationSupportDirectory
            .appending(path: "Lamina", directoryHint: .isDirectory)
            .appending(path: "generation-memory.json")
    }

    func preferredComponentIDs(for algorithm: String) -> [String] {
        let entries = load()
            .filter { $0.algorithm == algorithm && ($0.rating ?? 0) >= 0 && $0.passedValidation }
        var scores: [String: Int] = [:]
        for entry in entries {
            let weight = entry.rating == 1 ? 3 : 1
            for component in entry.components { scores[component, default: 0] += weight }
        }
        return scores.sorted { lhs, rhs in
            lhs.value == rhs.value ? lhs.key < rhs.key : lhs.value > rhs.value
        }.map(\.key)
    }

    func record(
        project: PresentationProject,
        plan: GenerationPlan,
        deck: DeckIR,
        budget: GenerationBudget
    ) {
        var entries = load().filter { $0.projectPath != project.directory.path }
        entries.append(GenerationMemoryEntry(
            id: UUID(),
            projectPath: project.directory.path,
            algorithm: plan.algorithm.id,
            components: Array(Set(deck.slides.map(\.pattern))).sorted(),
            theme: deck.theme,
            budget: budget,
            createdAt: .now,
            rating: nil,
            passedValidation: true
        ))
        save(Array(entries.suffix(200)))
    }

    func rate(project: PresentationProject, positive: Bool) {
        var entries = load()
        guard let index = entries.lastIndex(where: { $0.projectPath == project.directory.path }) else { return }
        entries[index].rating = positive ? 1 : -1
        save(entries)
    }

    private func load() -> [GenerationMemoryEntry] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder().decode([GenerationMemoryEntry].self, from: data)) ?? []
    }

    private func save(_ entries: [GenerationMemoryEntry]) {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            try encoder.encode(entries).write(to: fileURL, options: .atomic)
        } catch {
            return
        }
    }
}
