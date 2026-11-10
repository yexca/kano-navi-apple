import Foundation

/// The video archive's category filter. The API derives a video's category
/// from its tag; the app only names the codes.
enum VideoCategory {
    /// The category codes the archive accepts, in filter order.
    static let codes = ["game", "talk", "song", "other"]

    /// The filter's choices: all videos, then each category with the
    /// month's count. Counts are `nil` before the month loads.
    static func options(counts: [String: Int], allCount: Int?) -> [ArchiveFilterOption] {
        let known = allCount != nil
        let all = ArchiveFilterOption(code: nil, label: .localized(.Archive.all), count: allCount)
        return [all]
            + codes.map { code in
                ArchiveFilterOption(
                    code: code, label: .localized(label(for: code)),
                    count: known ? counts[code] ?? 0 : nil)
            }
    }

    static func label(for code: String) -> LocalizedStringResource {
        switch code {
        case "game": .Videos.categoryGame
        case "talk": .Videos.categoryTalk
        case "song": .Videos.categorySong
        default: .Videos.categoryOther
        }
    }
}
