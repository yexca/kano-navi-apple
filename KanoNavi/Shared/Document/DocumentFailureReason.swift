import Foundation
import KanoNaviCore

/// Why a document could not be read, in the terms a screen words.
nonisolated enum DocumentFailureReason: Equatable, Sendable {
    case offline
    /// The service answered with an HTTP error, such as 404 for an article
    /// it does not have.
    case serverError(status: Int)
    /// The response could not be decoded, or the request was not valid.
    case unreadable
    /// The service sends data this app version cannot read.
    case updateNeeded

    init(_ error: any Error) {
        switch error as? APIError {
        case .offline?, .cancelled?: self = .offline
        case .http(let status)?: self = .serverError(status: status)
        case .incompatible?: self = .updateNeeded
        case .decoding?, nil: self = .unreadable
        }
    }

    /// The sentence shown for this reason.
    var message: LocalizedStringResource {
        switch self {
        case .offline: .Document.reasonOffline
        case .serverError(let status): .Document.reasonServerError(status)
        case .unreadable: .Document.reasonUnreadable
        case .updateNeeded: .Document.reasonUpdateNeeded
        }
    }
}
