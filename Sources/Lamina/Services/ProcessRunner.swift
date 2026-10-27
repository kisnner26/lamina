import Foundation

actor ProcessRunner {
    func run(
        executable: URL,
        arguments: [String],
        currentDirectory: URL,
        standardInput: String? = nil
    ) throws -> ProcessResult {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        let inputPipe = Pipe()

        process.executableURL = executable
        process.arguments = arguments
        process.currentDirectoryURL = currentDirectory
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.standardInput = inputPipe
        process.environment = environment()

        try process.run()

        if let standardInput, let data = standardInput.data(using: .utf8) {
            inputPipe.fileHandleForWriting.write(data)
        }
        try? inputPipe.fileHandleForWriting.close()

        process.waitUntilExit()

        let output = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let error = errorPipe.fileHandleForReading.readDataToEndOfFile()
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
