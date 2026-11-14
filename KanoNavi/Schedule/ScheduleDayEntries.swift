import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The selected day's entries in the List mode, or one line saying it is
/// loading or has nothing.
struct ScheduleDayEntries: View {
    let model: ScheduleModel
    let contentLanguage: ContentLanguage
    let open: (ScheduleEvent) -> Void

    var body: some View {
        let entries = model.entries(on: model.selectedDate)
        if entries.isEmpty == false {
            ForEach(entries) { item in
                Button {
                    open(item.event)
                } label: {
                    ScheduleDayEntryRow(item: item, contentLanguage: contentLanguage)
                }
                .tint(.primary)
            }
        } else if model.month == nil, model.isLoading {
            HStack(spacing: 8) {
                ProgressView()
                Text(.Schedule.loading)
                    .foregroundStyle(.secondary)
            }
        } else if model.month != nil {
            Text(.Schedule.noEntries)
                .foregroundStyle(.secondary)
        }
    }
}
