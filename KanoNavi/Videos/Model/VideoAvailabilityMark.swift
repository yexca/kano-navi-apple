import KanoNaviCore

/// Who can watch a video, when not everyone can.
enum VideoAvailabilityMark: Equatable {
    case members
    case `private`
    case removed

    /// The mark for a video's availability. Public, unlisted, not yet checked
    /// and unknown availability have none: those videos are watchable.
    init?(_ availability: VideoAvailability?) {
        switch availability {
        case .members: self = .members
        case .private: self = .private
        case .removed: self = .removed
        case .public, .unlisted, .unknown, nil: return nil
        }
    }
}

extension VideoAvailabilityMark {
    /// The API's availability this mark stands for.
    var code: VideoAvailability {
        switch self {
        case .members: .members
        case .private: .private
        case .removed: .removed
        }
    }
}
