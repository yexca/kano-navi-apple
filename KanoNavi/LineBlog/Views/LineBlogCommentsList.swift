import KanoNaviCore
import SwiftUI

/// The comments of an article, or the note that the archive holds none.
struct LineBlogCommentsList: View {
    let comments: [LineBlogComment]
    let notice: DocumentNotice?
    let reload: () async -> Void

    var body: some View {
        List {
            if let notice {
                Section {
                    DocumentStatusNotice(notice: notice, reload: reload)
                }
            }

            if comments.isEmpty {
                Section {
                    ContentUnavailableView {
                        Label {
                            Text(.LineBlog.commentsNoneTitle)
                        } icon: {
                            Image(systemName: "bubble.left")
                        }
                    }
                }
            } else {
                Section {
                    ForEach(comments) { comment in
                        LineBlogCommentRow(comment: comment)
                    }
                } header: {
                    Text(.LineBlog.commentCount(comments.count))
                }
            }
        }
        .insetGroupedListStyle()
        .readableContentWidth()
        .refreshableScreen {
            await reload()
        }
    }
}
