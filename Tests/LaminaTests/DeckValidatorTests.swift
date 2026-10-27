import Foundation
import Testing
@testable import Lamina

struct DeckValidatorTests {
    @Test func acceptsOfflineDeck() throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let html = "<html><body><section class='slide'>Local deck</section></body></html>"
        try html.write(to: directory.appending(path: "index.html"), atomically: true, encoding: .utf8)

        try DeckValidator().validate(directory: directory)
    }

    @Test func rejectsRemoteResources() throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let html = "<html><body><section class='slide'><img src='https://example.com/a.jpg'></section></body></html>"
        try html.write(to: directory.appending(path: "index.html"), atomically: true, encoding: .utf8)

        #expect(throws: GenerationError.self) {
            try DeckValidator().validate(directory: directory)
        }
    }

    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appending(path: "lamina-test-\(UUID().uuidString)", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
