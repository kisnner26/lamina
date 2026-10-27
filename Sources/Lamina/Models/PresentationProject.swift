import Foundation

struct PresentationProject: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let directory: URL
    let createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        directory: URL,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.directory = directory
        self.createdAt = createdAt
    }

    var indexURL: URL { directory.appending(path: "index.html") }
}
