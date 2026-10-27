import SwiftUI

struct RootView: View {
    @State private var model = ComposerViewModel()

    var body: some View {
        HSplitView {
            ComposerView(model: model)
                .frame(minWidth: 340, idealWidth: 390, maxWidth: 470)
            PreviewPanel(model: model)
                .frame(minWidth: 620)
        }
        .background(DesignTokens.canvas)
        .preferredColorScheme(.dark)
        .alert("generation stopped", isPresented: $model.isShowingError) {
        } message: {
            Text(model.errorMessage)
        }
    }
}
