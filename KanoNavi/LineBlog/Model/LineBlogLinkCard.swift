import Foundation

/// A link card of an article.
nonisolated struct LineBlogLinkCard: Hashable, Sendable {
    let title: String
    /// The card's summary, left out when it only repeats the title.
    let description: String?
    let image: MediaImageSource?
    /// Where the card leads, or `nil` when its address is not a web page.
    let target: LineBlogLinkTarget?
    /// The linked site's host, shown under the title of an outside card.
    let host: String?
    /// The archived capture of the linked page (provenance).
    let archiveURL: URL?
}
