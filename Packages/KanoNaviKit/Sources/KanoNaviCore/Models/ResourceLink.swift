import Foundation

public struct ResourceLink: Codable, Equatable, Sendable {
    public var id: Int
    public var title: String
    public var detail: String?
    public var url: URL
    public var kind: String?
}
