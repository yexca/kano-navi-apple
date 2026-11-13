import KanoNaviCore

/// The tracks of one disc of a release, edition or participation work.
nonisolated struct WorksDiscGroup<Track>: Identifiable {
    let disc: Int
    /// What the disc is, such as a DVD or a bonus CD, when the record says.
    var label: LocalizedText?
    /// The disc's tracks in the order the record lists them.
    var tracks: [Track]

    var id: Int { disc }
}

extension WorksDiscGroup: Equatable where Track: Equatable {}
extension WorksDiscGroup: Sendable where Track: Sendable {}

/// Groups track lists by disc.
nonisolated enum WorksTrackList {
    /// A personal release's or edition's tracks by disc, discs in number
    /// order. A disc's label is the first one its tracks carry.
    static func discs(of tracks: [WorksTrack]) -> [WorksDiscGroup<WorksTrack>] {
        var groups = discs(of: tracks, disc: \.disc)
        for index in groups.indices {
            groups[index].label = groups[index].tracks.lazy.compactMap(\.discLabel).first {
                $0.isEmpty == false
            }
        }
        return groups
    }

    /// A participation work's tracks by disc, discs in number order.
    static func discs(of tracks: [WorksParticipationTrack]) -> [WorksDiscGroup<WorksParticipationTrack>] {
        discs(of: tracks, disc: \.disc)
    }

    private static func discs<Track>(of tracks: [Track], disc: (Track) -> Int) -> [WorksDiscGroup<Track>] {
        var groups: [WorksDiscGroup<Track>] = []
        for track in tracks {
            let number = disc(track)
            if let index = groups.firstIndex(where: { $0.disc == number }) {
                groups[index].tracks.append(track)
            } else {
                groups.append(WorksDiscGroup(disc: number, tracks: [track]))
            }
        }
        return groups.sorted { $0.disc < $1.disc }
    }
}
