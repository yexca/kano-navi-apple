import KanoNaviCore

/// The works that came out on today's Japan month and day in a past year,
/// for the Works entry: personal releases, participation works and uploads.
///
/// A work dated February 29 shows on February 28 in a year without that
/// day, so it comes up every year, on the day Japan counts a leap-day
/// birthday as passed. In a leap year it shows on February 29 alone.
nonisolated struct WorksOnThisDay: Equatable, Sendable {
    /// What one entry is, and where it leads.
    enum Work: Equatable, Sendable {
        case release(WorksRelease)
        case participation(WorksParticipation)
        case upload(WorksUploadCard)
    }

    struct Entry: Equatable, Identifiable, Sendable {
        let work: Work
        let date: JapanDate
        /// Whole years between `date` and today, at least one.
        let yearsAgo: Int

        var id: String {
            switch work {
            case .release(let release): "release." + release.id
            case .participation(let work): "participation." + work.id
            case .upload(let card): "upload." + card.id
            }
        }
    }

    /// Newest first; on one date, releases, then participation works, then
    /// uploads.
    let entries: [Entry]

    init(
        releases: [WorksRelease], participation: [WorksParticipation], uploads: [WorksUploadCard],
        today: JapanDate
    ) {
        let works: [(Work, JapanDate)] =
            releases.map { (.release($0), $0.date) }
            + participation.map { (.participation($0), $0.date) }
            + uploads.compactMap { card in card.date.map { (.upload(card), $0) } }
        entries = works.enumerated()
            .filter { Self.falls(on: today, date: $0.element.1) }
            .sorted { lhs, rhs in
                let (left, right) = (lhs.element.1, rhs.element.1)
                return left == right ? lhs.offset < rhs.offset : left > right
            }
            .map { Entry(work: $0.element.0, date: $0.element.1, yearsAgo: today.year - $0.element.1.year) }
    }

    /// Whether a work dated `date` comes up on `today`: the same month and
    /// day in an earlier year, or February 29 on February 28 of a year
    /// without it.
    static func falls(on today: JapanDate, date: JapanDate) -> Bool {
        guard date.year < today.year else { return false }
        if date.month == today.month, date.day == today.day { return true }
        return date.month == 2 && date.day == 29 && today.month == 2 && today.day == 28
            && isLeapYear(today.year) == false
    }

    /// Whether the Gregorian year has February 29.
    static func isLeapYear(_ year: Int) -> Bool {
        year.isMultiple(of: 4) && (year.isMultiple(of: 100) == false || year.isMultiple(of: 400))
    }
}
