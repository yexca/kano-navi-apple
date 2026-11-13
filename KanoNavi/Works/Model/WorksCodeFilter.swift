/// A filter over one code of a Works list, such as a release's format or an
/// upload's kind: the codes the app names, in the order their choices are
/// shown, with every other code gathered under one "other" choice.
nonisolated struct WorksCodeFilter: Equatable, Sendable {
    /// The choice that gathers the codes the app does not name.
    static let otherCode = "other"

    /// The named codes, in the order of their choices.
    let known: [String]

    /// The choice a code falls under.
    func bucket(of code: String) -> String {
        known.contains(code) ? code : Self.otherCode
    }

    /// Whether an item with `code` is shown under `selection`; `nil` selects
    /// everything.
    func matches(_ code: String, selection: String?) -> Bool {
        guard let selection else { return true }
        return bucket(of: code) == selection
    }

    /// The choices that have items, in order, with how many items each has.
    /// The "other" choice comes last.
    func counts(of codes: [String]) -> [WorksCodeCount] {
        var totals: [String: Int] = [:]
        for code in codes {
            totals[bucket(of: code), default: 0] += 1
        }
        return (known + [Self.otherCode]).compactMap { code in
            totals[code].map { WorksCodeCount(code: code, count: $0) }
        }
    }
}
