import SwiftUI

/// The app's tab bar. Each tab owns its own navigation stack.
struct RootView: View {
    @State private var selection = AppTab.now

    var body: some View {
        TabView(selection: $selection) {
            Tab(value: AppTab.now) {
                NowView()
            } label: {
                Label { Text(.tabNow) } icon: { Image(systemName: "dot.radiowaves.left.and.right") }
            }

            Tab(value: AppTab.schedule) {
                ScheduleView()
            } label: {
                Label { Text(.tabSchedule) } icon: { Image(systemName: "calendar") }
            }

            Tab(value: AppTab.videos) {
                VideosView()
            } label: {
                Label { Text(.tabVideos) } icon: { Image(systemName: "play.rectangle") }
            }

            Tab(value: AppTab.posts) {
                PostsView()
            } label: {
                Label { Text(.tabPosts) } icon: { Image(systemName: "text.bubble") }
            }

            Tab(value: AppTab.more) {
                MoreView()
            } label: {
                Label { Text(.tabMore) } icon: { Image(systemName: "ellipsis.circle") }
            }
        }
        .onOpenURL { url in
            // Widget links (`kanonavi://event/<id>`, `kanonavi://schedule`)
            // all land on the Schedule tab.
            if url.scheme == "kanonavi" {
                selection = .schedule
            }
        }
    }
}

#Preview {
    RootView()
}
