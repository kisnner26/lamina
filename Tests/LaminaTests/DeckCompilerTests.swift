import Foundation
import Testing
@testable import Lamina

struct DeckCompilerTests {
    @Test func compilesValidatedIRAndCachesSlideFragments() throws {
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let facts = [FactRecord(id: "f1", section: 1, text: "A verified fact")]
        let deck = DeckIR(
            version: 1,
            title: "Compiler test",
            subtitle: nil,
            theme: "editorial-dark",
            slides: [
                slide(id: "s1", pattern: "hero", title: "Open"),
                slide(id: "s2", pattern: "inventory", title: "Inputs"),
                slide(id: "s3", pattern: "sequence", title: "Process"),
                slide(id: "s4", pattern: "evidence-focus", title: "Evidence", factIDs: ["f1"]),
                slide(id: "s5", pattern: "closing", title: "Close")
            ]
        )
        let components = try ComponentLibrary().loadAll()
        let themes = try ThemeLibrary().loadAll()
        let audit = DeckIRValidator().audit(deck: deck, components: components, themes: themes, facts: facts)

        #expect(audit.passed)
        try DeckCompiler().compile(deck: deck, facts: facts, in: directory)

        let html = try String(contentsOf: directory.appending(path: "index.html"), encoding: .utf8)
        let manifest = try JSONDecoder().decode(
            DeckBuildManifest.self,
            from: Data(contentsOf: directory.appending(path: ".lamina-cache/manifest.json"))
        )
        #expect(html.contains("pattern-sequence"))
        #expect(!html.contains("https://"))
        #expect(manifest.slideHashes.count == 5)
    }

    @Test func ledgerCreatesStableFactReferences() {
        let facts = FactLedgerBuilder().build(from: "First fact. Second fact!\n\nThird fact?")

        #expect(facts.map(\.id) == ["f1", "f2", "f3"])
        #expect(facts.map(\.section) == [1, 1, 2])
    }

    private func slide(
        id: String,
        pattern: String,
        title: String,
        factIDs: [String]? = nil
    ) -> DeckSlide {
        DeckSlide(
            id: id,
            pattern: pattern,
            kicker: nil,
            title: title,
            body: "A concise explanation.",
            bullets: nil,
            factIDs: factIDs,
            media: nil,
            accent: nil,
            notes: nil
        )
    }
}
