import SwiftUI

/// The LINE BLOG archive screen the More tab opens. See `docs/design.md`.
struct LineBlogView: View {
    var body: some View {
        ContentUnavailableView {
            Label {
                Text(.rootPlaceholderTitle)
            } icon: {
                Image(systemName: "hammer")
            }
        } description: {
            Text(.rootPlaceholderMessage)
        }
        .navigationTitle(.More.moreLineBlog)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LineBlogView()
    }
}
