import KanoNaviCore
import SwiftUI

/// The archive inside the More tab's navigation stack: the index, and the
/// destinations its screens push.
///
/// The index document is read once here and handed to the article screens,
/// which take an article's comment count and its neighbours' titles from
/// it.
struct LineBlogArchive: View {
    let client: APIClient
    @State private var index: DocumentModel<LineBlogIndexRequest>

    init(client: APIClient) {
        self.client = client
        _index = State(initialValue: DocumentModel(client: client, request: LineBlogIndexRequest()))
    }

    var body: some View {
        LineBlogIndexScreen(model: index)
            .navigationDestination(for: LineBlogDestination.self) { destination in
                switch destination {
                case .article(let id):
                    LineBlogArticleScreen(client: client, index: index, articleID: id)
                case .comments(let articleID):
                    LineBlogCommentsScreen(client: client, articleID: articleID)
                }
            }
    }
}
