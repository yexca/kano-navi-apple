import SwiftUI

/// The More tab of the tab bar: the Journey, Works and LINE BLOG archive
/// screens, Settings and About. A sidebar lists the same screens as tabs of
/// their own instead (`MoreItemTab`). A Journey milestone with a release
/// opens that release's Works screen on the same stack. See
/// `docs/architecture/board-and-timelines.md`.
struct MoreView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    ForEach(MoreItem.archives, content: row)
                }

                Section {
                    ForEach(MoreItem.app, content: row)
                }
            }
            .navigationTitle(.tabMore)
            .moreDestinations(path: $path) { root in
                router?.moreRoot = root
            }
        }
        .moreStack(for: .more, path: $path)
        // The router carries the screen over when an iPad turns the tab bar
        // into a sidebar.
        .onChange(of: path.count) { _, count in
            if count == 0 {
                router?.moreRoot = nil
            }
        }
    }

    private func row(_ item: MoreItem) -> some View {
        NavigationLink(value: item.destination) {
            item.label
        }
    }
}

#Preview {
    MoreView()
}
