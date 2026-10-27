import SwiftUI

struct SourceEditorView: View {
    @Bindable var model: ComposerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
            TextField("presentation title", text: $model.title)
                .textFieldStyle(.plain)
                .font(.title3.bold())
                .padding(12)
                .background(Color.white.opacity(0.055))
                .clipShape(.rect(cornerRadius: DesignTokens.controlRadius))

            TextField(
                "paste the article, class notes, script, brief, or raw ideas…",
                text: $model.sourceText,
                axis: .vertical
            )
            .textFieldStyle(.plain)
            .lineLimit(9...15)
            .padding(12)
            .background(Color.white.opacity(0.055))
            .clipShape(.rect(cornerRadius: DesignTokens.controlRadius))

            Button("add source images", systemImage: "photo.on.rectangle.angled") {
                model.isImporterPresented = true
            }
            .buttonStyle(.bordered)

            if !model.images.isEmpty {
                LazyVStack(spacing: 6) {
                    ForEach(model.images) { image in
                        SourceImageRow(image: image, onRemove: model.removeImage)
                    }
                }
            }
        }
    }
}
