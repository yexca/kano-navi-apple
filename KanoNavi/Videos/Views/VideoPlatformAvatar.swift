import SwiftUI

/// The platform a timeline item opens, as a logo in a small circle where a
/// video app shows the channel's avatar.
struct VideoPlatformAvatar: View {
    let destination: NowLink.Destination?

    @ScaledMetric(relativeTo: .callout) private var diameter = 36

    var body: some View {
        Circle()
            .fill(.fill.tertiary)
            .frame(width: diameter, height: diameter)
            .overlay {
                icon
                    .font(.callout)
                    .foregroundStyle(.primary)
            }
            .accessibilityHidden(true)
    }

    @ViewBuilder private var icon: some View {
        if let destination {
            NowLinkButtons.icon(for: destination)
        } else {
            Image(systemName: "play.rectangle")
        }
    }
}
