import SwiftUI

/// Shown for an article number the archive does not have.
struct LineBlogNotFoundView: View {
    var body: some View {
        ContentUnavailableView {
            Label {
                Text(.LineBlog.notFoundTitle)
            } icon: {
                Image(systemName: "doc.questionmark")
            }
        }
    }
}

#Preview {
    LineBlogNotFoundView()
}
