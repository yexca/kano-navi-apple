import SwiftUI

/// Opens one Works release from a Journey milestone, by its `releaseId`.
///
/// The Journey does not link into the Works screen itself. Whoever presents
/// it can set the action, and a milestone with a release then offers
/// "View in Works":
///
///     JourneyView()
///         .environment(\.journeyOpenRelease, JourneyOpenRelease { releaseID in … })
struct JourneyOpenRelease {
    let action: (String) -> Void

    func callAsFunction(_ releaseID: String) {
        action(releaseID)
    }
}

extension EnvironmentValues {
    /// Opens a Works release from the Journey; `nil` (the default) hides the
    /// button.
    @Entry var journeyOpenRelease: JourneyOpenRelease? = nil
}
