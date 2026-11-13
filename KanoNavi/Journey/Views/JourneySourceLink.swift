import SwiftUI

/// "Source · <site>" opening a provenance page outside the app.
struct JourneySourceLink: View {
    let url: URL

    var body: some View {
        Link(destination: url) {
            Label {
                Text(.Journey.sourceLink(JourneyLabels.host(of: url) ?? url.absoluteString))
            } icon: {
                Image(systemName: "arrow.up.right.square")
            }
        }
    }
}
