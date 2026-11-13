import KanoNaviCore

/// One edition of a personal release as its section shows it: what sets the
/// edition apart from the release and from the other editions.
nonisolated struct WorksEditionSummary: Equatable, Identifiable, Sendable {
    /// The edition's position among the release's editions, from zero.
    let index: Int
    let edition: WorksEdition
    /// The edition's full track list, or `nil` when it is the list every
    /// edition shares, which the release already shows.
    let tracks: [WorksTrack]?
    /// The edition's disc photos, or none when they are the release's.
    let discs: [WorksDiscImage]

    var id: Int { index }

    init(index: Int, edition: WorksEdition, release: WorksRelease) {
        self.index = index
        self.edition = edition
        tracks = edition.tracks.isEmpty || edition.tracks == release.tracks ? nil : edition.tracks
        discs = edition.discs == release.discs ? [] : edition.discs
    }

    /// The editions of a release in the collection's order.
    static func summaries(of release: WorksRelease) -> [WorksEditionSummary] {
        release.editions.enumerated().map { index, edition in
            WorksEditionSummary(index: index, edition: edition, release: release)
        }
    }

    /// The edition's own facts in the order shown, leaving out what the
    /// record does not state.
    var facts: [WorksFact] {
        [
            WorksFact.localized(.catalog, edition.catalog),
            WorksFact.localized(.price, edition.price),
            WorksFact.localized(.format, edition.format),
            WorksFact.localized(.packaging, edition.packaging),
            edition.date.map { WorksFact(kind: .released, value: .date($0)) },
            WorksFact.plain(.jan, edition.jan),
        ].compactMap(\.self)
    }
}
