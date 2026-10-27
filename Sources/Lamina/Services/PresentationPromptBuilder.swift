import Foundation

struct PresentationPromptBuilder: Sendable {
    func build(request: GenerationRequest, stagedImages: [URL]) -> String {
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
}
