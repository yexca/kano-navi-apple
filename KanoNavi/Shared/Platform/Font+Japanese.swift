import SwiftUI

#if os(iOS)
    import UIKit
#else
    import AppKit
#endif

extension Font {
    /// Hiragino Sans, the system's Japanese face, at a text style's size and
    /// scaling with it, for Japanese copy shown in every interface language.
    ///
    /// The system font picks its CJK glyphs from the interface language, and
    /// neither the typesetting language nor the locale changes that: under
    /// Simplified Chinese, kana, kanji and punctuation in Japanese text take
    /// Chinese glyphs. Naming the Japanese face keeps them Japanese.
    static func japanese(_ style: TextStyle) -> Font {
        .custom("HiraginoSans-W3", size: baseSize(of: style), relativeTo: style)
    }

    /// The text style's size at the default text size on this platform.
    private static func baseSize(of style: TextStyle) -> CGFloat {
        #if os(iOS)
            UIFont.preferredFont(
                forTextStyle: platformStyle(style),
                compatibleWith: UITraitCollection(preferredContentSizeCategory: .large)
            ).pointSize
        #else
            NSFont.preferredFont(forTextStyle: platformStyle(style)).pointSize
        #endif
    }

    #if os(iOS)
        private static func platformStyle(_ style: TextStyle) -> UIFont.TextStyle {
            switch style {
            case .largeTitle: .largeTitle
            case .title: .title1
            case .title2: .title2
            case .title3: .title3
            case .headline: .headline
            case .subheadline: .subheadline
            case .callout: .callout
            case .footnote: .footnote
            case .caption: .caption1
            case .caption2: .caption2
            default: .body
            }
        }
    #else
        private static func platformStyle(_ style: TextStyle) -> NSFont.TextStyle {
            switch style {
            case .largeTitle: .largeTitle
            case .title: .title1
            case .title2: .title2
            case .title3: .title3
            case .headline: .headline
            case .subheadline: .subheadline
            case .callout: .callout
            case .footnote: .footnote
            case .caption: .caption1
            case .caption2: .caption2
            default: .body
            }
        }
    #endif
}
