import KanoNaviCore
import UIKit

/// Opens the screen a launch asks for before its first frame.
///
/// A widget tap, a `kanonavi://` link or a tapped notification reaches
/// SwiftUI (`onOpenURL`, the notification delegate) only after the first
/// frame, which would draw the Now tab and then cross-fade away from it. The
/// scene's connection options carry the same target earlier: this delegate
/// reads them while the scene is configured and seeds the router, which then
/// ignores the later delivery of the same target once.
final class AppDelegate: NSObject, UIApplicationDelegate {
    /// The app's router, set by `KanoNaviApp` before any scene connects.
    var router: AppRouter?

    func application(
        _ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let route = LaunchRoute.route(
            openedURLs: options.urlContexts.map(\.url),
            notificationUserInfo: options.notificationResponse?.notification.request.content.userInfo)
        if let route {
            router?.openAtLaunch(route)
        }
        return UISceneConfiguration(
            name: connectingSceneSession.configuration.name, sessionRole: connectingSceneSession.role)
    }
}
