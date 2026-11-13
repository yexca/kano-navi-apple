import KanoNaviCore
import SwiftUI

/// One personal release, by release ID. Self-contained: it reads the Works
/// collection itself (from the copy cached on this device first), so any
/// screen can push it, and it says so when the collection has no release
/// of that ID.
///
///     .navigationDestination(for: ReleaseLink.self) { link in
///         WorksReleaseScreen(releaseID: link.releaseID)
///     }
struct WorksReleaseScreen: View {
    let releaseID: String

    @Environment(\.services) private var services

    var body: some View {
        ZStack {
            if let services {
                WorksReleaseLoader(client: services.client, releaseID: releaseID)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
