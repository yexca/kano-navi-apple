import Foundation

public enum RequestValidationError: Error, Equatable, Sendable {
    case invalidDateRange
    case invalidPage
    case invalidPageSize
    case invalidCategory
    case invalidAccount
    /// A LINE BLOG article ID that is not an article number.
    case invalidArticleID
}
