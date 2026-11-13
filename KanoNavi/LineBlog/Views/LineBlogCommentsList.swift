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

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(.LineBlog.commentsNote)
                        .font(.subheadline)
                    Text(.LineBlog.rightsNotice)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            if comments.isEmpty {
                Section {
                    ContentUnavailableView {
                        Label {
                            Text(.LineBlog.commentsNoneTitle)
                        } icon: {
                            Image(systemName: "bubble.left")
                        }
                    } description: {
                        Text(.LineBlog.commentsNone)
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
        .listStyle(.insetGrouped)
        .refreshable {
            await reload()
        }
    }
}
