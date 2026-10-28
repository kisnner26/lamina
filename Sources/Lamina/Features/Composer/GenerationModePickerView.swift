import SwiftUI

struct GenerationModePickerView: View {
    @Bindable var model: ComposerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
            HStack {
                Text("generation logic")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)

                Spacer()

                Text(model.generationMode == .graph ? "token efficient" : "agent planned")
                    .font(.caption2.monospaced())
                    .foregroundStyle(DesignTokens.accent)
            }

            Picker("generation logic", selection: $model.generationMode) {
                ForEach(GenerationMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Text(model.generationMode.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
        }
        .padding(12)
        .background(Color.white.opacity(0.045))
        .clipShape(.rect(cornerRadius: DesignTokens.controlRadius))
    }
}
