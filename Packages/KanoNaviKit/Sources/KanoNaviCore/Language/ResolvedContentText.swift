import Foundation

public struct ResolvedContentText: Equatable, Sendable {
  public var text: String
  public var isTranslation: Bool
  public var origin: TranslationOrigin?
  public var original: String
  public init(text: String, isTranslation: Bool, origin: TranslationOrigin?, original: String) {
    self.text = text
    self.isTranslation = isTranslation
    self.origin = origin
    self.original = original
  }
}
