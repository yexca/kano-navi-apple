import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The Coming Up section: the next entries of the next two weeks under day
/// headers, ending with a link to the full schedule. When nothing is coming
/// up it says so, offers the calendar subscription and lists the most
/// recently ended entries under "Recently". See ``NowComingUp``.
struct NowComingUpSections: View {
    let model: NowComingUpModel
    /// The dashboard's events, for the recently ended entries.
    let dashboardEvents: [ScheduleEvent]
    let feedURL: URL?
    let now: Date

    @Environment(AppRouter.self) private var router
    @Environment(\.locale) private var locale
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AppStorage(AppSettings.contentLanguageKey) private var contentLanguage: ContentLanguage = .system

    var body: some View {
        let comingUp = model.events.map {
            NowComingUp(calendarEvents: $0, dashboardEvents: dashboardEvents, now: now)
        }
        let showsRecent = comingUp?.recent.isEmpty == false

        Section {
            if let notice = model.notice {
                NowComingUpNoticeRow(notice: notice) {
                    Task { await model.reload() }
                }
            }
            if let comingUp {
                if comingUp.days.isEmpty {
                    emptyRow
                } else {
                    ForEach(comingUp.days) { day in
                        dayHeader(day.date, today: comingUp.today)
                        ForEach(day.entries) { entry in
                            ticket(entry)
                        }
                    }
                }
            } else if model.notice == nil {
                loadingRow
            }
            if showsRecent == false {
                fullScheduleRow
            }
        } header: {
            Text(.Now.comingUpHeader)
        }

        if let comingUp, showsRecent {
            Section {
                ForEach(comingUp.recent) { entry in
                    ticket(entry)
                }
                fullScheduleRow
            } header: {
                Text(.Now.recentlyHeader)
            }
        }
    }

    private func dayHeader(_ date: JapanDate, today: JapanDate) -> some View {
        Group {
            if date == today {
                Text(.Now.comingUpToday)
            } else if date == today.addingDays(1) {
                Text(.Now.comingUpTomorrow)
            } else {
                Text(verbatim: JSTTimeFormat.day(date, locale: locale))
            }
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.secondary)
        .accessibilityAddTraits(.isHeader)
        .listRowSeparator(.hidden)
    }

    /// One entry; tapping it opens the entry in the Schedule tab.
    private func ticket(_ entry: NowEntry) -> some View {
        Button {
            router.selectedTab = .schedule
            router.scheduleFocus = .event(id: entry.eventID)
        } label: {
            EventTicketRow(
                event: entry.event, entry: entry.calendarEntry, contentLanguage: contentLanguage, now: now)
        }
        .tint(.primary)
    }

    private var emptyRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(.Now.comingUpEmpty)
                .foregroundStyle(.secondary)
            if let feedURL,
                let webcal = CalendarSubscription.webcalURL(from: feedURL, interfaceLocale: locale)
            {
                Button {
                    openURL(webcal)
                } label: {
                    // Beside the symbol, the title breaks inside a word at
                    // accessibility sizes.
                    if dynamicTypeSize.isAccessibilitySize {
                        Text(.Now.subscribeToCalendar)
                            .multilineTextAlignment(.leading)
                    } else {
                        Label(.Now.subscribeToCalendar, systemImage: "calendar.badge.plus")
                    }
                }
                .buttonStyle(.borderless)
            }
        }
    }

    private var loadingRow: some View {
        HStack(spacing: 8) {
            ProgressView()
            Text(.Now.loading)
                .foregroundStyle(.secondary)
        }
    }

    private var fullScheduleRow: some View {
        Button {
            router.selectedTab = .schedule
            router.scheduleFocus = .date(JapanDate.today(at: now))
        } label: {
            HStack {
                Text(.Now.seeFullSchedule)
                Spacer()
                Image(systemName: "chevron.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .contentShape(.rect)
        }
    }
}
