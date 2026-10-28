import Foundation

struct DeckIRValidator: Sendable {
    func audit(
        deck: DeckIR,
        components: [ComponentDefinition],
        themes: [ThemeDefinition],
        facts: [FactRecord]
    ) -> DeckAuditReport {
        var issues: [String] = []
        let componentIDs = Set(components.map(\.id))
        let themeIDs = Set(themes.map(\.id))
        let factIDs = Set(facts.map(\.id))

        if deck.version != 1 { issues.append("La versión de deck debe ser 1.") }
        if deck.slides.count < 5 || deck.slides.count > 12 { issues.append("El deck debe contener entre 5 y 12 slides.") }
        if !themeIDs.contains(deck.theme) { issues.append("El tema \(deck.theme) no está permitido.") }
        if Set(deck.slides.map(\.id)).count != deck.slides.count { issues.append("Los ids de slides deben ser únicos.") }

        for slide in deck.slides {
            if slide.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append("La slide \(slide.id) no tiene título.")
            }
            if slide.title.count > 90 { issues.append("El título de \(slide.id) es demasiado largo.") }
            if !componentIDs.contains(slide.pattern) { issues.append("El patrón \(slide.pattern) no está permitido.") }
            if slide.body?.count ?? 0 > 520 { issues.append("El cuerpo de \(slide.id) es demasiado largo.") }
            if slide.bullets?.count ?? 0 > 7 { issues.append("La slide \(slide.id) tiene demasiados puntos.") }
            for factID in slide.factIDs ?? [] where !factIDs.contains(factID) {
                issues.append("La slide \(slide.id) referencia un hecho inexistente: \(factID).")
            }
            for media in slide.media ?? [] where media.contains("://") {
                issues.append("La slide \(slide.id) usa un recurso remoto.")
            }
        }

        let repeatedPatterns = Dictionary(grouping: deck.slides, by: \.pattern)
            .filter { $0.value.count > max(3, deck.slides.count / 2) }
        if !repeatedPatterns.isEmpty { issues.append("Se repite demasiado el mismo patrón visual.") }
        return DeckAuditReport(issues: issues)
    }
}
