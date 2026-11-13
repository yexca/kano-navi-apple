import Foundation
import KanoNaviCore

/// How a failed read of an article or its comments is shown.
nonisolated enum LineBlogArticleFailure {
    /// Whether the failure means the archive has no such article: the
    /// service's 404, or a number that is not an article number and was
    /// never sent.
    static func isNotFound(_ error: (any Error)?) -> Bool {
        switch error {
        case APIError.http(status: 404)?: true
        case RequestValidationError.invalidArticleID?: true
        default: false
        }
    }
}
