import Foundation

public enum ContentLanguage: String, Codable, Equatable, Sendable, CaseIterable {
    case system
    case en
    case ja
    case zhHans
}

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

public struct ResolvedContentText: Equatable, Sendable {
    public var text: String
    public var isTranslation: Bool
    public var origin: TranslationOrigin?
    public var original: String
    public init(text: String, isTranslation: Bool, origin: TranslationOrigin?, original: String) { self.text = text; self.isTranslation = isTranslation; self.origin = origin; self.original = original }
}

public enum ContentLanguageResolver {
    public static func locale(for preference: ContentLanguage, interfaceLocale: Locale = .current) -> ContentLocale {
        switch preference { case .system: ContentLocale(interfaceLocale: interfaceLocale); case .en: .en; case .ja: .ja; case .zhHans: .zhHans }
    }

    public static func resolve(original: String, sourceLanguage: String?, translations: Translations?, preference: ContentLanguage, interfaceLocale: Locale = .current) -> ResolvedContentText {
        let locale = locale(for: preference, interfaceLocale: interfaceLocale)
        if locale == .ja, sourceLanguage?.lowercased().hasPrefix("ja") == true {
            return ResolvedContentText(text: original, isTranslation: false, origin: nil, original: original)
        }
        if let translation = translations?[locale], translation.text.isEmpty == false {
            return ResolvedContentText(text: translation.text, isTranslation: true, origin: translation.origin, original: original)
        }
        return ResolvedContentText(text: original, isTranslation: false, origin: nil, original: original)
    }
}
