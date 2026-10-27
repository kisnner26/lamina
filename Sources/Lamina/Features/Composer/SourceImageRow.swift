import SwiftUI

struct SourceImageRow: View {
    let image: SourceImage
    let onRemove: (SourceImage) -> Void

    var body: some View {
        HStack(spacing: DesignTokens.compactSpacing) {
            Image(systemName: "photo.fill")
                .foregroundStyle(DesignTokens.accent)
                .frame(width: 28, height: 28)
                .background(DesignTokens.accent.opacity(0.12))
                .clipShape(.rect(cornerRadius: 7))
                .accessibilityHidden(true)

            Text(image.filename)
                .font(.footnote)
                .lineLimit(1)
            Spacer()
            Button("remove \(image.filename)", systemImage: "xmark", action: remove)
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
        }
        .padding(8)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: DesignTokens.compactSpacing))
    }

    private func remove() {
        onRemove(image)
    }
}
