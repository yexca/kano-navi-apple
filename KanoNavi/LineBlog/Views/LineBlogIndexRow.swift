import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One article in the list: its first picture, its title in the content
/// language, when it was published in Japan time and how many comments the
/// archive holds.
struct LineBlogIndexRow: View {
    let post: LineBlogPostSummary

    @ContentLocaleSetting private var contentLocale
    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var thumbnailSide: CGFloat = 64

    var body: some View {
        let layout =
            dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 12))
        layout {
            LineBlogThumbnail(media: post.thumbnail)
                .frame(width: min(thumbnailSide, 96), height: min(thumbnailSide, 96))

            VStack(alignment: .leading, spacing: 4) {
                if let title = LineBlogTitle.listTitle(post.title, locale: contentLocale) {
                    Text(verbatim: title)
                        .font(.headline)
                } else {
                    Text(.LineBlog.untitled)
                        .font(.headline)
                }
                Text(verbatim: JSTTimeFormat.dateTime(post.published, locale: locale))
                    .font(.footnote)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                if post.commentCount > 0 {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        // The words alone at the largest sizes, so the
                        // count does not wrap beside its icon.
                        if dynamicTypeSize.isAccessibilitySize == false {
                            Image(systemName: "bubble.left")
                                .accessibilityHidden(true)
                        }
                        Text(.LineBlog.commentCount(post.commentCount))
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}
