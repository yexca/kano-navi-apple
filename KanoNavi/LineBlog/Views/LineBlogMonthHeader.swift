import SwiftUI

/// A month's header in the article list: the month and how many articles
/// it holds.
struct LineBlogMonthHeader: View {
    let month: LineBlogIndexListing.Month

    @Environment(\.locale) private var locale

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(verbatim: month.key.title(locale: locale))
            Spacer(minLength: 8)
            Text(.LineBlog.articleCount(month.posts.count))
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}
