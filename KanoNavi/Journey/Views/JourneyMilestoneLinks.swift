import KanoNaviCore
import SwiftUI

/// A milestone's source (or that it rests on a third-party archive), its
/// further links by their worded labels, and View in Works when whoever
/// presents the Journey can open a release.
struct JourneyMilestoneLinks: View {
    let milestone: JourneyMilestone

    @Environment(\.journeyOpenRelease) private var openRelease

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(.Journey.sourceHeader)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            if let source = milestone.sourceURL {
                JourneySourceLink(url: source)
            } else {
                Label {
                    Text(.Journey.archiveOnly)
                } icon: {
                    Image(systemName: "archivebox")
                }
                .foregroundStyle(.secondary)
            }
            ForEach(milestone.links, id: \.url) { link in
                Link(destination: link.url) {
                    Label {
                        Text(JourneyLabels.link(link.label))
                    } icon: {
                        Image(systemName: "arrow.up.right.square")
                    }
                }
            }
            if let releaseID = milestone.releaseID, let openRelease {
                Button(.Journey.openRelease, systemImage: "music.note.list") {
                    openRelease(releaseID)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
