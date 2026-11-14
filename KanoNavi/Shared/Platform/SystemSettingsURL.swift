import Foundation

#if os(iOS)
    import UIKit
#endif

/// The system settings pages the app links to.
enum SystemSettingsURL {
    /// The page that sets the app's own interface language: the app's
    /// settings on iOS, Language & Region on macOS.
    static var appLanguage: URL? {
        #if os(iOS)
            URL(string: UIApplication.openSettingsURLString)
        #else
            URL(string: "x-apple.systempreferences:com.apple.Localization-Settings.extension")
        #endif
    }

    /// The app's notification settings.
    static var notifications: URL? {
        #if os(iOS)
            URL(string: UIApplication.openNotificationSettingsURLString)
                ?? URL(string: UIApplication.openSettingsURLString)
        #else
            URL(
                string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension?id="
                    + (Bundle.main.bundleIdentifier ?? ""))
        #endif
    }
}
