import SwiftUI

/// Shown when the next two weeks have no current entries.
struct NothingScheduledView: View {
    var body: some View {
        StateMessage(systemImage: "calendar", message: .widgetNothingScheduled)
    }
}
