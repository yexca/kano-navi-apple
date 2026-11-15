/// A path of More's screens for one tab's `NavigationStack` to show.
struct StackRequest: Equatable {
    let tab: AppTab
    let path: [MoreDestination]
}
