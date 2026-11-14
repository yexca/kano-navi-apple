import SwiftUI
import WidgetKit

/// The heading of the list widgets: the avatar, a title, and a detail such
/// as the date range, or the cached-data note in its place.
struct WidgetHeader: View {
    let title: LocalizedStringResource
    let schedule: WidgetSchedule
    var detail: String?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .subheadline) private var avatarSize = 22.0

    var body: some View {
        HStack(spacing: 6) {
            Image(.avatar)
                .resizable()
                .widgetAccentedRenderingMode(.desaturated)
                .frame(width: avatarSize, height: avatarSize)
                .clipShape(.circle)
                .accessibilityHidden(true)
            Text(title)
                .font(.subheadline.weight(.bold))
            Spacer(minLength: 4)
            if schedule.isStale {
                FreshnessLabel(schedule: schedule, iconOnly: dynamicTypeSize.isAccessibilitySize)
            } else if let detail {
                Text(detail)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .lineLimit(1)
    }
}
