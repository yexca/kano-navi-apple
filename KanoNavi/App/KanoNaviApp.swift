import SwiftUI

@main
struct KanoNaviApp: App {
    /// Read at launch so a build with a missing or invalid API base URL fails
    /// immediately instead of on its first request.
    private let configuration = AppConfiguration.main

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
