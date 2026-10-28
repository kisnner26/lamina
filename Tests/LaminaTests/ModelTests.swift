import Foundation
import Testing
@testable import Lamina

struct ModelTests {
    @Test func blankTitleGetsFallback() {
        let request = GenerationRequest(
            title: "   ",
            sourceText: "Source",
            instructions: "",
            images: [],
            provider: .codex,
            mode: .graph,
            outputDirectory: URL(fileURLWithPath: "/tmp/deck")
        )

        #expect(request.normalizedTitle == "Untitled Presentation")
    }
}
