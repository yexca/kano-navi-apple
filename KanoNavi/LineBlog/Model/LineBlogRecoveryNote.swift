import Foundation
import KanoNaviCore

/// The words for a picture that was added after the recovery archive.
nonisolated enum LineBlogRecoveryNote {
    /// The note under a picture found as `recovery`; a code this app does
    /// not know gets a neutral note.
    static func text(for recovery: LineBlogImageRecovery) -> LocalizedStringResource {
        switch recovery {
        case .standIn: .LineBlog.recoveryStandIn
        case .tweet: .LineBlog.recoveryTweet
        case .unknown: .LineBlog.recoveryOther
        }
    }
}
