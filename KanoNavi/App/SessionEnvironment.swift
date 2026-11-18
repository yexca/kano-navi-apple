import KanoNaviCore
import SwiftUI

/// Puts the session and the services for its selected server in the
/// environment, following the session when another server is selected.
struct SessionEnvironment: ViewModifier {
    let session: AppSession

    func body(content: Content) -> some View {
        content
            .environment(session)
            .environment(\.services, session.services)
            .environment(session.dashboard)
            .environment(session.notifications)
    }
}

extension View {
    /// Puts `session` and the services for its selected server in the
    /// environment.
    func sessionEnvironment(_ session: AppSession) -> some View {
        modifier(SessionEnvironment(session: session))
    }
}
