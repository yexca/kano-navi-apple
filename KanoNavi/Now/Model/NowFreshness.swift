import Foundation
import KanoNaviComponents
import KanoNaviCore

/// How current the snapshot's data is: the last collection run and the last
/// successful read of each source, from the dashboard's `meta`.
struct NowFreshness: Equatable {
    enum State: Equatable {
        case current
        /// Older than ``NowFreshness/staleAfter``.
        case outOfDate
        /// Unknown, or too far ahead of this device's clock to trust.
        case waiting
    }

    enum SourceName: String, CaseIterable {
        case x
        case youtube
        case bilibili
        case shop
    }

    struct Source: Equatable, Identifiable {
        var name: SourceName
        var readAt: Date?
        var state: State

        var id: SourceName { name }
    }

    /// A source or run older than this is out of date.
    static let staleAfter: TimeInterval = 24 * 60 * 60
    /// A time this far ahead of the device's clock still counts as read.
    static let futureTolerance: TimeInterval = 5 * 60

    /// The last run's status code, such as `success` or `partial`.
    var syncStatus: String?
    /// When the last run finished, or started when it has no finish time.
    var syncAt: Date?
    var syncState: State
    var sources: [Source]

    init(meta: DashboardMeta, now: Date) {
        syncStatus = meta.lastSync?.status
        syncAt = meta.lastSync?.finishedAt ?? meta.lastSync?.startedAt
        syncState = Self.state(of: syncAt, now: now)
        let times = meta.sourceFetchedAt ?? [:]
        sources = SourceName.allCases.map { name in
            let readAt = times[name.rawValue] ?? nil
            return Source(name: name, readAt: readAt, state: Self.state(of: readAt, now: now))
        }
    }

    /// Whether the last run needs a look: it is neither `success`, `ok` nor
    /// `partial`.
    var syncNeedsReview: Bool {
        guard let syncStatus else { return false }
        return ["success", "ok", "partial"].contains(syncStatus) == false
    }

    /// What the one-line footer reports.
    enum Summary: Equatable {
        /// Nothing to report.
        case healthy
        /// A run is collecting now.
        case running
        /// The last run finished, but some sources reported warnings.
        case warnings
        /// The last run, or a source, was not read for a day.
        case notReadForADay
        /// The last run failed.
        case failed
    }

    /// The footer's summary. A failed run comes first, then anything not
    /// read for a day, then a partial run's warnings and a running run.
    var summary: Summary {
        if syncNeedsReview, syncStatus != "running", syncStatus != "none" {
            return .failed
        }
        if syncState == .outOfDate || sources.contains(where: { $0.state == .outOfDate }) {
            return .notReadForADay
        }
        switch syncStatus {
        case "partial": return .warnings
        case "running": return .running
        default: return .healthy
        }
    }

    /// Whether the footer is drawn as a warning: the last run failed, or the
    /// run or a source was not read for a day.
    var needsAttention: Bool {
        summary == .failed || summary == .notReadForADay
    }

    /// When the last run collected data, such as "Updated 17:01 JST"; a run
    /// before today in Japan also names its day. `nil` while the run's time
    /// is waiting.
    func updatedLine(now: Date, locale: Locale) -> String? {
        guard let syncAt, syncState != .waiting else { return nil }
        let time =
            JapanDate.date(from: syncAt) == JapanDate.today(at: now)
            ? JSTTimeFormat.time(syncAt, locale: locale)
            : JSTTimeFormat.dateTime(syncAt, locale: locale)
        var resource = LocalizedStringResource.Now.freshnessUpdated(time)
        resource.locale = locale
        return String(localized: resource)
    }

    static func state(of date: Date?, now: Date) -> State {
        guard let date, date.timeIntervalSince(now) <= futureTolerance else { return .waiting }
        return now.timeIntervalSince(date) > staleAfter ? .outOfDate : .current
    }
}
