import SwiftUI

/// The open end of the timeline after the newest milestone.
struct JourneyStoryContinues: View {
    var body: some View {
        Label {
            Text(.Journey.storyContinues)
        } icon: {
            Image(systemName: "ellipsis")
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }
}
