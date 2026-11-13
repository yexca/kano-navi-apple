/// A screen the More tab opens.
enum MoreDestination: Hashable {
    case journey
    case works
    /// One Works release, by release ID, opened from a Journey milestone.
    case worksRelease(String)
    case lineBlog
    case settings
    case about
}
