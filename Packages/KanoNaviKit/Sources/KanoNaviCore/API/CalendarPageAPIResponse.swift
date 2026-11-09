import Foundation

extension CalendarPage: APIResponse {
  public func validated() throws {
    guard events.allSatisfy({ $0.view != nil }) else { throw APIError.incompatible }
  }

  public func resolvingMedia(against baseURL: URL) -> CalendarPage {
    var value = self
    value.events = value.events.map { $0.resolvingMedia(against: baseURL) }
    value.scheduleImages = value.scheduleImages.map { $0.resolvingMedia(against: baseURL) }
    return value
  }
}
