import SwiftUI

/// The way from an article to its archived comments, with their count
/// when the article list says it. An article known to have none says so
/// instead.
struct LineBlogCommentsLink: View {
    let articleID: String
    /// The number of archived comments, or `nil` when it is not known.
    let count: Int?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if count == 0 {
            Label {
                Text(.LineBlog.commentsNone)
            } icon: {
                Image(systemName: "bubble.left")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        } else {
            NavigationLink(value: LineBlogDestination.comments(articleID: articleID)) {
                HStack(spacing: 10) {
                    // The words alone at the largest sizes, so they are
                    // not broken inside a word.
                    if dynamicTypeSize.isAccessibilitySize == false {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .accessibilityHidden(true)
                    }
                    Group {
                        if let count {
                            Text(.LineBlog.commentCount(count))
                        } else {
                            Text(.LineBlog.comments)
                        }
                    }
                    .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.forward")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
                .font(.body.weight(.semibold))
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.fill.quaternary, in: .rect(cornerRadius: 12))
                .contentShape(.rect(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }
}
