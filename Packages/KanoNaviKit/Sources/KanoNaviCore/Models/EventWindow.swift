import Foundation

public struct EventWindow: Codable, Equatable, Sendable {
    public var from: JapanDate
    public var to: JapanDate
    public var paginated: Bool
}
