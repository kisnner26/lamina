import SwiftUI

struct GenerationBudgetPickerView: View {
    @Bindable var model: ComposerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
            HStack {
                Text("token budget")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                Spacer()
                Text(model.budget.detail)
                    .font(.caption2.monospaced())
                    .foregroundStyle(DesignTokens.accent)
            }

            Picker("token budget", selection: $model.budget) {
                ForEach(GenerationBudget.allCases) { budget in
                    Text(budget.title).tag(budget)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(12)
        .background(Color.white.opacity(0.045))
        .clipShape(.rect(cornerRadius: DesignTokens.controlRadius))
    }
}
