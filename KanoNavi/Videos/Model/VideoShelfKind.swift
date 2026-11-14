import Foundation
import KanoNaviCore

/// The kinds the video shelf's filter offers, in its order.
enum VideoShelfKind: String, CaseIterable, Identifiable {
    /// Broadcasts: stream reservations, live streams and stream archives.
    case streams
    /// Uploads and premieres, and premiere reservations.
    case videos
    case shorts

    var id: String { rawValue }

    /// The kind a video's form gives. A reservation's form is `upcoming`, so
    /// its stored kind or tag context says whether it is a stream.
    init(video: Video) {
        if video.view?.formCode == .short || video.isShort == true {
            self = .shorts
            return
        }
        switch video.view?.formCode {
        case .stream, .archive:
            self = .streams
        case .premiere, .video:
            self = .videos
        case .short, .upcoming, .unknown, nil:
            self = video.kind == "stream" || video.view?.tagContext == "stream" ? .streams : .videos
        }
    }

    var label: LocalizedStringResource {
        switch self {
        case .streams: .Videos.kindStreams
        case .videos: .Videos.kindVideos
        case .shorts: .Videos.shorts
        }
    }
}
