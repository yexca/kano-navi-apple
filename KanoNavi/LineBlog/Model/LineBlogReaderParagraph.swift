import Foundation
import KanoNaviCore

/// A paragraph as the reader lays it out, with its machine translations.
nonisolated struct LineBlogReaderParagraph: Hashable, Sendable {
    /// The Japanese original: text and rows of pictures in reading order.
    let segments: [LineBlogSegment]
    /// The translated paragraphs in Chinese and in English; empty for a
    /// language without one.
    let chinese: [LineBlogRichText]
    let english: [LineBlogRichText]

    /// The translated paragraphs shown after the original for `locale`:
    /// none for Japanese, the original, and none for `nil`.
    func translation(in locale: ContentLocale?) -> [LineBlogRichText] {
        switch locale {
        case .zhHans?: chinese
        case .en?: english
        case .ja?, nil: []
        }
    }
}
