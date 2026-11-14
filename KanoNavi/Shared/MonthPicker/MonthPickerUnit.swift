import Foundation

/// What a month picker's counts count, so VoiceOver reads "12 posts".
enum MonthPickerUnit {
    case posts
    case videos

    /// A month's count in words.
    func count(_ count: Int) -> LocalizedStringResource {
        switch self {
        case .posts: .Archive.monthPostCount(count)
        case .videos: .Archive.monthVideoCount(count)
        }
    }
}
