import SwiftUI

/// Shown when the next two weeks have no current entries.
struct NothingScheduledView: View {
    var body: some View {
        Text(.widgetNothingScheduled)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
