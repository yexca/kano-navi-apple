import KanoNaviCore

/// One mark on a personal release: its format, or a fact that sets it apart.
nonisolated enum WorksReleaseMark: Hashable, Sendable {
    case format(WorksReleaseFormat)
    /// Released for download or streaming.
    case digital
    /// A unit work, with the unit's name as written.
    case unit(String)
    /// Every edition was withdrawn.
    case cancelled

    /// A release's marks in the order shown: cancelled first, since it
    /// changes how the rest reads, then format, digital and unit.
    static func marks(for release: WorksRelease) -> [WorksReleaseMark] {
        var marks: [WorksReleaseMark] = []
        if release.cancelled { marks.append(.cancelled) }
        marks.append(.format(release.format))
        if release.digital { marks.append(.digital) }
        if let unit = release.unit, unit.isEmpty == false { marks.append(.unit(unit)) }
        return marks
    }
}
