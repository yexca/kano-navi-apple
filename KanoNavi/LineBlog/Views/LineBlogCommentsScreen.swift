import KanoNaviCore
import SwiftUI

/// The archived reader comments of one article, newest first, under the
/// archive's rights notice.
struct LineBlogCommentsScreen: View {
    @State private var model: DocumentModel<LineBlogCommentsRequest>

    init(client: APIClient, articleID: String) {
        _model = State(
            initialValue: DocumentModel(
                client: client, request: LineBlogCommentsRequest(articleID: articleID)))
    }

    var body: some View {
        ZStack {
            if let response = model.value {
                LineBlogCommentsList(comments: response.comments, notice: model.notice, reload: model.reload)
            } else if LineBlogArticleFailure.isNotFound(model.failure) {
                LineBlogNotFoundView()
            } else {
                DocumentUnavailableView(reason: model.failureReason, reload: model.reload)
            }
        }
        .navigationTitle(.LineBlog.comments)
        .inlineNavigationTitle()
        .task {
            await model.load()
        }
    }
}
