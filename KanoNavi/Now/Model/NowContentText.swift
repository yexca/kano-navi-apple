import Foundation
import KanoNaviCore

/// Wording from the API that follows the content language: a title or post
/// text with its source language and translations.
struct NowContentText: Equatable {
    var original: String
    var sourceLanguage: String?
    var translations: Translations?

    init(_ original: String, sourceLanguage: String? = nil, translations: Translations? = nil) {
        self.original = original
        self.sourceLanguage = sourceLanguage
        self.translations = translations
    }

    /// The wording to show for a content-language preference.
    func resolved(for preference: ContentLanguage, interfaceLocale: Locale) -> ResolvedContentText {
        ContentLanguageResolver.resolve(
            original: original,
            sourceLanguage: sourceLanguage,
            translations: translations,
            preference: preference,
            interfaceLocale: interfaceLocale
        )
    }
}
