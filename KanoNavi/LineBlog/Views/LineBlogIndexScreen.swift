import KanoNaviCore
import SwiftUI

/// The archive's front page: every article by Japan month, newest first,
/// with a menu to jump to a month and an info button for what the archive is.
struct LineBlogIndexScreen: View {
    let model: DocumentModel<LineBlogIndexRequest>

    var body: some View {
        DocumentView(model: model) { index in
            LineBlogIndexList(
                index: index, listing: LineBlogIndexListing(posts: index.posts), notice: model.notice,
                reload: model.reload)
        }
        .navigationTitle(.LineBlog.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
