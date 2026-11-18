import KanoNaviCore
import SwiftUI

/// Why the Add Server sheet did not add a server.
enum AddServerProblem: Equatable {
    case notHTTPS
    case invalid
    case duplicate
    case unreachable
    case incompatible

    init(_ error: ServerAddressError) {
        switch error {
        case .notHTTPS: self = .notHTTPS
        case .empty, .invalid: self = .invalid
        }
    }

    var message: LocalizedStringResource {
        switch self {
        case .notHTTPS: .More.serverProblemNotHTTPS
        case .invalid: .More.serverProblemInvalid
        case .duplicate: .More.serverProblemDuplicate
        case .unreachable: .More.serverProblemUnreachable
        case .incompatible: .More.serverProblemIncompatible
        }
    }
}
