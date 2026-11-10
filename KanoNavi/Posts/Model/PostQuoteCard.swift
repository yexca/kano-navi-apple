import Foundation
import KanoNaviCore

/// The status a post quotes, or the dynamic a Bilibili forward forwards,
/// shown nested in the post.
struct PostQuoteCard: Equatable {
    /// The quoted post was deleted or withheld; only its link is known.
    var isUnavailable: Bool
    /// The author's name to show: their name, else `@handle`; `nil` when
    /// neither is known.
    var authorName: String?
    /// The author's `@handle` beside a known name, for X quotes.
    var authorHandle: String?
    var isBilibili: Bool
    var publishedAt: Date?
    var text: NowContentText?
    var images: [PostImage]
    var url: URL

    init(quote: PostQuote, isBilibili: Bool) {
        isUnavailable = quote.unavailable
        self.isBilibili = isBilibili
        let name = quote.authorName.flatMap { $0.isEmpty ? nil : $0 }
        let handle = quote.authorHandle.flatMap { $0.isEmpty ? nil : $0 }
        if isBilibili {
            // A forwarded dynamic's author shows by name, never by mid.
            authorName = name
            authorHandle = nil
        } else {
            authorName = name ?? handle.map { "@" + $0 }
            authorHandle = name != nil ? handle.map { "@" + $0 } : nil
        }
        publishedAt = quote.publishedAt
        text = quote.text.flatMap { text in
            text.isEmpty
                ? nil
                : NowContentText(text, sourceLanguage: quote.sourceLanguage, translations: quote.translations)
        }
        images = quote.unavailable ? [] : PostImage.ready(quote.media)
        url = quote.url
    }
}
