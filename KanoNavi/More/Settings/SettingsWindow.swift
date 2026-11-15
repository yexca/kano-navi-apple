import SwiftUI

/// The Mac's Settings window: the language settings and the notification
/// settings as panes, on the pane the router names. The window takes each
/// pane's height.
struct SettingsWindow: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.settingsPane) {
            Tab(value: SettingsPane.general) {
                SettingsView(isSettingsWindowPane: true)
                    .frame(height: 170)
            } label: {
                Label {
                    Text(.More.settingsGeneral)
                } icon: {
                    Image(systemName: "gearshape")
                }
            }

            Tab(value: SettingsPane.notifications) {
                NotificationSettingsView()
                    .frame(height: 520)
            } label: {
                Label {
                    Text(.Notifications.screenTitle)
                } icon: {
                    Image(systemName: "bell.badge")
                }
            }
        }
        .frame(width: 560)
    }
}
