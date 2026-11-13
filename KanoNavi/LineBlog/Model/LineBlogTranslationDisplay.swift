import Foundation
import KanoNaviCore

/// Which machine translation an article shows.
nonisolated enum LineBlogTranslationDisplay {
    /// The language whose translations follow each paragraph: the content
    /// language when it is Chinese or English and the reader has not turned
    /// translations off. Japanese is the original, so it shows none.
    static func locale(content: ContentLocale, isOn: Bool) -> ContentLocale? {
        guard isOn, content != .ja else { return nil }
        return content
    }
}
