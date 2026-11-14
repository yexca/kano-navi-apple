import KanoNaviCore
import SwiftUI

/// The List mode's calendar: the Monday-first weekday row above one month at
/// a time, which pages sideways to the month before or after it.
struct ScheduleMonthCalendar: View {
    let model: ScheduleModel

    /// The month page in view, kept in step with the model's month.
    @State private var page: JapanDate?

    init(model: ScheduleModel) {
        self.model = model
        _page = State(initialValue: model.displayedMonth)
    }

    var body: some View {
        VStack(spacing: 8) {
            ScheduleWeekdayRow()
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(model.browsableMonths, id: \.self) { month in
                        ScheduleMonthPage(month: month, model: model)
                            .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .scrollPosition(id: $page)
            .onChange(of: page) { _, page in
                if let page {
                    model.showMonth(page)
                }
            }
            .onChange(of: model.displayedMonth) { _, month in
                if page != month {
                    withAnimation {
                        page = month
                    }
                }
            }
        }
        // Seven columns of numbers cannot grow past this size on an iPhone;
        // the entries below the grid keep the full text size.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}
