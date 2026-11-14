import KanoNaviCore
import SwiftUI

/// The navigation bar's leading item: the month on screen, large and bold.
/// Tapping it goes back to today.
struct ScheduleMonthTitle: View {
    let month: JapanDate
    let showToday: () -> Void

    @Environment(\.locale) private var locale

    var body: some View {
        let title = month.monthTitle(locale: locale)
        Button(action: showToday) {
            Text(verbatim: title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .buttonStyle(.plain)
        .fixedSize()
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .accessibilityShowsLargeContentViewer {
            Text(verbatim: title)
        }
        .accessibilityLabel(Text(verbatim: title))
        .accessibilityHint(Text(.Schedule.todayHint))
        .accessibilityAction(named: Text(.Schedule.today), showToday)
    }
}
