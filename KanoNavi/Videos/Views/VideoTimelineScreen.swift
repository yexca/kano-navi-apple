import KanoNaviCore
import SwiftUI

/// The video timeline: a feed of every dated video newest first by Japan
/// month, paged as it scrolls, narrowed by the filter menus and started at a
/// month chosen in the month menu. The navigation subtitle names the section
/// at the top, On Air or a month, abbreviated at accessibility text sizes. A
/// failed read keeps the videos on screen and says so.
struct VideoTimelineScreen: View {
    @State private var model: VideoTimelineModel
    /// The `id` of the first section with a video on screen, once one is.
    @State private var topSectionID: String?

    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
            LazyVStack(alignment: .leading, spacing: 0) {
                if let notice = model.notice {
                    VideoTimelineStatusNotice(notice: notice, retry: retry)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }

                VideoTimelineItems(model: model)
            }
            .scrollTargetLayout()
        }
        // Reports only when a video comes on or goes off screen, and sets
        // the state only when the top section changes. The feed runs under
        // the navigation bar, so a video counts while 30% of it shows: about
        // until it slides under the bar.
        .onScrollTargetVisibilityChange(idType: VideoTimelineSlot.self, threshold: 0.3) { slots in
            guard let id = VideoTimelineSection.topID(of: model.sections, visible: slots),
                id != topSectionID
            else { return }
            topSectionID = id
        }
        // Each start is its own feed, shown from its top, even when its
        // pages were read before.
        .id(model.start)
        // The covers at the top are drawn on the first frame when the disk
        // cache has them.
        .environment(\.mediaImageDecodesCachedFilesAtOnce, true)
        .refreshable(action: model.refresh)
        .navigationTitle(.tabVideos)
        .navigationSubtitle(subtitle ?? Text(verbatim: ""))
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
        .onChange(of: model.start) {
            // A new feed is shown from its top.
            topSectionID = nil
        }
        .task(id: model.start) {
            await model.loadIfNeeded()
        }
        .task(id: model.filter) {
            await model.fill()
        }
    }

    /// The name of the section at the top, or of the first section until a
    /// video is on screen.
    private var subtitle: Text? {
        guard model.listing != nil else { return nil }
        let sections = model.sections
        let top = sections.first { $0.id == topSectionID } ?? sections.first
        return top?.title(locale: locale, abbreviated: dynamicTypeSize.isAccessibilitySize)
    }

    private func retry() {
        Task { await model.refresh() }
    }
}
