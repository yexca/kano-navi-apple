import KanoNaviCore
import SwiftUI

/// The body of a single-document screen: loads the model when it appears,
/// draws `content` once there is a document (fresh, cached or read before a
/// failed reload), and `DocumentUnavailableView` until then.
///
///     DocumentView(model: model) { index in
///         List {
///             if let notice = model.notice {
///                 Section { DocumentStatusNotice(notice: notice, reload: model.reload) }
///             }
///             ForEach(index.articles) { … }
///         }
///         .refreshableScreen(action: model.reload)
///     }
///
/// `content` owns the notice and pull to refresh, because where they go
/// depends on the screen's layout.
struct DocumentView<Request: APIRequest, Content: View>: View {
    let model: DocumentModel<Request>
    @ViewBuilder let content: (Request.Response) -> Content

    var body: some View {
        ZStack {
            if let value = model.value {
                content(value)
            } else {
                DocumentUnavailableView(reason: model.failureReason, reload: model.reload)
            }
        }
        .task {
            await model.load()
        }
    }
}
