import Foundation

/// How the Schedule tab shows its months, chosen from the toolbar and kept
/// under ``AppSettings/scheduleModeKey``.
nonisolated enum ScheduleMode: String, CaseIterable, Identifiable {
    /// One month that pages sideways, with the selected day's entries below.
    case list
    /// Months scrolling vertically, a colored dot per entry.
    case compact
    /// Months scrolling vertically in taller cells, a colored bar per entry.
    case stacked
    /// Months scrolling vertically in taller cells, each entry's title.
    case details

    /// The mode before one is chosen.
    static let defaultMode = ScheduleMode.list

    /// The modes that scroll months vertically, in Calendar's menu order.
    static let gridModes: [ScheduleMode] = [.compact, .stacked, .details]

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .list: .Schedule.modeList
        case .compact: .Schedule.modeCompact
        case .stacked: .Schedule.modeStacked
        case .details: .Schedule.modeDetails
        }
    }

    var systemImage: String {
        switch self {
        case .list: "list.bullet.below.rectangle"
        case .compact: "circle.grid.3x3"
        case .stacked: "rectangle.grid.1x3"
        case .details: "text.alignleft"
        }
    }

    /// How many of a day's entries a grid cell draws before "+n".
    var markCapacity: Int {
        switch self {
        case .list: 1
        case .compact, .stacked: 4
        case .details: 3
        }
    }

    /// The entries a grid cell draws and the count it folds into "+n". A day
    /// over capacity gives one place to "+n", so the cell never grows.
    func marks(forEntryCount count: Int) -> (shown: Int, more: Int) {
        Self.marks(forEntryCount: count, capacity: markCapacity)
    }

    /// The entries drawn and folded into "+n" when a cell has room for
    /// `capacity` marks.
    static func marks(forEntryCount count: Int, capacity: Int) -> (shown: Int, more: Int) {
        guard count > capacity else { return (count, 0) }
        let shown = max(capacity - 1, 0)
        return (shown, count - shown)
    }
}
