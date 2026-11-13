import KanoNaviCore

/// One row of a track list: a disc's heading or a track.
nonisolated struct WorksTrackEntry<Track>: Identifiable {
    enum Content {
        /// The heading of a disc, with what the disc is when the record says.
        case disc(number: Int, label: LocalizedText?)
        case track(Track)
    }

    /// The row's position in the list.
    let id: Int
    let content: Content
}

extension WorksTrackEntry.Content: Equatable where Track: Equatable {}
extension WorksTrackEntry: Equatable where Track: Equatable {}
extension WorksTrackEntry.Content: Sendable where Track: Sendable {}
extension WorksTrackEntry: Sendable where Track: Sendable {}

nonisolated extension WorksTrackList {
    /// The rows of a track list by disc. Discs get a heading when there is
    /// more than one, or when the only disc says what it is.
    static func entries<Track>(of discs: [WorksDiscGroup<Track>]) -> [WorksTrackEntry<Track>] {
        let showsDiscs = discs.count > 1 || discs.contains { $0.label != nil }
        var contents: [WorksTrackEntry<Track>.Content] = []
        for disc in discs {
            if showsDiscs {
                contents.append(.disc(number: disc.disc, label: disc.label))
            }
            contents += disc.tracks.map { .track($0) }
        }
        return contents.enumerated().map { WorksTrackEntry(id: $0.offset, content: $0.element) }
    }
}
