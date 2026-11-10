import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One of today's or tomorrow's entries. Tapping it opens the entry in the
/// Schedule tab.
struct NowEntryRow: View {
    let entry: NowEntry

    @Environment(AppRouter.self) private var router
    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button {
            router.selectedTab = .schedule
            router.scheduleFocus = .event(id: entry.eventID)
        } label: {
            let layout =
                dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
                : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 12))
            layout {
                time
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(isPast ? .secondary : .primary)
                    .frame(minWidth: dynamicTypeSize.isAccessibilitySize ? nil : 84, alignment: .leading)

                VStack(alignment: .leading, spacing: 6) {
                    NowTitle(text: entry.title)
                        .strikethrough(entry.state == .cancelled)
                        .foregroundStyle(isPast ? .secondary : .primary)
                    NowFlowLayout(spacing: 6) {
                        EventChips(event: entry.event, saleMark: entry.saleMark)
                        ForEach(platforms, id: \.rawValue) { platform in
                            PlatformMark(platform: platform, showsName: false)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private var isPast: Bool {
        entry.state == .done || entry.state == .cancelled
    }

    /// The entry's JST time; an estimate reads "about", and an entry
    /// without a clock time says the time is to be announced.
    @ViewBuilder private var time: some View {
        let calendarEntry = entry.calendarEntry
        if let startsAt = calendarEntry.startsAt,
            JSTTimeFormat.showsTime(startsAt: startsAt, timePrecision: calendarEntry.timePrecision)
        {
            if entry.isApproximate {
                Text(.Now.approximately(JSTTimeFormat.time(startsAt, locale: locale)))
            } else {
                JSTTimeLabel(entry: calendarEntry)
            }
        } else {
            Text(.Now.timeTBA)
        }
    }

    private var platforms: [EventPlatform] {
        entry.event.platforms ?? entry.event.platform.map { [$0] } ?? []
    }
}
