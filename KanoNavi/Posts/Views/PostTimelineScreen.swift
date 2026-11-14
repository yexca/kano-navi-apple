import KanoNaviCore
import SwiftUI

/// The post timeline: every post newest first, each in its own card, by
/// Japan month, paged as it scrolls, narrowed by the account menu and started
/// at a month chosen in the month picker. The navigation subtitle names the
/// month at the top, abbreviated at accessibility text sizes. A failed read
/// keeps the posts on screen and says so.
struct PostTimelineScreen: View {
    @State private var model: PostTimelineModel
    /// The `id` of the first section with a post on screen, once one is.
    @State private var topSectionID: String?
    /// The post at the top, which stays in place when the pages are read
    /// again and posts are added or removed above it; empty while the list
    /// is at its top.
    @State private var position = ScrollPosition(idType: TimelineSlot.self)
    /// The board's accounts, from the dashboard's metadata when there is a
    /// snapshot.
    let meta: DashboardMeta?
    /// The dashboard's revision, which changes when the service's data does.
    let revision: Int?
    let avatarFallback: PostAvatarFallback

    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(client: APIClient, meta: DashboardMeta?, revision: Int?, avatarFallback: PostAvatarFallback) {
        // Reads the cached newest page at once, so the timeline is on the
        // first frame. `PostsView` builds this screen once per services.
        let model = PostTimelineModel(
            months: PostTimelineSource.months(client: client), page: PostTimelineSource.page(client: client),
            cachedFirstPage: PostTimelineSource.cachedFirstPage(client: client))
        model.avatarFallback = avatarFallback
        _model = State(initialValue: model)
        self.meta = meta
        self.revision = revision
        self.avatarFallback = avatarFallback
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                if let notice = model.notice {
                    PostTimelineStatusNotice(notice: notice, retry: retry)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }

                PostTimelineItems(model: model)
            }
            .scrollTargetLayout()
        }
        .scrollPosition($position, anchor: .top)
        // A scroll to the top, such as a tap on the tab, does not update the
        // position, which would then pull the list back to the post it
        // held. At the top there is nothing to hold: new posts show above.
        .onScrollGeometryChange(for: Bool.self) { geometry in
            geometry.contentOffset.y <= -geometry.contentInsets.top + 1
        } action: { _, isAtTop in
            if isAtTop, position.viewID != nil {
                position = ScrollPosition(idType: TimelineSlot.self)
            }
        }
        .readableContentWidth()
        .background(Color.groupedBackground)
        // Reports only when a post comes on or goes off screen, and sets the
        // state only when the top section changes. The posts run under the
        // navigation bar, so a post counts while 30% of it shows.
        .onScrollTargetVisibilityChange(idType: TimelineSlot.self, threshold: 0.3) { slots in
            guard let id = PostTimelineSection.topID(of: model.sections, visible: slots), id != topSectionID
            else { return }
            topSectionID = id
        }
        // Each start and account is its own timeline, shown from its top,
        // even when its pages were read before.
        .id(model.key)
        // The images at the top are drawn on the first frame when the disk
        // cache has them.
        .environment(\.mediaImageDecodesCachedFilesAtOnce, true)
        .refreshableScreen(action: model.refresh)
        .navigationTitle(.tabPosts)
        .navigationSubtitle(subtitle ?? Text(verbatim: ""))
        .toolbar {
            ToolbarItem(placement: .barLeading) {
                ArchiveFilterMenu(
                    options: filterOptions, selection: $model.account, title: .Posts.accountFilter
                )
                .accessibilityIdentifier("posts.filter")
            }
            if let index = model.index, index.months.isEmpty == false {
                ToolbarItem(placement: .primaryAction) {
                    MonthPickerButton(index: index, selection: $model.start, unit: .posts)
                        .accessibilityIdentifier("posts.month")
                }
            }
        }
        .onChange(of: model.key) {
            // A new timeline is shown from its top.
            topSectionID = nil
            position = ScrollPosition(idType: TimelineSlot.self)
        }
        .onChange(of: avatarFallback) {
            model.avatarFallback = avatarFallback
        }
        .onChange(of: accounts) {
            // An account the board no longer follows shows every post again.
            if let account = model.account, accounts.contains(where: { $0.code == account }) == false {
                model.account = nil
            }
        }
        // The pages already read are read again when the service's data
        // changes, keeping them on screen until the reads return.
        .onChange(of: revision) { old, new in
            guard old != nil else { return }
            Task { await model.reloadAfterChange(revision: new) }
        }
        .task(id: model.key) {
            await model.loadIfNeeded()
        }
    }

    /// The accounts the filter offers.
    private var accounts: [PostFilterAccount] {
        PostAccountFilter.accounts(meta: meta, counts: model.counts)
    }

    private var filterOptions: [ArchiveFilterOption] {
        PostAccountFilter.options(accounts: accounts, counts: model.counts, allCount: model.allCount)
    }

    /// The month at the top, or of the first post until one is on screen.
    private var subtitle: Text? {
        guard model.listing != nil else { return nil }
        let sections = model.sections
        guard let top = sections.first(where: { $0.id == topSectionID }) ?? sections.first else { return nil }
        let title = top.month.first.monthTitle(
            locale: locale, abbreviated: dynamicTypeSize.isAccessibilitySize)
        return Text(verbatim: title)
    }

    private func retry() {
        Task { await model.refresh() }
    }
}
