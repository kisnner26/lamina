import Foundation

struct SourceImage: Identifiable, Hashable, Sendable {
    let id: UUID
    let url: URL

    init(id: UUID = UUID(), url: URL) {
        self.id = id
        self.url = url
    }

    var filename: String { url.lastPathComponent }
}
