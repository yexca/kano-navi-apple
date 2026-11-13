import KanoNaviCore
import SwiftUI

/// The reader for one article. Older and Newer swap the article in place,
/// so Back always returns to where the reader was opened from.
struct LineBlogArticleScreen: View {
    let client: APIClient
    let index: DocumentModel<LineBlogIndexRequest>
    @State private var articleID: String

    init(client: APIClient, index: DocumentModel<LineBlogIndexRequest>, articleID: String) {
        self.client = client
        self.index = index
        _articleID = State(initialValue: articleID)
    }

    var body: some View {
        // A new identity per article gives each its own document model,
        // translation switch and scroll position.
        LineBlogArticlePage(client: client, index: index, articleID: articleID, show: show)
            .id(articleID)
    }

    private func show(_ id: String) {
        articleID = id
    }
}
