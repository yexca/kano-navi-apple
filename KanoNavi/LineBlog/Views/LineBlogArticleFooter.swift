import KanoNaviCore
import SwiftUI

/// The end of an article: the way to its archived comments with their
/// count, the older and the newer article, and where the article was
/// recovered from.
struct LineBlogArticleFooter: View {
    let response: LineBlogPostResponse
    /// The archive's article list; empty when it has not been read.
    let summaries: [LineBlogPostSummary]
    /// Replaces the article on screen with a neighbour.
    let show: (String) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Divider()

            // The article states its own count; a copy cached before the
            // service counted them takes it from the article list.
            LineBlogCommentsLink(
                articleID: response.post.id,
                count: response.post.commentCount ?? summary(response.post.id)?.commentCount)

            if response.previousID != nil || response.nextID != nil {
                let layout =
                    dynamicTypeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10))
                    : AnyLayout(HStackLayout(alignment: .top, spacing: 10))
                layout {
                    // `previousID` is the older article, `nextID` the newer.
                    if let id = response.previousID {
                        LineBlogNeighborButton(direction: .older, title: summary(id)?.title) {
                            show(id)
                        }
                    }
                    if let id = response.nextID {
                        LineBlogNeighborButton(direction: .newer, title: summary(id)?.title) {
                            show(id)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(.LineBlog.sources)
                    .font(.subheadline.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)
                if let url = LineBlogLinkTarget.outsideURL(response.post.url) {
                    LineBlogProvenanceLink(title: .LineBlog.originalAddress, url: url)
                }
                if let url = LineBlogLinkTarget.outsideURL(response.post.archiveURL) {
                    LineBlogProvenanceLink(title: .LineBlog.archivedCapture, url: url)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func summary(_ id: String) -> LineBlogPostSummary? {
        summaries.first { $0.id == id }
    }
}
