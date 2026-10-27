import SwiftUI

struct GenerateButton: View {
    let model: ComposerViewModel

    var body: some View {
        Button(action: model.generate) {
            HStack {
                Label(buttonTitle, systemImage: buttonIcon)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .accessibilityHidden(true)
            }
            .font(.headline)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.borderedProminent)
        .tint(DesignTokens.accent)
        .disabled(!model.canGenerate)
        .accessibilityHint("Genera una presentación web usando el agente seleccionado")
    }

    private var buttonTitle: String {
        switch model.status {
        case .idle, .failed: "generate presentation"
        case .preparing: "preparing workspace"
        case .generating(let provider): "designing with \(provider.displayName)"
        case .validating: "checking result"
        case .ready: "generate another version"
        }
    }

    private var buttonIcon: String {
        model.status.isRunning ? "ellipsis" : "sparkles.rectangle.stack"
    }
}
