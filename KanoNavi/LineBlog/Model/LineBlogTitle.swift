import Foundation
import KanoNaviCore

/// An article's title as the reader shows it: the Japanese original and,
/// when translations show, the title in their language.
nonisolated struct LineBlogTitle: Equatable, Sendable {
    /// The title as written, or the first language that has one. `nil`
    /// when the archive has no title at all.
    let original: String?
    /// The title in the translations' language, when it differs.
    let translated: String?

    /// - Parameter translation: The language whose translations show, from
    ///   `LineBlogTranslationDisplay`.
    init(_ title: LocalizedText, translation: ContentLocale?) {
        original = title.resolved(for: .ja, fallback: LocalizedText.japaneseOriginalFallback)?.text
        if let translation, let text = title.text(in: translation), text != original {
            translated = text
        } else {
            translated = nil
        }
    }

    /// The title a list shows for `locale`: in that language when the
    /// archive has it, otherwise the Japanese original.
    static func listTitle(_ title: LocalizedText, locale: ContentLocale) -> String? {
        title.resolved(for: locale, fallback: LocalizedText.japaneseOriginalFallback)?.text
    }
}
