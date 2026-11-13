import Foundation

/// A text the archive reads (Journey, Works, LINE BLOG) give in each language as
/// `{"ja", "zh-CN", "en"}`, with `null` for a language the data lacks. The
/// service never picks a language; `resolved(for:fallback:)` does.
///
/// An empty string counts as missing, like `null`.
public struct LocalizedText: Codable, Hashable, Sendable {
    public var ja: String?
    public var zhCN: String?
    public var en: String?

    /// The order the Journey and Works pages fall back in: English, then
    /// Japanese, then Chinese.
    public static let defaultFallback: [ContentLocale] = [.en, .ja, .zhHans]

    /// The order for texts written in Japanese, such as LINE BLOG titles:
    /// Japanese, then English, then Chinese.
    public static let japaneseOriginalFallback: [ContentLocale] = [.ja, .en, .zhHans]

    public init(ja: String? = nil, zhCN: String? = nil, en: String? = nil) {
        self.ja = ja
        self.zhCN = zhCN
        self.en = en
    }

    enum CodingKeys: String, CodingKey {
        case ja
        case zhCN = "zh-CN"
        case en
    }

    /// The text in one language, or `nil` when it is `null` or empty.
    public func text(in locale: ContentLocale) -> String? {
        let value =
            switch locale {
            case .ja: ja
            case .zhHans: zhCN
            case .en: en
            }
        guard let value, value.isEmpty == false else { return nil }
        return value
    }

    /// Whether no language has any text.
    public var isEmpty: Bool {
        ContentLocale.allCases.allSatisfy { text(in: $0) == nil }
    }

    /// The text in `locale` when present, else in the first language of
    /// `fallback` that has one. `nil` only when every language is missing.
    public func resolved(
        for locale: ContentLocale,
        fallback: [ContentLocale] = LocalizedText.defaultFallback
    ) -> LocalizedTextResolution? {
        for candidate in [locale] + fallback {
            if let text = text(in: candidate) {
                return LocalizedTextResolution(text: text, locale: candidate, requestedLocale: locale)
            }
        }
        return nil
    }

    /// Resolves for the app's content-language setting; `.system` follows the
    /// interface locale.
    public func resolved(
        for preference: ContentLanguage,
        interfaceLocale: Locale = .current,
        fallback: [ContentLocale] = LocalizedText.defaultFallback
    ) -> LocalizedTextResolution? {
        resolved(
            for: ContentLanguageResolver.locale(for: preference, interfaceLocale: interfaceLocale),
            fallback: fallback
        )
    }
}

/// The text a `LocalizedText` resolved to and the language it is in.
public struct LocalizedTextResolution: Equatable, Sendable {
    public var text: String
    /// The language of `text`.
    public var locale: ContentLocale
    /// The language that was asked for.
    public var requestedLocale: ContentLocale

    public init(text: String, locale: ContentLocale, requestedLocale: ContentLocale) {
        self.text = text
        self.locale = locale
        self.requestedLocale = requestedLocale
    }

    /// Whether the requested language was missing and another one is shown.
    public var isFallback: Bool { locale != requestedLocale }
}
