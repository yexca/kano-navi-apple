import Foundation

/// An image of the Now tab that opens in the viewer: the profile's banner or
/// avatar, or the spotlight's cover.
struct NowPicture: Equatable, Identifiable {
    enum Role: Equatable, Hashable {
        case banner
        case avatar
        case cover
    }

    var role: Role
    var url: URL

    var id: Role { role }

    /// The profile's banner and avatar that it has, in that order.
    static func profile(_ profile: NowProfile) -> [NowPicture] {
        [
            profile.bannerURL.map { NowPicture(role: .banner, url: $0) },
            profile.avatarURL.map { NowPicture(role: .avatar, url: $0) },
        ].compactMap(\.self)
    }
}
