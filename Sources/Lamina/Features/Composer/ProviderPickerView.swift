import SwiftUI

struct ProviderPickerView: View {
    @Bindable var model: ComposerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
            Text("agent")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)

            Picker("Agent", selection: $model.provider) {
                ForEach(AIProvider.allCases) { provider in
                    Text(provider.displayName)
                        .tag(provider)
                }
            }
            .pickerStyle(.segmented)

            Label(statusText, systemImage: statusIcon)
                .font(.footnote)
                .foregroundStyle(model.isProviderAvailable(model.provider) ? Color.secondary : Color.orange)
        }
    }

    private var statusText: String {
        model.isProviderAvailable(model.provider)
            ? "sesión local disponible"
            : "cli no encontrado"
    }

    private var statusIcon: String {
        model.isProviderAvailable(model.provider)
            ? "checkmark.circle.fill"
            : "exclamationmark.triangle.fill"
    }
}
