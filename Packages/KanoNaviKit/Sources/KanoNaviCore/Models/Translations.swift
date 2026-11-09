import Foundation

public struct Translations: Codable, Equatable, Sendable {
    public var en: Translation?
    public var ja: Translation?
    public var zhCN: Translation?
    public init(en: Translation? = nil, ja: Translation? = nil, zhCN: Translation? = nil) {
        self.en = en
        self.ja = ja
        self.zhCN = zhCN
    }
    enum CodingKeys: String, CodingKey {
        case en, ja
        case zhCN = "zh-CN"
    }
    public subscript(locale: ContentLocale) -> Translation? {
        switch locale {
        case .en: en
        case .ja: ja
        case .zhHans: zhCN
        }
    }
}
