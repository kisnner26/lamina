import Foundation

actor ProcessRunner {
    func run(
        executable: URL,
        arguments: [String],
        currentDirectory: URL,
        standardInput: String? = nil
    ) throws -> ProcessResult {
        let process = Process()
        let inputPipe = Pipe()
        let logDirectory = FileManager.default.temporaryDirectory
            .appending(path: "lamina-process-\(UUID().uuidString)", directoryHint: .isDirectory)
        let outputURL = logDirectory.appending(path: "stdout.log")
        let errorURL = logDirectory.appending(path: "stderr.log")

        try FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)
        _ = FileManager.default.createFile(atPath: outputURL.path, contents: nil)
        _ = FileManager.default.createFile(atPath: errorURL.path, contents: nil)
        let outputHandle = try FileHandle(forWritingTo: outputURL)
        let errorHandle = try FileHandle(forWritingTo: errorURL)
        defer { try? FileManager.default.removeItem(at: logDirectory) }

        process.executableURL = executable
        process.arguments = arguments
        process.currentDirectoryURL = currentDirectory
        process.standardOutput = outputHandle
        process.standardError = errorHandle
        process.standardInput = inputPipe
        process.environment = environment()

        try process.run()

        if let standardInput, let data = standardInput.data(using: .utf8) {
            inputPipe.fileHandleForWriting.write(data)
        }
        try? inputPipe.fileHandleForWriting.close()

        process.waitUntilExit()
        try outputHandle.close()
        try errorHandle.close()

        let output = try Data(contentsOf: outputURL)
        let error = try Data(contentsOf: errorURL)
        return ProcessResult(
            exitCode: process.terminationStatus,
            standardOutput: String(decoding: output, as: UTF8.self),
            standardError: String(decoding: error, as: UTF8.self)
        )
    }

    private func environment() -> [String: String] {
        var value = ProcessInfo.processInfo.environment
        let additions = ["/opt/homebrew/bin", "/usr/local/bin", "/usr/bin", "/bin"]
        let currentPath = value["PATH", default: ""]
        value["PATH"] = (additions + [currentPath]).joined(separator: ":")
        value["TERM"] = "dumb"
        value["NO_COLOR"] = "1"
        return value
    }
}
