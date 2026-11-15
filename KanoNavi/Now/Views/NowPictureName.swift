import SwiftUI

extension NowPicture.Role {
    /// What the image is called: what VoiceOver reads for it and what the
    /// viewer's caption says.
    var name: LocalizedStringResource {
        switch self {
        case .banner: .Now.profileBanner
        case .avatar: .Now.profileAvatar
        case .cover: .Now.spotlightCover
        }
    }
}
