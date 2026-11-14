import KanoNaviCore
import SwiftUI

/// The video timeline: every dated video newest first by Japan month, paged
/// as the list scrolls, narrowed by the filter menu and started at a month
/// chosen in the month menu. A failed read keeps the videos on screen and
/// says so.
struct VideoTimelineScreen: View {
    @State private var model: VideoTimelineModel

    init(client: APIClient) {
        _model = State(
            initialValue: VideoTimelineModel(
                months: VideoTimelineSource.months(client: client),
                page: VideoTimelineSource.page(client: client)))
    }

    var body: some View {
        List {
            if let notice = model.notice {
                Section {
                    VideoTimelineStatusNotice(notice: notice, retry: retry)
                }
            }

            VideoTimelineItems(model: model)
        }
        // Each start is its own list, shown from its top, even when its
        // pages were read before.
        .id(model.start)
        .listStyle(.insetGrouped)
        .refreshable(action: model.refresh)
        .navigationTitle(.tabVideos)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                VideoFilterMenu(filter: $model.filter)
            }
            if let index = model.index, index.months.isEmpty == false {
                ToolbarItem(placement: .primaryAction) {
                    VideoMonthMenu(index: index, selection: $model.start)
                }
            }
        }
        .task(id: model.start) {
            await model.loadIfNeeded()
        }
        .task(id: model.filter) {
            await model.fill()
        }
    }

    private func retry() {
        Task { await model.refresh() }
    }
}
