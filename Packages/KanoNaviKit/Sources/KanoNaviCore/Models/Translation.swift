import Foundation

public struct Translation: Codable, Equatable, Sendable {
    public var text: String
    public var origin: TranslationOrigin
    public var platform: String?

    public init(text: String, origin: TranslationOrigin, platform: String? = nil) {
        self.text = text
        self.origin = origin
        self.platform = platform
    }
}
