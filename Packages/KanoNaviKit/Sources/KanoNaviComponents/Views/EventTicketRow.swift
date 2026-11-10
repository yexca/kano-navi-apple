import KanoNaviCore
import SwiftUI

/// One upcoming schedule entry drawn as a ticket: a stub with its large JST
/// time and how soon it is, beside its title and one line of marks.
///
/// - The stub shows the clock time with "JST", "About 21:00" for an
///   estimate, or "Time TBA", and under it a relative phrase ("in 3 hours",
///   "tomorrow"); see ``EventTicketTiming``. A live entry turns the stub red
///   with the live mark and its end time ("Until 23:00"), or its start when
///   the end is not known.
/// - The title follows the content language, with a ``TranslationMark``
///   when it is a translation.
/// - The marks name the platform, the entry's type and tag, a pending or
///   suspected cancellation, and the members and sale chips.
/// - An entry that is done is dimmed. A cancelled entry is struck through
///   and says "Cancelled" in place of the relative phrase.
///
/// Pass the instant to read the entry against, such as a `TimelineView`'s
/// date or a widget entry's date, so the phrase stays current. At
/// accessibility text sizes the stub moves above the title and everything
/// wraps. Safe in widgets: it has no controls or navigation, so the
/// container decides what a tap does.
public struct EventTicketRow: View {
    private let event: ScheduleEvent
    private let entry: CalendarEntryView
    private let contentLanguage: ContentLanguage
    private let now: Date
    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title3) private var stubWidth = 84.0

    /// Creates a ticket.
    ///
    /// - Parameters:
    ///   - event: The event from the API.
    ///   - entry: The calendar entry being shown, such as a sale's closing;
    ///     the event's first entry when `nil`.
    ///   - contentLanguage: The user's content-language setting.
    ///   - now: The instant the relative phrase and live state are read at.
    public init(
        event: ScheduleEvent, entry: CalendarEntryView? = nil, contentLanguage: ContentLanguage, now: Date
    ) {
        self.event = event
        self.entry = entry ?? event.displayCalendarEntries[0]
        self.contentLanguage = contentLanguage
        self.now = now
    }

    public var body: some View {
        let timing = EventTicketTiming(event: event, entry: entry, now: now)
        let stacked = dynamicTypeSize.isAccessibilitySize
        let layout =
            stacked
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 12))
        layout {
            stub(timing, stacked: stacked)
            details(stacked: stacked)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Stub

    private func stub(_ timing: EventTicketTiming, stacked: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if case .live(let endsAt) = timing {
                LiveIndicator()
                if let detail = liveDetail(endsAt: endsAt) {
                    Text(detail)
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(.red)
                }
            } else {
                time
                    .strikethrough(event.isCancelled)
                if event.isCancelled {
                    Text(DisplayCodeLabels.eventState(.cancelled))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                } else if let relative = timing.relativeText(now: now, locale: locale) {
                    Text(relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(
            minWidth: stacked ? nil : stubWidth, maxHeight: stacked ? nil : .infinity, alignment: .topLeading
        )
        .background(stubFill(timing), in: .rect(cornerRadius: 8))
        .foregroundStyle(isDone ? .secondary : .primary)
    }

    /// The start in Japan time: a large clock time labelled JST, an estimate
    /// with "about", or "Time TBA" without a clock time.
    @ViewBuilder private var time: some View {
        if let startsAt = entry.startsAt,
            JSTTimeFormat.showsTime(startsAt: startsAt, timePrecision: entry.timePrecision)
        {
            let clock = JSTTimeFormat.clockTime(startsAt, locale: locale)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                if entry.timePrecision == "approximate" {
                    Text(ComponentStrings.approximateTime(clock))
                        .font(.headline)
                } else {
                    Text(verbatim: clock)
                        .font(.title3.weight(.semibold))
                }
                Text(ComponentStrings.timeZoneJST)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .monospacedDigit()
        } else {
            Text(ComponentStrings.timeTBA)
                .font(.headline)
        }
    }

    private func liveDetail(endsAt: Date?) -> LocalizedStringResource? {
        if let endsAt, endsAt > now {
            return ComponentStrings.liveUntil(JSTTimeFormat.clockTime(endsAt, locale: locale))
        }
        if let startsAt = entry.startsAt,
            JSTTimeFormat.showsTime(startsAt: startsAt, timePrecision: entry.timePrecision)
        {
            return ComponentStrings.liveSince(JSTTimeFormat.clockTime(startsAt, locale: locale))
        }
        return nil
    }

    private func stubFill(_ timing: EventTicketTiming) -> AnyShapeStyle {
        if case .live = timing {
            return AnyShapeStyle(Color.red.opacity(0.15))
        }
        return AnyShapeStyle(.fill.tertiary)
    }

    // MARK: - Details

    private func details(stacked: Bool) -> some View {
        let title = event.resolvedTitle(preference: contentLanguage, interfaceLocale: locale)
        return VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: title.text)
                .font(.body.weight(.medium))
                .strikethrough(event.isCancelled)
                .foregroundStyle(isDone ? .secondary : .primary)
                .lineLimit(stacked ? nil : 3)
            if title.isTranslation {
                TranslationMark(origin: title.origin)
            }
            marks
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var marks: some View {
        FlowLayout(spacing: 6) {
            if let platform = platforms.first {
                PlatformMark(platform: platform)
            }
            ForEach(platforms.dropFirst(), id: \.rawValue) { platform in
                PlatformMark(platform: platform, showsName: false)
            }
            if let kind {
                Text(kind)
            }
            if event.displayState == .pending || event.displayState == .cancellationReview {
                EventStateBadge(state: event.displayState)
            }
            if event.isMembersOnly {
                MembersChip()
            }
            if let saleMark = entry.saleMark {
                SaleChip(mark: saleMark)
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private var isDone: Bool {
        event.displayState == .done
    }

    private var platforms: [EventPlatform] {
        event.platforms ?? event.platform.map { [$0] } ?? []
    }

    /// The entry's type and tag, such as "Stream · Gameplay". The type is
    /// left out when a chip already says it (members, a sale's mark) and a
    /// tag that reads the same as the type is shown once.
    private var kind: String? {
        var labels: [String] = []
        if event.isMembersOnly == false, entry.saleMark == nil, let typeCode = event.view?.typeCode {
            labels.append(string(DisplayCodeLabels.eventType(typeCode)))
        }
        if let activityCode = event.view?.activityCode {
            let tag = string(DisplayCodeLabels.tag(activityCode))
            if labels.contains(tag) == false {
                labels.append(tag)
            }
        }
        switch labels.count {
        case 0: return nil
        case 1: return labels[0]
        default: return string(ComponentStrings.joined(labels[0], labels[1]))
        }
    }

    private func string(_ resource: LocalizedStringResource) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }
}
