import Foundation

actor DeckEditorService {
    private let loader = DeckIRLoader()
    private let compiler = DeckCompiler()

    func apply(_ edit: DeckEditMessage, to project: PresentationProject) throws {
        var deck = try loader.load(from: project.directory)
        guard edit.slide >= 0, edit.slide < deck.slides.count else {
            throw GenerationError.invalidDeck("La slide editada no existe.")
        }

        if edit.field == "layout" {
            deck.slides[edit.slide].layout = SlideLayout(
                x: edit.x,
                y: edit.y,
                scale: edit.scale,
                rotation: edit.rotation,
                alignment: deck.slides[edit.slide].layout?.alignment
            )
        } else if let value = edit.value {
            applyText(value, field: edit.field, slide: &deck.slides[edit.slide])
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try encoder.encode(deck).write(to: project.directory.appending(path: "deck.json"), options: .atomic)
        let factsURL = project.directory.appending(path: "planning/facts.json")
        let facts = (try? JSONDecoder().decode([FactRecord].self, from: Data(contentsOf: factsURL))) ?? []
        try compiler.compile(deck: deck, facts: facts, in: project.directory)
    }

    private func applyText(_ value: String, field: String, slide: inout DeckSlide) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        switch field {
        case "title": slide.title = trimmed
        case "kicker": slide.kicker = trimmed
        case "body": slide.body = trimmed
        default:
            guard field.hasPrefix("bullet-"),
                  let index = Int(field.dropFirst("bullet-".count)),
                  var bullets = slide.bullets,
                  index >= 0,
                  index < bullets.count else { return }
            bullets[index] = trimmed
            slide.bullets = bullets
        }
    }
}
