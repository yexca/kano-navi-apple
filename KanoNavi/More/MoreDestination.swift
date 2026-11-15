/// A screen the More tab, or a sidebar tab of its own, opens.
enum MoreDestination: Hashable {
    case journey
    case works
    /// One Works release, by release ID, opened from a Journey milestone.
    case worksRelease(String)
    case lineBlog
    case settings
    case notifications
    case about
}
