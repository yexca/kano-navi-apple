import Foundation
import KanoNaviCore

/// One post as the Posts tab shows it, from the dashboard or an archive page.
struct PostCard: Equatable, Identifiable {
    var id: String
    var account: PostAccount
    var avatar: PostAvatar
    /// A related account's post promoted onto the board: the agency's, not
    /// Kano's own.
    var isPromoted: Bool
    var publishedAt: Date
    /// The text, or `nil` when the post has none (a Bilibili dynamic of
    /// emoji only, or a bare forward).
    var text: NowContentText?
    var images: [PostImage]
    var quote: PostQuoteCard?
    /// The original post on X or Bilibili.
    var url: URL

    /// - Parameters:
    ///   - accountAvatars: The snapshot's or archive page's account avatars.
    ///   - profileAvatarURL: Kano's profile avatar, for Kano's own posts without
    ///     an account avatar.
    init(post: Post, accountAvatars: [String: URL?]?, profileAvatarURL: URL?) {
        id = post.id
        account = PostAccount(source: post.source, handle: post.accountHandle)
        avatar = PostAvatar(post: post, accountAvatars: accountAvatars, profileAvatarURL: profileAvatarURL)
        isPromoted = post.promoted == true
        publishedAt = post.publishedAt
        text =
            post.text.isEmpty
            ? nil
            : NowContentText(post.text, sourceLanguage: post.sourceLanguage, translations: post.translations)
        images = PostImage.ready(in: post)
        quote = post.quote.map { PostQuoteCard(quote: $0, isBilibili: post.source == "bilibili") }
        url = post.url
    }

    var isBilibili: Bool { account == .bilibili }

    /// The post's own images, for the viewer.
    var gallery: PostGallery {
        PostGallery(images: images, url: url, isBilibili: isBilibili)
    }
}
