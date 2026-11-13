import KanoNaviCore
import SwiftUI

/// An image's provenance links: the page it comes from, the file or the
/// video moment on the source site, and the original stream of a frame.
/// The same address is offered once. A cover known only by a site's name
/// says that name.
struct JourneyMediaLinks: View {
    let media: JourneyMedia

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let page = media.sourcePage {
                JourneySourceLink(url: page)
            } else if let name = media.cover?.sourceLabel, name.isEmpty == false {
                Text(.Journey.sourceNamed(name))
                    .foregroundStyle(.secondary)
            }
            if let file = media.sourceURL, file != media.sourcePage, file != media.originalStream {
                Link(destination: file) {
                    Label {
                        Text(fileLabel)
                    } icon: {
                        Image(systemName: media.frameTime == nil ? "photo" : "play.rectangle")
                    }
                }
            }
            if let stream = media.originalStream, stream != media.sourcePage {
                Link(destination: stream) {
                    Label {
                        Text(.Journey.originalStream)
                    } icon: {
                        Image(systemName: "play.rectangle")
                    }
                }
            }
        }
    }

    private var fileLabel: LocalizedStringResource {
        media.frameTime == nil ? .Journey.sourceFile : .Journey.videoAtFrame
    }
}
