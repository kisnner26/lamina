import SwiftUI

struct PreviewPlaceholderView: View {
    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                RoundedRectangle(cornerRadius: 26)
                    .fill(DesignTokens.accent.opacity(0.08))
                    .frame(width: 260, height: 164)
                    .rotationEffect(.degrees(-5))
                RoundedRectangle(cornerRadius: 26)
                    .fill(.thinMaterial)
                    .stroke(DesignTokens.hairline)
                    .frame(width: 260, height: 164)
                    .rotationEffect(.degrees(4))
                Image(systemName: "rectangle.3.group.fill")
                    .font(.system(size: 52, weight: .light))
                    .foregroundStyle(DesignTokens.accent)
            }
            .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("your deck appears here")
                    .font(DesignTokens.displayFont)
                Text("source → agent → original web presentation")
                    .font(.callout.monospaced())
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RadialGradient(
                colors: [DesignTokens.accent.opacity(0.1), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 420
            )
        )
    }
}
