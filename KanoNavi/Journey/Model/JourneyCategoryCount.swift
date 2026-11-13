import KanoNaviCore

/// A gallery category choice with the number of images it holds.
nonisolated struct JourneyCategoryCount: Identifiable, Equatable {
    let category: JourneyMediaCategory
    let count: Int

    var id: String { category.rawValue }

    /// The order the gallery offers the known categories in.
    static let knownOrder: [JourneyMediaCategory] = [.artwork, .model, .goods, .frame, .cover]
}
