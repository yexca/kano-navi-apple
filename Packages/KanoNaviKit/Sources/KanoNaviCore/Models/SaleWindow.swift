import Foundation

public struct SaleWindow: Codable, Equatable, Sendable {
    public var startsOn: JapanDate
    public var startsAt: Date?
    public var endsOn: JapanDate?
    public var endsAt: Date?
    public init(
        startsOn: JapanDate, startsAt: Date? = nil, endsOn: JapanDate? = nil, endsAt: Date? = nil
    ) {
        self.startsOn = startsOn
        self.startsAt = startsAt
        self.endsOn = endsOn
        self.endsAt = endsAt
    }
}
