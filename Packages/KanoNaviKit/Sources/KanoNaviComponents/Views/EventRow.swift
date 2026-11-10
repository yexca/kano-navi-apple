import KanoNaviCore
import SwiftUI

/// One schedule entry: its JST time, its title in the content language, its
/// chips (see ``EventChips``) and its platforms.
///
/// Pass the calendar entry that places the event on the day being shown, so
/// a sale's closing day shows the closing time and mark. Cancelled entries
/// are struck through and say so in words. At accessibility text sizes the
/// time moves above the title, and every part wraps rather than truncates.
/// Safe in widgets: tapping is left to the container, such as a `Button`
/// in the app or a `Link` in a widget.
public struct EventRow: View {
    private let event: ScheduleEvent
    private let entry: CalendarEntryView
    private let contentLanguage: ContentLanguage
    private let includesDate: Bool
    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .subheadline) private var timeWidth = 76.0

    /// Creates a row.
    ///
    /// - Parameters:
    ///   - event: The event from the API.
    ///   - entry: The calendar entry being shown; the event's first entry
    ///     when `nil`.
    ///   - contentLanguage: The user's content-language setting.
    ///   - includesDate: Whether the time also names the date, for lists
    ///     that span several days.
    public init(
        event: ScheduleEvent, entry: CalendarEntryView? = nil, contentLanguage: ContentLanguage,
        includesDate: Bool = false
    ) {
        self.event = event
        self.entry = entry ?? event.displayCalendarEntries[0]
        self.contentLanguage = contentLanguage
        self.includesDate = includesDate
    }

    public var body: some View {
        let stacksTime = includesDate || dynamicTypeSize.isAccessibilitySize
        let layout =
            stacksTime
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 12))
        layout {
            JSTTimeLabel(entry: entry, includesDate: includesDate)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(minWidth: stacksTime ? nil : timeWidth, alignment: .leading)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.body.weight(.medium))
                    .strikethrough(event.isCancelled)
                    .foregroundStyle(event.displayState == .done ? .secondary : .primary)
                    .fixedSize(horizontal: false, vertical: true)
                FlowLayout(spacing: 6) {
                    EventChips(event: event, saleMark: entry.saleMark)
                    ForEach(platforms, id: \.rawValue) { platform in
                        PlatformMark(platform: platform, showsName: false)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var title: String {
        event.resolvedTitle(preference: contentLanguage, interfaceLocale: locale).text
    }

    private var platforms: [EventPlatform] {
        event.platforms ?? event.platform.map { [$0] } ?? []
    }
}
