import KanoNaviCore
import SwiftUI

/// The Works screen the More tab opens: Kano's releases, the works she took
/// part in and her uploads. See `docs/design.md`.
///
/// It is pushed inside the More tab's `NavigationStack` and registers the
/// screens it opens itself.
struct WorksView: View {
    @Environment(\.services) private var services

    var body: some View {
        ZStack {
            if let services {
                WorksHomeScreen(client: services.client)
            }
        }
        .navigationTitle(.Works.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
