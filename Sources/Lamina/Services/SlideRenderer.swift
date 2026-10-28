import Foundation

struct SlideRenderer: Sendable {
    func render(
        slide: DeckSlide,
        index: Int,
        total: Int,
        facts: [FactRecord]
    ) -> String {
        let kicker = slide.kicker.map { "<p class=\"kicker\">\(escape($0))</p>" } ?? ""
        let body = slide.body.map { "<p class=\"body-copy\">\(escape($0))</p>" } ?? ""
        let bullets = renderBullets(slide.bullets ?? [])
        let evidence = renderFacts(ids: slide.factIDs ?? [], facts: facts)
        let media = renderMedia(slide.media ?? [])
        let visual = visualMarkup(for: slide.pattern, slide: slide)
        let accent = safeColor(slide.accent).map { " style=\"--slide-accent:\($0)\"" } ?? ""

        return """
        <section class="slide pattern-\(escapeAttribute(slide.pattern))" data-slide="\(index)" data-slide-id="\(escapeAttribute(slide.id))"\(accent)>
          <div class="slide-index">\(padded(index + 1)) / \(padded(total))</div>
          <div class="slide-copy">\(kicker)<h2>\(escape(slide.title))</h2>\(body)\(bullets)\(evidence)</div>
          <div class="slide-visual" aria-hidden="true">\(media)\(visual)</div>
          \(slide.notes.map { "<aside class=\"speaker-notes\">\(escape($0))</aside>" } ?? "")
        </section>
        """
    }

    private func renderBullets(_ bullets: [String]) -> String {
        guard !bullets.isEmpty else { return "" }
        return "<ul class=\"bullet-list\">" + bullets.enumerated().map { index, item in
            "<li><span>\(padded(index + 1))</span>\(escape(item))</li>"
        }.joined() + "</ul>"
    }

    private func renderFacts(ids: [String], facts: [FactRecord]) -> String {
        let selected = ids.compactMap { id in facts.first { $0.id == id } }
        guard !selected.isEmpty else { return "" }
        return "<div class=\"facts\">" + selected.map {
            "<blockquote><small>\(escape($0.id.uppercased()))</small>\(escape($0.text))</blockquote>"
        }.joined() + "</div>"
    }

    private func renderMedia(_ paths: [String]) -> String {
        let localPaths = paths.filter { !$0.contains("://") }.prefix(3)
        guard !localPaths.isEmpty else { return "" }
        let frames = localPaths.map { path in
            "<figure class=\"media-frame\"><img src=\"\(escapeAttribute(path))\" alt=\"\"></figure>"
        }.joined()
        return "<div class=\"media-stack media-count-\(localPaths.count)\">\(frames)</div>"
    }

    private func visualMarkup(for pattern: String, slide: DeckSlide) -> String {
        switch pattern {
        case "split-compare":
            return "<div class=\"compare-shapes\"><i>A</i><b>VS</b><i>B</i></div>"
        case "sequence":
            return "<div class=\"sequence-line\"><i></i><i></i><i></i><i></i></div>"
        case "inventory":
            return "<div class=\"inventory-grid\"><i></i><i></i><i></i><i></i><i></i><i></i></div>"
        case "timeline":
            return "<div class=\"timeline-track\"><i></i><i></i><i></i><i></i></div>"
        case "concept-map":
            return "<svg class=\"concept-svg\" viewBox=\"0 0 600 500\"><path d=\"M300 250L120 100M300 250L500 120M300 250L140 410M300 250L500 400\"/><g><circle cx=\"300\" cy=\"250\" r=\"72\"/><circle cx=\"120\" cy=\"100\" r=\"38\"/><circle cx=\"500\" cy=\"120\" r=\"38\"/><circle cx=\"140\" cy=\"410\" r=\"38\"/><circle cx=\"500\" cy=\"400\" r=\"38\"/></g></svg>"
        case "evidence-focus":
            return "<div class=\"evidence-orbit\"><i></i><b>\(escape(String(slide.title.prefix(1))))</b></div>"
        case "matrix":
            return "<div class=\"matrix-grid\">" + String(repeating: "<i></i>", count: 9) + "</div>"
        case "closing":
            return "<div class=\"closing-mark\">↗</div>"
        default:
            return "<div class=\"hero-mark\"><i></i><i></i><b>\(escape(String(slide.title.prefix(1))))</b></div>"
        }
    }

    private func safeColor(_ value: String?) -> String? {
        guard let value, value.range(of: "^#[0-9A-Fa-f]{6}$", options: .regularExpression) != nil else { return nil }
        return value
    }

    private func escape(_ value: String) -> String {
        value
            .replacing("&", with: "&amp;")
            .replacing("<", with: "&lt;")
            .replacing(">", with: "&gt;")
            .replacing("\"", with: "&quot;")
            .replacing("'", with: "&#39;")
    }

    private func escapeAttribute(_ value: String) -> String { escape(value) }

    private func padded(_ value: Int) -> String { value < 10 ? "0\(value)" : "\(value)" }
}
