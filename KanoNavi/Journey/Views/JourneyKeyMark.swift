import SwiftUI

/// "Key milestone" with a star, on a highlighted milestone.
struct JourneyKeyMark: View {
    let tone: JourneyTone

    var body: some View {
        Label {
            Text(.Journey.keyMilestone)
        } icon: {
            Image(systemName: "star.fill")
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(tone.color)
    }
}
