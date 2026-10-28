import Foundation

struct WebMediaQueryPlanner: Sendable {
    func queries(for deck: DeckIR, slide: DeckSlide, budget: GenerationBudget) -> [WebMediaQuery] {
        if let explicit = slide.mediaQueries, !explicit.isEmpty { return explicit }

        let visualLanguage = deck.artDirection?.imageTreatment ?? ""
        let subject = keywords(from: "\(visualLanguage) \(slide.title) \(slide.kicker ?? "") \(deck.title)")
        guard !subject.isEmpty else { return [] }

        let wantsVideo = budget == .original && (
            slide.pattern == "full-bleed" ||
            slide.notes?.localizedCaseInsensitiveContains("video") == true ||
            slide.notes?.localizedCaseInsensitiveContains("clip") == true
        )
        return [WebMediaQuery(query: subject.joined(separator: " "), type: wantsVideo ? .video : .image)]
    }

    private func keywords(from source: String) -> [String] {
        let ignored: Set<String> = [
            "about", "after", "against", "along", "authentic", "before", "behind", "cinematic",
            "deep", "directional", "documentary", "from", "full", "image", "into", "large", "most",
            "photograph", "presentation", "shadows", "slide", "small", "stock", "style", "their", "there",
            "these", "this", "through", "using", "visual", "warm", "what", "when", "where", "which", "with"
        ]
        let normalized = source
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
        let words = normalized.components(separatedBy: CharacterSet.alphanumerics.inverted)
        var result: [String] = []
        for word in words where word.count >= 4 && !ignored.contains(word) && !result.contains(word) {
            result.append(word)
            if result.count == 5 { break }
        }
        return result
    }
}
