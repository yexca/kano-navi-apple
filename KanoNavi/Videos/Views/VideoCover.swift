import KanoNaviCore
import SwiftUI

/// A video's cover in a fixed 16:9 box, cropped to fill it, with its status
/// or length, Shorts and who can watch it drawn over the corners.
struct VideoCover: View {
    let card: VideoCard

    /// The cover's corner radius.
    static let cornerRadius: CGFloat = 12

    var body: some View {
        Rectangle()
            .fill(.fill.tertiary)
            .aspectRatio(16 / 9, contentMode: .fit)
            .overlay {
                if let url = card.thumbnailURL {
                    MediaImage(decorative: Self.source(url), contentMode: .fill)
                } else {
                    Image(systemName: "play.rectangle")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                trailingBadge
                    .padding(8)
            }
            .overlay(alignment: .bottomLeading) {
                if card.isShort {
                    VideoCoverCapsule(text: Text(.Videos.shorts), systemImage: "play.rectangle.portrait")
                        .padding(8)
                }
            }
            .overlay(alignment: .topLeading) {
                if let availability = card.availability {
                    VideoCoverCapsule(
                        text: Text(DisplayCodeLabels.availability(availability.code)),
                        systemImage: Self.symbol(for: availability))
                    .padding(8)
                }
            }
            // Labels stay a size that leaves the picture in view.
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            .clipShape(.rect(cornerRadius: Self.cornerRadius))
            // Keep the height the width gives, so a tall title beside it at
            // accessibility sizes never squeezes the cover narrower.
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityHidden(true)
    }

    /// The cover's file. The API gives no size, so the box is the 16:9 of a
    /// video and the largest copy the media route makes stands for the
    /// original's width: the loader then asks for the copy that covers the
    /// width drawn, and the route answers the original when it has no copy
    /// that large.
    static func source(_ url: URL) -> MediaImageSource {
        MediaImageSource(url: url, pixelSize: CGSize(width: 1920, height: 1080))
    }

    @ViewBuilder private var trailingBadge: some View {
        switch card.coverBadge {
        case .live:
            VideoCoverCapsule(
                text: Text(DisplayCodeLabels.videoPhase(.live)), background: .red, isUppercased: true)
        case .started:
            VideoCoverCapsule(
                text: Text(DisplayCodeLabels.videoPhase(.started)), systemImage: "play.circle", background: .red)
        case .upcoming(let isPremiere):
            VideoCoverCapsule(
                text: Text(isPremiere ? DisplayCodeLabels.form(.premiere) : DisplayCodeLabels.videoPhase(.upcoming)),
                systemImage: "clock")
        case .cancelled:
            VideoCoverCapsule(text: Text(DisplayCodeLabels.videoPhase(.cancelled)), systemImage: "xmark.circle")
        case nil:
            if let lengthText = card.lengthText {
                VideoCoverCapsule(text: Text(verbatim: lengthText))
            }
        }
    }

    private static func symbol(for availability: VideoAvailabilityMark) -> String {
        switch availability {
        case .members: "person.crop.circle.badge.checkmark"
        case .private: "lock.fill"
        case .removed: "nosign"
        }
    }
}
