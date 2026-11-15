import SwiftUI

extension View {
    /// Registers More's screens on the enclosing `NavigationStack`.
    ///
    /// - Parameter rootAppeared: Called with the screen at the bottom of
    ///   `path` whenever it comes into view.
    func moreDestinations(
        path: Binding<NavigationPath>, rootAppeared: ((MoreDestination) -> Void)? = nil
    ) -> some View {
        navigationDestination(for: MoreDestination.self) { destination in
            MoreDestinationScreen(destination: destination)
                .onAppear {
                    if path.wrappedValue.count == 1 {
                        rootAppeared?(destination)
                    }
                }
        }
    }

    /// Lets a Journey milestone push its Works release onto the stack this
    /// modifies, and replaces `path` with the one the router asks `tab` to
    /// show.
    func moreStack(for tab: AppTab, path: Binding<NavigationPath>) -> some View {
        modifier(MoreStack(tab: tab, path: path))
    }
}

private struct MoreStack: ViewModifier {
    @Environment(AppRouter.self) private var router: AppRouter?
    let tab: AppTab
    @Binding var path: NavigationPath

    func body(content: Content) -> some View {
        content
            .environment(
                \.journeyOpenRelease,
                JourneyOpenRelease { releaseID in
                    path.append(MoreDestination.worksRelease(releaseID))
                }
            )
            .onChange(of: router?.stackRequest, initial: true) { _, request in
                guard let request, request.tab == tab else { return }
                router?.stackRequest = nil
                path = NavigationPath(request.path)
            }
    }
}
