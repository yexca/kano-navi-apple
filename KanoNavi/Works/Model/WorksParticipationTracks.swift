import KanoNaviCore

/// A participation work's tracks as its screen lists them: the ones Kano
/// took part in first, then the whole list when it holds more than those.
nonisolated struct WorksParticipationTracks: Equatable, Sendable {
    /// The tracks Kano took part in, in the record's order.
    let kano: [WorksParticipationTrack]
    /// Every track by disc.
    let discs: [WorksDiscGroup<WorksParticipationTrack>]
    let total: Int

    init(_ work: WorksParticipation) {
        kano = work.tracks.filter(\.kano)
        discs = WorksTrackList.discs(of: work.tracks)
        total = work.tracks.count
    }

    /// Whether the record has more than one disc, so a track names its disc.
    var isMultiDisc: Bool { discs.count > 1 }

    /// Whether Kano's tracks get a section of their own above the full
    /// list: only when the work also has tracks without her. Otherwise the
    /// one list says it all.
    var separatesKanoTracks: Bool {
        kano.isEmpty == false && kano.count < total
    }
}
