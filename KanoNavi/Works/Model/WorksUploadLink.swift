import Foundation
import KanoNaviCore

/// One watch page of an upload or track, and whether the stored data says
/// nobody can watch it any more.
nonisolated struct WorksUploadLink: Equatable, Identifiable, Sendable {
    let link: PlatformVideoLink
    /// The stored video of this ID is removed or private.
    let isGone: Bool

    var id: URL { link.url }

    init(_ link: PlatformVideoLink, isGone: Bool = false) {
        self.link = link
        self.isGone = isGone
    }
}
