import KanoNaviCore
import SwiftUI
import WidgetKit

/// The state of the entry a widget leads with: "● Live" on red, or "Next"
/// tinted with Berry. Live is a dot and a word, never color alone. Only the
/// words are accented: the system draws the accented group opaque, which
/// would hide them in their fill.
struct StatusCapsule: View {
    let isLive: Bool

    @Environment(\.widgetRenderingMode) private var renderingMode
    @ScaledMetric(relativeTo: .caption2) private var dotSize = 6.0

    var body: some View {
        Group {
            if isLive {
                HStack(spacing: 3) {
                    Circle()
                        .frame(width: dotSize, height: dotSize)
                        .accessibilityHidden(true)
                    Text(DisplayCodeLabels.eventState(.live))
                }
                .foregroundStyle(isFullColor ? Color.white : Color.primary)
                .widgetAccentable()
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(isFullColor ? Color.red : Color.primary.opacity(0.2), in: .capsule)
            } else {
                Text(.widgetNext)
                    .berryForeground()
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .berryTint(0.15, in: .capsule)
            }
        }
        .font(.caption2.weight(.bold))
        .lineLimit(1)
        .fixedSize()
        .accessibilityElement(children: .combine)
    }

    private var isFullColor: Bool { renderingMode == .fullColor }
}
