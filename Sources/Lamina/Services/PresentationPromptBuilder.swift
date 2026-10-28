import Foundation

struct PresentationPromptBuilder: Sendable {
    func build(
        request: GenerationRequest,
        stagedImages: [URL],
        plan: GenerationPlan
    ) -> String {
        let imageList = stagedImages.isEmpty ? "none" : stagedImages.map(\.path).joined(separator: "\n")
        let planningRule = request.mode == .graph
            ? "Follow every node in \(plan.graphPath) once and in graph order."
            : "Plan the strongest narrative yourself; use \(plan.graphPath) only as optional guidance."
        let assetRule = switch request.budget {
        case .economy: "Use only provided components and source images. Do not create new assets."
        case .balanced: "You may create small local SVG assets when they add subject-specific meaning."
        case .original: "You may create original local SVG assets, but keep the Deck IR concise."
        }

        return """
        You are the creative director for Lamina. Produce a compact Deck IR, not website code.

        Read these local planning files:
        source=\(plan.sourcePath)
        direction=\(plan.directionPath)
        facts=\(plan.factsPath)
        algorithm=\(plan.algorithmPath)
        graph=\(plan.graphPath)
        allowed_components=\(plan.componentsPath)
        allowed_themes=\(plan.themesPath)

        \(planningRule)
        \(assetRule)

        Source images:
        \(imageList)

        Write exactly one required file: deck.json. Optional generated SVG files belong under assets/generated/. Never write index.html, CSS, or JavaScript; Lamina compiles those locally.

        deck.json schema:
        {"version":1,"title":"...","subtitle":"...","theme":"allowed theme id","slides":[{"id":"slide-1","pattern":"allowed component id","kicker":"...","title":"...","body":"...","bullets":["..."],"factIDs":["f1"],"media":["assets/source/file.jpg"],"accent":"#RRGGBB","notes":"..."}]}

        Rules:
        - 5 to 12 slides; concise visible text; no repeated layout for most slides.
        - Use only component and theme ids from the provided catalogs.
        - Use factIDs for factual claims. Never invent facts, dates, numbers, names, or quotes.
        - Treat component purpose as behavior, not visible labels. Create a strong opening, progression, and callback ending.
        - Keep source media paths relative. No remote URLs, external libraries, or markdown response.
        - Make valid JSON with no comments or code fence. Verify deck.json before finishing.
        """
    }

    func repair(
        slideIndex: Int,
        request: GenerationRequest,
        plan: GenerationPlan
    ) -> String {
        """
        Repair only slide \(slideIndex + 1) in deck.json inside \(request.outputDirectory.path).
        Read \(plan.sourcePath), \(plan.factsPath), \(plan.componentsPath), and \(plan.themesPath).
        Keep every other slide equivalent in meaning and structure. Fix density, factual references, and visual pattern choice for the target slide. Use only allowed ids and local media. Return no explanation; update deck.json directly and keep valid JSON.
        """
    }
}
