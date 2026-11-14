import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The selected day's entries under the List mode's month, in a plain list
/// that scrolls on its own and pulls to refresh, under a quiet caption
/// saying the times are in JST, or a centered line when the day has none.
struct ScheduleDayList: View {
    let entries: [ScheduleDayEntry]
    let isLoading: Bool
    let isLoaded: Bool
    let contentLanguage: ContentLanguage
    let open: (ScheduleEvent) -> Void
    let refresh: () async -> Void

    @Environment(\.locale) private var locale

    var body: some View {
        let rows = entries.map { ScheduleDayRowModel($0, contentLanguage: contentLanguage, locale: locale) }
        VStack(spacing: 0) {
            // Times are Japan time; one quiet caption says so for the day.
            if rows.contains(where: \.isTimed) {
                Text(.Schedule.timesInJST)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
                    .padding(.top, 6)
            }
            List {
                ForEach(Array(zip(entries, rows)), id: \.0.id) { item, row in
                    Button {
                        open(item.event)
                    } label: {
                        ScheduleDayEntryRow(row: row)
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
