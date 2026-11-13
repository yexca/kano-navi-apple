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

    /// The watch pages of a recording's platform IDs in the web board's
    /// order, each page once: an ID the record lists twice, such as a
    /// YouTube video that is also among the members-only ones, keeps its
    /// first place. `isGone` says whether the stored data marks a page as
    /// removed or private.
    static func links(
        of ids: PlatformVideoIDs, isGone: (PlatformVideoLink) -> Bool = { _ in false }
    ) -> [WorksUploadLink] {
        ids.links.uniqued(by: \.url).map { WorksUploadLink($0, isGone: isGone($0)) }
    }
}
