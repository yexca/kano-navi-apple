import SwiftUI

/// How a piece of running text is set: the article's own words, or a
/// translation under them.
nonisolated enum LineBlogTextStyle: Sendable {
    case original
    case translation
}
