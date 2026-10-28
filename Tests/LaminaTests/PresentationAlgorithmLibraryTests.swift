import Foundation
import Testing
@testable import Lamina

struct PresentationAlgorithmLibraryTests {
    @Test func selectsComparisonForVersusMaterial() throws {
        let request = GenerationRequest(
            title: "Pancakes vs crepes",
            sourceText: "Compare two recipes and their differences.",
            instructions: "",
            images: [],
            provider: .codex,
            mode: .graph,
            outputDirectory: URL(fileURLWithPath: "/tmp/deck")
        )

        let algorithm = try PresentationAlgorithmLibrary().select(for: request)

        #expect(algorithm.id == "comparison")
    }

    @Test func graphIsLinearAndUsesAlgorithmMechanisms() {
        let request = GenerationRequest(
            title: "A process",
            sourceText: "Input\n\nTransformation\n\nResult",
            instructions: "",
            images: [],
            provider: .codex,
            mode: .graph,
            outputDirectory: URL(fileURLWithPath: "/tmp/deck")
        )
        let algorithm = PresentationAlgorithm(
            id: "process",
            name: "process",
            summary: "",
            keywords: [],
            slideRoles: ["input", "change", "result"],
            mechanisms: ["inventory", "assembly", "reveal"],
            constraints: []
        )

        let graph = PresentationGraphBuilder().build(request: request, algorithm: algorithm)

        #expect(graph.nodes.count == 3)
        #expect(graph.nodes[0].next == ["slide-2"])
        #expect(graph.nodes[2].next.isEmpty)
        #expect(graph.nodes[1].sourceSections == [2])
    }
}
