import Foundation

public struct CalendarEntryView: Codable, Equatable, Sendable {
  public var saleMark: SaleMark?
  public var startsOn: JapanDate
  public var startsAt: Date?
  public var timePrecision: String
  public init(
    saleMark: SaleMark? = nil, startsOn: JapanDate, startsAt: Date? = nil, timePrecision: String
  ) {
    self.saleMark = saleMark
    self.startsOn = startsOn
    self.startsAt = startsAt
    self.timePrecision = timePrecision
  }
}
