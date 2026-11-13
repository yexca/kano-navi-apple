import KanoNaviCore
import SwiftUI

/// The LINE BLOG archive screen the More tab opens: the list of recovered
/// articles, which leads to the reader and each article's comments. See
/// `docs/design.md`.
struct LineBlogView: View {
    @Environment(\.services) private var services

    var body: some View {
        if let client = services?.client {
            LineBlogArchive(client: client)
        }
    }
}

#Preview {
    NavigationStack {
        LineBlogView()
    }
}
