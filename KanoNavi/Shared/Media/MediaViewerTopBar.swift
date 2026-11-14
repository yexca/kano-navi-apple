import SwiftUI

/// The viewer's Close button and, with more than one picture, its counter.
struct MediaViewerTopBar: View {
    /// The picture shown, counted from 1.
    let position: Int
    let count: Int
    let close: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            Button(.Media.viewerClose, systemImage: "xmark", action: close)
                .keyboardShortcut(.cancelAction)
                .labelStyle(.iconOnly)
                .font(.body.weight(.semibold))
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)

            Spacer()

            if count > 1 {
                Text(.Media.viewerPosition(position, count))
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .glassEffect(in: .capsule)
                    .accessibilityLabel(Text(.Media.viewerPositionSpoken(position, count)))
            }
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }
}

#Preview {
    MediaViewerTopBar(position: 3, count: 12) {}
        .frame(maxHeight: .infinity, alignment: .top)
        .background(.black)
        .environment(\.colorScheme, .dark)
}
