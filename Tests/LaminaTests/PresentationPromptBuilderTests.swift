import Foundation
import Testing
@testable import Lamina

struct PresentationPromptBuilderTests {
    @Test func promptCarriesSourceImagesAndOfflineContract() {
        let output = URL(fileURLWithPath: "/tmp/lamina/deck")
        let image = output.appending(path: "assets/source/source-1.jpg")
        let request = GenerationRequest(
            title: "Coffee rituals",
            sourceText: "Coffee moved from ceremony to daily habit.",
            instructions: "Use simple English.",
            images: [],
            provider: .codex,
            outputDirectory: output
        )

        let prompt = PresentationPromptBuilder().build(request: request, stagedImages: [image])

        #expect(prompt.contains("Coffee rituals"))
        #expect(prompt.contains(image.path))
        #expect(prompt.contains("No external libraries"))
        #expect(prompt.contains("Do not use a generic"))
        #expect(prompt.contains("file://"))
    }
}
