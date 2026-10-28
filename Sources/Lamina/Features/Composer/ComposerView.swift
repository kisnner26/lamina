import SwiftUI
import UniformTypeIdentifiers

struct ComposerView: View {
    @Bindable var model: ComposerViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
                ComposerHeaderView()
                ProviderPickerView(model: model)
                GenerationModePickerView(model: model)
                SourceEditorView(model: model)
                DirectionEditorView(model: model)
                GenerateButton(model: model)
            }
            .padding(24)
        }
        .scrollIndicators(.hidden)
        .background(DesignTokens.elevated.opacity(0.72))
        .fileImporter(
            isPresented: $model.isImporterPresented,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true,
            onCompletion: handleImport
        )
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls): model.importImages(from: urls)
        case .failure(let error):
            model.errorMessage = error.localizedDescription
            model.isShowingError = true
        }
    }
}
