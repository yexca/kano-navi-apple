/// What a video is now, drawn on its cover when it is not simply published.
enum VideoCoverBadge: Equatable {
    /// On air: red, "Live".
    case live
    /// Past its start without a confirmed broadcast: red, "Started".
    case started
    /// Reserved: a premiere, or a stream and any other reservation.
    case upcoming(isPremiere: Bool)
    case cancelled
}

extension VideoCard {
    /// The cover's status badge; `nil` for a published video, which shows its
    /// length there instead.
    var coverBadge: VideoCoverBadge? {
        switch status {
        case .live: .live
        case .started: .started
        case .upcoming: .upcoming(isPremiere: kind == .videos)
        case .cancelled: .cancelled
        case nil: nil
        }
    }
}
