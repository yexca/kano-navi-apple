import Foundation

public struct CalendarRequest: APIRequest {
  public typealias Response = CalendarPage
  public let from: JapanDate
  public let to: JapanDate
  public let page: Int
  public let pageSize: Int
  public let path = "/api/calendar"
  public var queryItems: [URLQueryItem] {
    [
      URLQueryItem(name: "from", value: from.rawValue),
      URLQueryItem(name: "to", value: to.rawValue), URLQueryItem(name: "page", value: String(page)),
      URLQueryItem(name: "pageSize", value: String(pageSize)),
    ]
  }
  public init(from: JapanDate, to: JapanDate, page: Int = 1, pageSize: Int = 100) {
    self.from = from
    self.to = to
    self.page = page
    self.pageSize = pageSize
  }
  public func validate() throws {
    guard from <= to, from.addingDays(41) >= to else {
      throw RequestValidationError.invalidDateRange
    }
    guard page > 0 else { throw RequestValidationError.invalidPage }
    guard (1...100).contains(pageSize) else { throw RequestValidationError.invalidPageSize }
  }
}
