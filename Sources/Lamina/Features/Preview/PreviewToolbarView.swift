import SwiftUI

struct PreviewToolbarView: View {
    let project: PresentationProject?
    let onReveal: () -> Void
    let onReset: () -> Void

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
                Button("show in finder", systemImage: "folder", action: onReveal)
                Button("new presentation", systemImage: "plus", action: onReset)
            }
        }
        .padding(.horizontal, 18)
        .frame(minHeight: 58)
        .background(.ultraThinMaterial)
    }
}
