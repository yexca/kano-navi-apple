import Foundation

public enum ContentLocale: String, Codable, Equatable, Sendable, CaseIterable {
  case en
  case ja
  case zhHans

  public init(interfaceLocale: Locale) {
    let language = interfaceLocale.language.languageCode?.identifier ?? "en"
    self = language == "ja" ? .ja : language == "zh" ? .zhHans : .en
  }

  public var apiLocale: String { self == .zhHans ? "zh-CN" : rawValue }
}
