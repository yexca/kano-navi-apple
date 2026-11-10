import KanoNaviComponents
import SwiftUI

/// Marks cached data shown after a failed read, with the time it was read.
struct FreshnessLabel: View {
    let schedule: WidgetSchedule
    /// Whether to show only the icon, for the smallest layouts.
    var iconOnly = false

    @Environment(\.locale) private var locale

    var body: some View {
        if schedule.isStale {
            Group {
                if iconOnly {
                    Image(systemName: "exclamationmark.icloud")
                        .accessibilityLabel(Text(message))
                } else {
                    Label {
                        Text(message)
                    } icon: {
                        Image(systemName: "exclamationmark.icloud")
                    }
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
    }

    private var message: LocalizedStringResource {
        if let fetchedAt = schedule.fetchedAt {
            .widgetStaleAsOf(JSTTimeFormat.time(fetchedAt, locale: locale))
        } else {
            .widgetStale
        }
    }
}
