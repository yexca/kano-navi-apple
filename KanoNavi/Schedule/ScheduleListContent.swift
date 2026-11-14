import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The List mode: the month on screen above the selected day's entries,
/// with the month's notice first when it is not a fresh read.
struct ScheduleListContent: View {
    let model: ScheduleModel
    let contentLanguage: ContentLanguage
    let open: (ScheduleEvent) -> Void

    @Environment(\.locale) private var locale

    var body: some View {
        List {
            if let notice = model.notice {
                Section {
                    ScheduleStatusNotice(notice: notice, retry: retry)
                }
            }
            Section {
                ScheduleMonthCalendar(model: model)
                    .listRowInsets(EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8))
            }
            Section {
                ScheduleDayEntries(model: model, contentLanguage: contentLanguage, open: open)
            } header: {
                Text(verbatim: model.selectedDate.dayTitle(locale: locale))
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await model.refresh()
        }
    }

    private func retry() {
        Task { await model.refresh() }
    }
}
