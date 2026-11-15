import SwiftUI

/// The Journey screen the More tab opens: Kano's milestones as a timeline
/// and every image as a gallery, from `GET /api/journey`. See
/// `docs/architecture/archives.md`.
///
/// It is pushed inside More's `NavigationStack` and registers its own
/// destinations.
struct JourneyView: View {
    @Environment(\.services) private var services

    var body: some View {
        if let services {
            JourneyScreen(client: services.client)
        } else {
            ContentUnavailableView {
                Label {
                    Text(.rootPlaceholderTitle)
                } icon: {
                    Image(systemName: "hammer")
                }
            } description: {
                Text(.rootPlaceholderMessage)
            }
            .navigationTitle(.More.moreJourney)
            .inlineNavigationTitle()
        }
    }
}

#Preview {
    NavigationStack {
        JourneyView()
    }
}
