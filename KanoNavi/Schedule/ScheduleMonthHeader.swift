import KanoNaviCore
import SwiftUI

/// The month on screen as a fixed header styled like a large title, as in
/// Calendar, where the month name never collapses: it stays put while the
/// day list or the months below it scroll. At accessibility text sizes the
/// month is abbreviated so the year stays.
struct ScheduleMonthHeader: View {
    let month: JapanDate

    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Text(verbatim: month.monthTitle(locale: locale, abbreviated: dynamicTypeSize.isAccessibilitySize))
            .font(.largeTitle.bold())
            .lineLimit(2)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 2)
            .padding(.bottom, 6)
            // A month named while dragging cross-fades in place.
            .contentTransition(.interpolate)
            .accessibilityAddTraits(.isHeader)
    }
}
