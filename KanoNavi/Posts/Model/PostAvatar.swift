import Foundation
import KanoNaviCore

/// The round image that leads a post's header, resolved from the board's
/// `accountAvatars` as the web board does: an account's cached avatar; for a
/// hidden one, the handle's initial; without an entry, Kano's profile avatar
/// for Kano's own posts and the initial for a promoted post.
enum PostAvatar: Equatable {
    case image(URL)
    /// The handle's first letter or digit, uppercased, on a sunken circle.
    case initial(String)
    /// A person symbol on a sunken circle, for a promoted post with no handle
    /// to take a letter from, such as a Bilibili one.
    case symbol
    /// An empty circle: an own post while the profile has no avatar.
    case placeholder

    /// - Parameters:
    ///   - accountAvatars: The map keyed by `<source>:<account_key>`, where
    ///     the key is the lowercase handle without `@`.
    ///   - profileAvatarURL: Kano's profile avatar, the fallback for Kano's own
    ///     posts.
    init(post: Post, accountAvatars: [String: URL?]?, profileAvatarURL: URL?) {
        let handle = Self.accountKey(post.accountHandle)
        // Only an X handle gives a letter; a Bilibili handle is a numeric mid.
        // The letter skips leading marks, so `_kano` shows "K".
        let letter =
            post.source == "bilibili"
            ? nil : handle?.first { $0.isLetter || $0.isNumber }.map { String($0).uppercased() }
        let badge = letter.map(PostAvatar.initial) ?? .symbol
        if let handle, let entry = accountAvatars?[post.source + ":" + handle] {
            self = entry.map(PostAvatar.image) ?? badge
        } else if post.promoted == true {
            self = badge
        } else {
            self = profileAvatarURL.map(PostAvatar.image) ?? .placeholder
        }
    }

    /// The API's account key for a handle: lowercase, without `@`; `nil`
    /// when there is no handle.
    private static func accountKey(_ handle: String?) -> String? {
        guard var handle = handle?.trimmingCharacters(in: .whitespaces) else { return nil }
        if handle.hasPrefix("@") {
            handle.removeFirst()
        }
        return handle.isEmpty ? nil : handle.lowercased()
    }
}
