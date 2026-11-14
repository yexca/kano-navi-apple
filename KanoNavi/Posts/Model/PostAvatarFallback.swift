import Foundation

/// The dashboard's avatars, for posts whose page leaves its account avatars
/// out.
struct PostAvatarFallback: Equatable {
    /// The dashboard's `accountAvatars`.
    var accountAvatars: [String: URL?]?
    /// Kano's profile avatar, for Kano's own posts without an account avatar.
    var profileAvatarURL: URL?
}
