import SwiftUI

extension View {
    /// Tells the router whether the tab view around this tab's content shows
    /// a sidebar or a tab bar, whenever that changes.
    func reportsTabPresentation() -> some View {
        modifier(TabPresentationReporter())
    }
}

private struct TabPresentationReporter: ViewModifier {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(\.tabBarPlacement) private var placement

    func body(content: Content) -> some View {
        content
            .onChange(of: placement, initial: true) { _, placement in
                guard let placement else { return }
                router?.tabPresentationChanged(showsSidebar: placement == .sidebar)
            }
    }
}
