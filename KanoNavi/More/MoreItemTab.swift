import SwiftUI

/// A sidebar tab that shows one of More's screens at the root of its own
/// `NavigationStack`.
struct MoreItemTab: View {
    let item: MoreItem
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            MoreDestinationScreen(destination: item.destination)
                .moreDestinations(path: $path)
        }
        .moreStack(for: item.tab, path: $path)
    }
}
