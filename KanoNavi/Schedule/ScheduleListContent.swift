import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The List mode, as in Calendar: the month's name, the weekday row and the
/// month on screen fixed at the top, edge to edge, with nothing around them
/// that scrolls, then the month's notice when it is not a fresh read, then
/// the selected day's entries.
///
/// Dragging the month pages it (see ``ScheduleMonthPager``); the header
/// names the month a release would show as soon as the drag passes the
/// threshold.
struct ScheduleListContent: View {
    let model: ScheduleModel
    let contentLanguage: ContentLanguage
    let open: (ScheduleEvent) -> Void
    /// The grid mode this List is turning into or out of. Its month is then
    /// drawn as that mode's month, in place, with the next months below it,
    /// and the day's entries slide away.
    var expansion: ScheduleMode?

    /// The month a drag would land on, against the month on screen, for the
    /// header.
    @State private var preview = 0

    var body: some View {
        VStack(spacing: 0) {
            ScheduleMonthHeader(month: model.displayedMonth.addingMonths(preview))
            ScheduleWeekdayRow()
                .padding(.vertical, 6)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            ScheduleHairline()
            // The content below may run past the screen while it grows into
            // a grid mode; laid over a view that takes just the space left,
            // it grows down without moving anything above it.
            Color.clear
                .overlay(alignment: .top) {
                    VStack(spacing: 0) {
                        ScheduleMonthPager(
                            model: model, expansion: expansion, contentLanguage: contentLanguage,
                            preview: $preview)
                        if let expansion {
                            nextMonths(expansion)
                        } else {
                            dayEntries
                        }
                    }
                }
                .clipped()
        }
        // Opaque, so it covers the grid exactly while they hand over.
        .background(.background)
        .allowsHitTesting(expansion == nil)
    }

    /// The months after the one on screen, drawn where a grid mode shows
    /// them while List turns into or out of it.
    private func nextMonths(_ style: ScheduleMode) -> some View {
        ForEach(1...2, id: \.self) { offset in
            let month = model.displayedMonth.addingMonths(offset)
            ScheduleMonthView(
                month: month, today: model.today, days: model.monthDays[month],
                notice: model.notice(for: month), style: style, showsLabel: true, selectedDate: nil,
                contentLanguage: contentLanguage, action: { _ in }, page: nil, retry: {}
            )
            .equatable()
            .fixedSize(horizontal: false, vertical: true)
            .transition(.opacity)
        }
    }

    // MARK: Entries

    @ViewBuilder
    private var dayEntries: some View {
        VStack(spacing: 0) {
            if let notice = model.notice {
                ScheduleStatusNotice(notice: notice, retry: retry)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ScheduleHairline()
            }
            ScheduleDayList(
                entries: model.entries(on: model.selectedDate), isLoading: model.isLoading,
                isLoaded: model.month != nil, contentLanguage: contentLanguage, open: open,
                refresh: model.refresh
            )
            .equatable()
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func retry() {
        Task { await model.refresh() }
    }
}
