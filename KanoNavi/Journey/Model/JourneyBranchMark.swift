import KanoNaviCore

/// What an identity chip draws before the name: the branch's portrait, or a
/// symbol when there is none (the All chip, or a branch whose portrait the
/// API gives as `null`). Either way the chip also shows the name and the
/// tone, so a missing portrait never leaves the identity unreadable.
nonisolated enum JourneyBranchMark: Equatable {
    case portrait(JourneyMedia)
    case symbol(String)

    /// The All chip's symbol.
    static let allSymbol = "square.grid.2x2.fill"
    /// The symbol of a branch without a portrait.
    static let missingPortraitSymbol = "person.fill"

    /// The mark of `branch`, or of the All chip for `nil`.
    init(branch: JourneyBranch?) {
        guard let branch else {
            self = .symbol(Self.allSymbol)
            return
        }
        if let portrait = branch.portrait {
            self = .portrait(portrait)
        } else {
            self = .symbol(Self.missingPortraitSymbol)
        }
    }
}
