import SwiftUI

/// The live mark: a red dot and the word "Live", never color alone.
struct NowLiveBadge: View {
    var body: some View {
        Label {
            Text(.Now.liveBadge)
        } icon: {
            Image(systemName: "circle.fill")
                .imageScale(.small)
                .foregroundStyle(.red)
        }
        .font(.caption.weight(.bold))
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(.red.opacity(0.15), in: .capsule)
        .labelStyle(NowCompactLabelStyle())
    }
}

#Preview {
    NowLiveBadge()
}
