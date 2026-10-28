import Foundation

struct PresentationPromptBuilder: Sendable {
    func build(
        request: GenerationRequest,
        stagedImages: [URL],
        plan: GenerationPlan? = nil
    ) -> String {
        if request.mode == .graph, let plan {
            return graphPrompt(request: request, stagedImages: stagedImages, plan: plan)
        }
        return fullBriefPrompt(request: request, stagedImages: stagedImages)
    }

    private func fullBriefPrompt(request: GenerationRequest, stagedImages: [URL]) -> String {
        let imageList = stagedImages.isEmpty
            ? "No source images were provided."
            : stagedImages.map { "- \($0.path)" }.joined(separator: "\n")

        return """
        You are the creative director and frontend engineer for a premium interactive presentation.

        Build the complete presentation inside this exact directory:
        \(request.outputDirectory.path)

        TITLE
        \(request.normalizedTitle)

        SOURCE MATERIAL
        \(request.sourceText.isEmpty ? "No source text was provided." : request.sourceText)

        USER DIRECTION
        \(request.instructions.isEmpty ? "Choose the strongest visual direction from the source." : request.instructions)

        SOURCE IMAGES
        \(imageList)

        CREATIVE STANDARD
        - Derive one unmistakable visual language from the subject. Do not use a generic startup deck, dashboard, template, card wall, or AI-gradient look.
        - Create a strong opening, narrative progression, visual comparisons where useful, and a memorable ending.
        - Use expressive typography, deliberate composition, custom CSS/SVG illustrations, and subject-specific motion.
        - Every slide must feel designed, not merely decorated. Vary composition while preserving one design system.
        - Keep on-screen English concise and easy to present unless the source clearly asks for another language.
        - Preserve facts from the source. Do not invent claims, statistics, citations, names, or quotes.
        - Use source images when they add meaning. Copy or reference them only through relative local paths.

        OUTPUT CONTRACT
        - Create index.html, styles.css, and app.js. You may add local files under assets/.
        - Produce 6 to 10 horizontal, full-viewport slides with keyboard, wheel, trackpad, and clickable navigation.
        - Include a progress indicator, slide count, fullscreen control, and optional speaker notes.
        - Use semantic HTML and visible focus states. Respect prefers-reduced-motion.
        - Prevent text clipping and overlap at 1440x900, 1920x1080, and narrow mobile widths.
        - Animate only opacity and transforms where possible. Avoid scroll listeners that cause layout thrashing.
        - No external libraries, CDNs, remote fonts, analytics, network requests, or build step.
        - All assets must work offline by opening index.html directly with file://.
        - Do not create markdown explanations. Work directly on the files, then verify the result.
        """
    }

    private func graphPrompt(
        request: GenerationRequest,
        stagedImages: [URL],
        plan: GenerationPlan
    ) -> String {
        let imageList = stagedImages.isEmpty
            ? "none"
            : stagedImages.map(\.path).joined(separator: "\n")

        return """
        Build an original offline web presentation in \(request.outputDirectory.path).

        The narrative has already been planned locally to reduce token usage. Read and follow:
        - source: \(plan.sourcePath)
        - user direction: \(plan.directionPath)
        - reusable algorithm: \(plan.algorithmPath)
        - slide graph: \(plan.graphPath)

        Use every graph node once, in graph order. Treat its role and mechanism as behavior, not as literal on-screen text. Preserve source facts and do not invent claims.

        Source images:
        \(imageList)

        Create only index.html, styles.css, app.js, and local assets. Make each slide visually distinct but part of one subject-specific art direction. Use custom CSS/SVG and meaningful motion; avoid generic cards, dashboards, gradients, and repeated layouts.

        The deck must work from file:// with no network, libraries, CDNs, or remote fonts. Add keyboard, wheel, trackpad, click, progress, slide count, and fullscreen controls. Prevent overlap at 1440x900, 1920x1080, and narrow widths. Use semantic HTML, visible focus, reduced-motion support, and compositor-friendly animation. Verify the files directly; do not return an explanation.
        """
    }
}
