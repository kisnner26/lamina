import Foundation

struct FactLedgerBuilder: Sendable {
    func build(from source: String) -> [FactRecord] {
        let sections = PresentationGraphBuilder().sourceSections(from: source)
        var nextID = 1
        return sections.enumerated().flatMap { sectionIndex, section in
            section
                .split(whereSeparator: { character in ".!?\n".contains(character) })
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .map { sentence in
                    defer { nextID += 1 }
                    return FactRecord(id: "f\(nextID)", section: sectionIndex + 1, text: sentence)
                }
        }
    }
}
