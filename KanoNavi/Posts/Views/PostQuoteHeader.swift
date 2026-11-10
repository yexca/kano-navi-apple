import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// A quote's author and time.
struct PostQuoteHeader: View {
    let quote: PostQuoteCard

    @Environment(\.locale) private var locale

    var body: some View {
        FlowLayout(spacing: 6) {
            if quote.isBilibili {
                PlatformMark(platform: .bilibili, showsName: quote.authorName == nil)
            }
            if let name = quote.authorName {
                Text(verbatim: name)
                    .fontWeight(.semibold)
            }
            if let handle = quote.authorHandle {
                Text(verbatim: handle)
                    .foregroundStyle(.secondary)
            }
            if let publishedAt = quote.publishedAt {
                Text(verbatim: JSTTimeFormat.dateTime(publishedAt, locale: locale))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
        .font(.footnote)
    }
}
