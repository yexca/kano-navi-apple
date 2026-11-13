/// How many items of a Works list fall under one choice of a `WorksCodeFilter`.
nonisolated struct WorksCodeCount: Equatable, Sendable {
    /// The code, or `WorksCodeFilter.otherCode`.
    let code: String
    let count: Int
}
