import SwiftUI

extension View {
    /// Pull to refresh, as `refreshable(action:)`, which also offers
    /// `action` to the View ▸ Refresh command (⌘R) while this screen is in
    /// front. A Mac draws no refresh control, so there the command is the
    /// way to read the screen again.
    func refreshableScreen(action: @escaping @MainActor () async -> Void) -> some View {
        modifier(ScreenRefreshPublisher(action: action))
    }
}

/// Adds pull to refresh and publishes the screen's refresh while the
/// screen is on screen: a tab not selected and a screen under a pushed one
/// stay in the hierarchy, and must not answer the command.
private struct ScreenRefreshPublisher: ViewModifier {
    let action: @MainActor () async -> Void

    @State private var refresh = ScreenRefresh()
    @State private var isOnScreen = false

    func body(content: Content) -> some View {
        let _ = refresh.update(action)
        content
            .refreshable {
                await action()
            }
            .focusedSceneValue(\.screenRefresh, isOnScreen ? refresh : nil)
            .onAppear {
                isOnScreen = true
            }
            .onDisappear {
                isOnScreen = false
            }
    }
}
