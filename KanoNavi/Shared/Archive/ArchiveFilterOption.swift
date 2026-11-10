import Foundation

/// One choice of an archive filter with the selected month's count for it.
nonisolated struct ArchiveFilterOption: Equatable, Identifiable, Sendable {
    /// The filter code the API takes, or `nil` for all items.
    var code: String?
    var label: ArchiveFilterLabel
    /// An SF Symbol drawn before the name, such as a platform's.
    var systemImage: String?
    /// The month's items for this choice, or `nil` before the month loads.
    var count: Int?

    var id: String { code ?? "" }
}
