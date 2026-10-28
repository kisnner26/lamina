import SwiftUI

struct PreviewToolbarView: View {
    let project: PresentationProject?
    let rating: Bool?
    let layoutIssueCount: Int
    let isEditing: Bool
    let onReveal: () -> Void
    let onReset: () -> Void
    let onRegenerate: (Int) -> Void
    let onRate: (Bool) -> Void
    let onToggleEditing: () -> Void

    var body: some View {
        HStack(spacing: DesignTokens.compactSpacing) {
            VStack(alignment: .leading, spacing: 1) {
                Text(project?.title ?? "preview")
                    .font(.headline)
                    .lineLimit(1)
                Text(project == nil ? "waiting for a source" : "offline web deck")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if project != nil {
                Button(isEditing ? "done editing" : "edit slides", systemImage: isEditing ? "checkmark" : "cursorarrow.motionlines", action: onToggleEditing)
                    .buttonStyle(.borderedProminent)
                if layoutIssueCount > 0 {
                    Label("\(layoutIssueCount) layout issues", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else {
                    Label("layout clean", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let project, project.slideCount > 0 {
                    Menu("repair slide", systemImage: "wrench.and.screwdriver") {
                        ForEach(0..<project.slideCount, id: \.self) { index in
                            Button("slide \(index + 1)") { onRegenerate(index) }
                        }
                    }
                }
                Button("worked well", systemImage: rating == true ? "hand.thumbsup.fill" : "hand.thumbsup") {
                    onRate(true)
                }
                .labelStyle(.iconOnly)
                .help("mark this generation as successful")
                Button("needs work", systemImage: rating == false ? "hand.thumbsdown.fill" : "hand.thumbsdown") {
                    onRate(false)
                }
                .labelStyle(.iconOnly)
                .help("lower this pattern's future priority")
                Button("show in finder", systemImage: "folder", action: onReveal)
                Button("new presentation", systemImage: "plus", action: onReset)
            }
        }
        .padding(.horizontal, 18)
        .frame(minHeight: 58)
        .background(.ultraThinMaterial)
    }
}
