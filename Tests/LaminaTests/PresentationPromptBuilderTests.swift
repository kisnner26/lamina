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
            mode: .fullBrief,
            outputDirectory: output
        )

        let prompt = PresentationPromptBuilder().build(request: request, stagedImages: [image])

        #expect(prompt.contains("Coffee rituals"))
        #expect(prompt.contains(image.path))
        #expect(prompt.contains("No external libraries"))
        #expect(prompt.contains("Do not use a generic"))
        #expect(prompt.contains("file://"))
    }

    @Test func graphPromptReferencesPlanWithoutRepeatingSource() {
        let output = URL(fileURLWithPath: "/tmp/lamina/graph-deck")
        let algorithm = PresentationAlgorithm(
            id: "comparison",
            name: "contrast engine",
            summary: "comparison",
            keywords: ["versus"],
            slideRoles: ["hook", "verdict"],
            mechanisms: ["collision", "callback"],
            constraints: ["stay asymmetric"]
        )
        let request = GenerationRequest(
            title: "Pancakes vs crepes",
            sourceText: "A deliberately unique source sentence.",
            instructions: "simple English",
            images: [],
            provider: .codex,
            mode: .graph,
            outputDirectory: output
        )
        let graph = PresentationGraphBuilder().build(request: request, algorithm: algorithm)
        let plan = GenerationPlan(
            algorithm: algorithm,
            graph: graph,
            sourcePath: "planning/source.md",
            directionPath: "planning/direction.txt",
            algorithmPath: "planning/algorithm.json",
            graphPath: "planning/presentation-graph.json"
        )

        let prompt = PresentationPromptBuilder().build(request: request, stagedImages: [], plan: plan)

        #expect(prompt.contains("planning/presentation-graph.json"))
        #expect(!prompt.contains(request.sourceText))
        #expect(prompt.count < 2_000)
    }
}
