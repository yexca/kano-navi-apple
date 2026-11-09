import Foundation

public struct ArchiveAdjacent: Codable, Equatable, Sendable {
    public var previous: JapanDate?
    public var next: JapanDate?
    public init(previous: JapanDate? = nil, next: JapanDate? = nil) {
        self.previous = previous
        self.next = next
    }
}
