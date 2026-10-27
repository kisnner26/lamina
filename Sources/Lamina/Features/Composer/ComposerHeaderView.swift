import SwiftUI

struct ComposerHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("lamina")
                .font(DesignTokens.displayFont)
                .tracking(-1.2)
            Text("source in. original deck out.")
                .font(.callout.monospaced())
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}
