import SwiftUI

extension View {
    /// Opens the Mac's Settings window when the router asks for it. Does
    /// nothing elsewhere.
    func opensSettingsWindowOnRequest() -> some View {
        modifier(SettingsWindowOpener())
    }
}

private struct SettingsWindowOpener: ViewModifier {
    #if os(macOS)
        @Environment(AppRouter.self) private var router
        @Environment(\.openSettings) private var openSettings
    #endif

    func body(content: Content) -> some View {
        #if os(macOS)
            content
                .onChange(of: router.settingsWindowRequested, initial: true) { _, requested in
                    guard requested else { return }
                    router.settingsWindowRequested = false
                    openSettings()
                }
        #else
            content
        #endif
    }
}
