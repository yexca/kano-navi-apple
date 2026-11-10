import KanoNaviCore
import SwiftUI

/// The Posts tab's recent posts for one snapshot, newest first as the
/// dashboard lists them, and the link to the month archive.
struct PostsList: View {
    let snapshot: Dashboard
    let dashboard: DashboardStore
    let showsArchive: Bool

    var body: some View {
        List {
            DashboardNoticeSection(dashboard: dashboard)

            Section {
                if snapshot.posts.isEmpty {
                    Text(.Posts.recentEmpty(snapshot.meta.postWindowDays))
                        .foregroundStyle(.secondary)
                }
                ForEach(snapshot.posts, id: \.id) { post in
                    PostCardView(card: PostCard(post: post))
                }
            } header: {
                Text(.Posts.recentHeader)
            }

            if showsArchive {
                Section {
                    NavigationLink(value: PostsDestination.archive) {
                        Label {
                            Text(.Posts.pastPosts)
                        } icon: {
                            Image(systemName: "clock.arrow.circlepath")
                        }
                    }
                    .accessibilityIdentifier("posts.archive")
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
