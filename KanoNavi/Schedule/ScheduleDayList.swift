import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The selected day's entries under the List mode's month, in a plain list
/// that scrolls on its own and pulls to refresh, or a centered line when the
/// day has none.
struct ScheduleDayList: View {
    let entries: [ScheduleDayEntry]
    let isLoading: Bool
    let isLoaded: Bool
    let contentLanguage: ContentLanguage
    let open: (ScheduleEvent) -> Void
    let refresh: () async -> Void

    var body: some View {
        List {
            ForEach(entries) { item in
                Button {
                    open(item.event)
                } label: {
                    ScheduleDayEntryRow(item: item, contentLanguage: contentLanguage)
                }
                .tint(.primary)
            }
        }
        .listStyle(.plain)
        .overlay {
            if entries.isEmpty {
                emptyState
            }
        }
        .refreshable {
            await refresh()
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if isLoading, isLoaded == false {
            ProgressView(.Schedule.loading)
        } else if isLoaded {
            Text(.Schedule.noEntries)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}
