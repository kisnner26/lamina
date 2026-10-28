import Testing
@testable import Lamina

struct WebMediaQueryPlannerTests {
    @Test func keepsExplicitMediaQueries() {
        let expected = WebMediaQuery(query: "35mm projector booth", type: .image)
        var slide = sampleSlide
        slide.mediaQueries = [expected]

        let queries = WebMediaQueryPlanner().queries(for: sampleDeck(slide), slide: slide, budget: .balanced)

        #expect(queries.count == 1)
        #expect(queries[0].query == expected.query)
        #expect(queries[0].type == .image)
    }

    @Test func createsFocusedFallbackWhenAgentOmitsQueries() {
        let slide = sampleSlide

        let queries = WebMediaQueryPlanner().queries(for: sampleDeck(slide), slide: slide, budget: .balanced)

        #expect(queries.count == 1)
        #expect(queries[0].query.contains("projection"))
        #expect(queries[0].type == .image)
    }

    @Test func requestsVideoForOriginalFullBleedSlide() {
        var slide = sampleSlide
        slide.pattern = "full-bleed"

        let queries = WebMediaQueryPlanner().queries(for: sampleDeck(slide), slide: slide, budget: .original)

        #expect(queries[0].type == .video)
    }

    private var sampleSlide: DeckSlide {
        DeckSlide(
            id: "slide-1",
            pattern: "hero",
            kicker: "inside the booth",
            title: "the projectionist",
            body: nil,
            bullets: nil,
            factIDs: nil,
            media: nil,
            accent: nil,
            notes: nil
        )
    }

    private func sampleDeck(_ slide: DeckSlide) -> DeckIR {
        DeckIR(
            version: 1,
            title: "behind the beam",
            subtitle: nil,
            theme: "editorial-dark",
            artDirection: DeckArtDirection(
                motif: "projector beam",
                composition: "cinematic",
                imageTreatment: "cinema projection booths, film reels and working hands",
                motion: "slow pushes",
                texture: "film grain"
            ),
            slides: [slide]
        )
    }
}
