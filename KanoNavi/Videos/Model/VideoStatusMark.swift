import KanoNaviCore

/// What a video is now, when it is not simply published: on air, reserved,
/// past its start without a confirmed broadcast, or cancelled.
enum VideoStatusMark: Equatable {
    case live
    case upcoming
    case started
    case cancelled

    /// The mark for a video's `view.phase`; a past or unknown phase has none.
    /// A video without a `view` is marked cancelled only when its record says
    /// so.
    init?(video: Video) {
        switch video.view?.phase {
        case .live: self = .live
        case .upcoming: self = .upcoming
        case .started: self = .started
        case .cancelled: self = .cancelled
        case nil where video.isCancelled == true: self = .cancelled
        case .past, .unknown, nil: return nil
        }
    }
}
