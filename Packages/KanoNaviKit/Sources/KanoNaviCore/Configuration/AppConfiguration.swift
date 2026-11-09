import Foundation

/// Build settings the app reads from its Info.plist.
///
/// `Config/Base.xcconfig` sets `API_BASE_URL`, and `Config/Info.plist` exposes
/// it under ``apiBaseURLKey``.
public struct AppConfiguration: Equatable, Sendable {
  public static let apiBaseURLKey = "KanoNaviAPIBaseURL"

  /// The configuration of the running app or extension.
  public static var main: AppConfiguration {
    do {
      return try AppConfiguration(infoDictionary: Bundle.main.infoDictionary ?? [:])
    } catch {
      fatalError("Invalid build configuration: \(error)")
    }
  }

  /// The origin of the Kano Navi service. It always uses HTTPS.
  public let apiBaseURL: URL

  public init(infoDictionary: [String: Any]) throws(AppConfigurationError) {
    guard let rawValue = infoDictionary[Self.apiBaseURLKey] as? String else {
      throw .missingAPIBaseURL
    }

    guard
      let url = URL(string: rawValue),
      url.scheme?.lowercased() == "https",
      let host = url.host(),
      host.isEmpty == false
    else {
      throw .invalidAPIBaseURL(rawValue)
    }

    apiBaseURL = url
  }
}
