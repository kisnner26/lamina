import Foundation

struct PresentationProject: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let directory: URL
    let createdAt: Date
    let slideCount: Int
    let renderRevision: UUID

    init(
        id: UUID = UUID(),
        title: String,
        directory: URL,
        createdAt: Date = .now,
        slideCount: Int = 0,
        renderRevision: UUID = UUID()
    ) {
        self.id = id
        self.title = title
        self.directory = directory
        self.createdAt = createdAt
        self.slideCount = slideCount
        self.renderRevision = renderRevision
    }

    var indexURL: URL { directory.appending(path: "index.html") }
}
