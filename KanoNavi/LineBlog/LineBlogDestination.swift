/// A screen pushed inside the LINE BLOG archive.
nonisolated enum LineBlogDestination: Hashable, Sendable {
    /// One article, by its number.
    case article(id: String)
    /// The archived comments of an article.
    case comments(articleID: String)
}
