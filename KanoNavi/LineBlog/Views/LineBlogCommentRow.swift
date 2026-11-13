import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One archived comment: its number, the name its writer gave, when it was
/// posted in Japan time, its rating and its text as written.
struct LineBlogCommentRow: View {
    let comment: LineBlogComment

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(.LineBlog.commentNumber(comment.number))
                        .font(.subheadline)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .accessibilityLabel(Text(.LineBlog.commentNumberSpoken(comment.number)))
                    Text(verbatim: comment.author)
                        .font(.subheadline.weight(.semibold))
                }
                Text(verbatim: JSTTimeFormat.dateTime(comment.posted, locale: locale))
                    .font(.footnote)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                if let rating = comment.rating.flatMap(LineBlogRatingDisplay.init) {
                    LineBlogRatingView(rating: rating)
                }
            }
            .accessibilityElement(children: .combine)

            Text(verbatim: comment.body)
                .font(.body)
                .textSelection(.enabled)
        }
        .padding(.vertical, 4)
    }
}
