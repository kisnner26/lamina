import SwiftUI

struct PreviewPanel: View {
    let model: ComposerViewModel

    var body: some View {
        VStack(spacing: 0) {
            PreviewToolbarView(
                project: model.project,
                onReveal: revealProject,
                onReset: model.reset
            )
            Divider().overlay(DesignTokens.hairline)
            if let project = model.project {
                PresentationWebView(project: project)
            } else {
                PreviewPlaceholderView()
            }
        }
        .background(DesignTokens.canvas)
    }

    private func revealProject() {
        guard let project = model.project else { return }
        NSWorkspace.shared.activateFileViewerSelecting([project.indexURL])
    }
}
