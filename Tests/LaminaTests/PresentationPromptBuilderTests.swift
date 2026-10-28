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
            budget: .balanced,
            outputDirectory: output
        )

        let prompt = PresentationPromptBuilder().build(
            request: request,
            stagedImages: [image],
            plan: makePlan(request: request)
        )

        #expect(prompt.contains(image.path))
        #expect(prompt.contains("deck.json"))
        #expect(prompt.contains("Never write index.html"))
        #expect(!prompt.contains(request.sourceText))
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
            budget: .balanced,
            outputDirectory: output
        )
        let plan = makePlan(request: request, algorithm: algorithm)

        let prompt = PresentationPromptBuilder().build(request: request, stagedImages: [], plan: plan)

        #expect(prompt.contains("planning/presentation-graph.json"))
        #expect(!prompt.contains(request.sourceText))
        #expect(prompt.count < 3_200)
    }

    private func makePlan(
        request: GenerationRequest,
        algorithm: PresentationAlgorithm? = nil
    ) -> GenerationPlan {
        let selected = algorithm ?? PresentationAlgorithm(
            id: "narrative-arc",
            name: "narrative",
            summary: "",
            keywords: [],
            slideRoles: ["hook", "close"],
            mechanisms: ["hero", "callback"],
            constraints: []
        )
        return GenerationPlan(
            algorithm: selected,
            graph: PresentationGraphBuilder().build(request: request, algorithm: selected),
            sourcePath: "planning/source.md",
            directionPath: "planning/direction.txt",
            algorithmPath: "planning/algorithm.json",
            graphPath: "planning/presentation-graph.json",
            grammarPath: "planning/visual-grammar.json",
            factsPath: "planning/facts.json",
            componentsPath: "planning/components.json",
            themesPath: "planning/themes.json",
            components: [],
            themes: [],
            facts: [],
            grammar: VisualGrammar(
                id: "test",
                name: "test",
                keywords: [],
                principles: [],
                compositionRules: [],
                motionRules: [],
                mediaRules: []
            )
        )
    }
}
