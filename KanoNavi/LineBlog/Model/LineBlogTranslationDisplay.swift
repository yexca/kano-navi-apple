import Foundation
import KanoNaviCore

/// Which machine translation an article shows.
nonisolated enum LineBlogTranslationDisplay {
    /// Whether the article has anything translated to show in the content
    /// language: a paragraph's translation, or the title in that language.
    /// Only then does the reader offer its switch and its note. Japanese is
    /// the original, so it never has.
    static func isOffered(content: ContentLocale, title: LocalizedText, layout: LineBlogArticleLayout) -> Bool
    {
        guard content != .ja else { return false }
        return layout.hasTranslation(in: content)
            || LineBlogTitle(title, translation: content).translated != nil
    }

    /// The language whose translations show: the content language when the
    /// article has something in it and the reader has not turned
    /// translations off.
    static func locale(content: ContentLocale, isOffered: Bool, isOn: Bool) -> ContentLocale? {
        guard isOffered, isOn, content != .ja else { return nil }
        return content
    }
}
