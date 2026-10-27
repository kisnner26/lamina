import SwiftUI

struct DirectionEditorView: View {
    @Bindable var model: ComposerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
            Text("creative direction")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)

            TextField(
                "audience, language, mood, authors, constraints…",
                text: $model.instructions,
                axis: .vertical
            )
            .textFieldStyle(.plain)
            .lineLimit(3...6)
            .padding(12)
            .background(Color.white.opacity(0.055))
            .clipShape(.rect(cornerRadius: DesignTokens.controlRadius))
        }
    }
}
