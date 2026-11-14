import Foundation
import KanoNaviCore

extension NotificationRoute {
    /// The route a local notification carries in its `userInfo`, or `nil`
    /// when it carries none the app knows.
    nonisolated init?(userInfo: [AnyHashable: Any]) {
        guard let rawURL = userInfo[NotificationUserInfoKey.routeURL] as? String,
            let url = URL(string: rawURL)
        else {
            return nil
        }
        self.init(url: url)
    }
}
