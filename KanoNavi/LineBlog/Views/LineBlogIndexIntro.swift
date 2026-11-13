import SwiftUI

/// What the archive is, above the article list: recovered from a closed
/// service, unofficial, with the blog's original address as provenance.
struct LineBlogIndexIntro: View {
    let originalBlogURL: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(.LineBlog.introBody)
                .font(.subheadline)
            Text(.LineBlog.rightsNotice)
                .font(.footnote)
                .foregroundStyle(.secondary)
            if let url = LineBlogLinkTarget.outsideURL(originalBlogURL) {
                LineBlogProvenanceLink(title: .LineBlog.originalBlogAddress, url: url)
            }
        }
        .padding(.vertical, 4)
    }
}
