/// The app's top-level tabs, in display order.
///
/// A tab bar shows Now, Schedule, Posts, Videos and More. A sidebar shows
/// the first four and lists More's screens as tabs of their own instead of
/// More; see `RootView`.
enum AppTab: Hashable {
    case now
    case schedule
    case posts
    case videos
    case more
    case journey
    case works
    case lineBlog
    case settings
    case about

    /// The More screen this sidebar-only tab shows at its root, or `nil` for
    /// a tab both presentations show and for More itself.
    var moreDestination: MoreDestination? {
        MoreItem.all.first { $0.tab == self }?.destination
    }

    /// The sidebar-only tab that shows `destination` at its root, if any.
    init?(sidebarRoot destination: MoreDestination) {
        guard let item = MoreItem.all.first(where: { $0.destination == destination }) else { return nil }
        self = item.tab
    }
}
