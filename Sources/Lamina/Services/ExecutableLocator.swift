import Foundation

struct ExecutableLocator: Sendable {
    func locate(_ provider: AIProvider) -> URL? {
        candidates(for: provider).first { FileManager.default.isExecutableFile(atPath: $0.path) }
    }

    func isAvailable(_ provider: AIProvider) -> Bool {
        locate(provider) != nil
    }

    private func candidates(for provider: AIProvider) -> [URL] {
        let pathDirectories = ProcessInfo.processInfo.environment["PATH", default: ""]
            .split(separator: ":")
            .map { URL(fileURLWithPath: String($0), isDirectory: true) }

        let pathCandidates = pathDirectories.map { $0.appending(path: provider.commandName) }
        return knownLocations(for: provider) + pathCandidates
    }

    private func knownLocations(for provider: AIProvider) -> [URL] {
        switch provider {
        case .codex:
            [
                URL(fileURLWithPath: "/Applications/ChatGPT.app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex"),
                URL(fileURLWithPath: "/opt/homebrew/bin/codex"),
                URL(fileURLWithPath: "/usr/local/bin/codex")
            ]
        case .claude:
            [
                URL(fileURLWithPath: "/opt/homebrew/bin/claude"),
                URL(fileURLWithPath: "/usr/local/bin/claude"),
                URL(fileURLWithPath: "/Applications/Claude.app/Contents/MacOS/claude")
            ]
        }
    }
}
