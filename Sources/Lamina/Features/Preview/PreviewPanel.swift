import SwiftUI

struct PreviewPanel: View {
    let model: ComposerViewModel

    var body: some View {
        VStack(spacing: 0) {
            PreviewToolbarView(
                project: model.project,
                rating: model.projectRating,
                layoutIssueCount: model.layoutIssueSlides.count,
                isEditing: model.isEditing,
                onReveal: revealProject,
                onReset: model.reset,
                onRegenerate: model.regenerateSlide,
                onRate: model.rateProject,
                onToggleEditing: model.toggleEditing
            )
            Divider().overlay(DesignTokens.hairline)
            if let project = model.project {
                PresentationWebView(
                    project: project,
                    isEditing: model.isEditing,
                    onAudit: model.updateLayoutIssues,
                    onEdit: model.applyDeckEdit
                )
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
