import KanoNaviCore
import SwiftUI

/// The video timeline: a feed of every dated video newest first under
/// pinned Japan month headers, paged as it scrolls, narrowed by the filter
/// menus and started at a month chosen in the month menu. A failed read
/// keeps the videos on screen and says so.
struct VideoTimelineScreen: View {
    @State private var model: VideoTimelineModel

    init(client: APIClient) {
        // Reads the cached newest page at once, so the timeline is on the
        // first frame. `VideosView` builds this screen once per services.
        _model = State(
            initialValue: VideoTimelineModel(
                months: VideoTimelineSource.months(client: client),
                page: VideoTimelineSource.page(client: client),
                cachedFirstPage: VideoTimelineSource.cachedFirstPage(client: client)))
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                if let notice = model.notice {
                    VideoTimelineStatusNotice(notice: notice, retry: retry)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }

                VideoTimelineItems(model: model)
            }
        }
        // Each start is its own feed, shown from its top, even when its
        // pages were read before.
        .id(model.start)
        // The covers at the top are drawn on the first frame when the disk
        // cache has them.
        .environment(\.mediaImageDecodesCachedFilesAtOnce, true)
        .refreshable(action: model.refresh)
        .navigationTitle(.tabVideos)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                VideoKindMenu(selection: $model.filter.kind)
                VideoPlatformMenu(selection: $model.filter.platform)
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
