import Foundation
import KanoNaviCore
import Observation

/// Reads the calendar range behind the Now tab's Coming Up section: today
/// and the 13 Japan days after it.
///
/// The range cached on this device is on screen from the start, when it was
/// read at once, or from the first load, while the service is read. A
/// failed load keeps the last good range on screen and records the failure
/// beside it. A load that returns what is on screen publishes nothing.
@Observable
final class NowComingUpModel {
    /// Reads the range starting on a Japan date, usually
    /// `CalendarReader.readResult(from:to:)`, which falls back to the cache.
    typealias Loader = @Sendable (JapanDate) async throws -> CalendarReadResult
    /// Reads the cached range starting on a Japan date without the service.
    typealias CacheReader = @Sendable (JapanDate) async -> CalendarReadResult?

    /// The last good range.
    private(set) var result: CalendarReadResult?
    /// The last failure, cleared by a successful load.
    private(set) var failure: (any Error)?
    private(set) var isLoading = false
    /// Whether a load has finished, so a range read from the cache before
    /// then is not reported as a fallback.
    private(set) var hasLoaded = false
    @ObservationIgnored private var inFlight: Task<Void, Never>?

    private let loader: Loader
    private let cacheReader: CacheReader
    private let todayProvider: () -> JapanDate

    /// - Parameter cached: The range cached on this device, read before the
    ///   model is created, to show on the first frame.
    init(
        loader: @escaping Loader, cacheReader: @escaping CacheReader = { _ in nil },
        cached: CalendarReadResult? = nil, today: @escaping () -> JapanDate = { .today }
    ) {
        self.loader = loader
        self.cacheReader = cacheReader
        self.todayProvider = today
        result = cached
    }

    /// Builds the loaders from the app's calendar reader and reads the
    /// cached range at once.
    convenience init(calendar: CalendarReader, today: JapanDate = .today) {
        let lastDay = NowComingUp.dayCount - 1
        self.init(
            loader: { today in try await calendar.readResult(from: today, to: today.addingDays(lastDay)) },
            cacheReader: { today in await calendar.cachedResult(from: today, to: today.addingDays(lastDay)) },
            cached: calendar.cachedResultImmediately(from: today, to: today.addingDays(lastDay)))
    }

    /// The range's events, or `nil` before anything is read.
    var events: [ScheduleEvent]? { result?.page.events }

    /// Why the entries on screen are not a fresh read, or `nil` when they are
    /// (or while the first load runs).
    var notice: NowComingUpNotice? {
        if failure != nil {
            return result == nil ? .loadFailed : .updateFailed
        }
        guard hasLoaded, let result, result.isFromCache else { return nil }
        return .saved(fetchedAt: result.fetchedAt)
    }

    /// Reads the range from today. A reload that starts while another runs
    /// waits for it instead of sending its own request.
    func reload() async {
        if let inFlight {
            await inFlight.value
            return
        }
        let request = Task { await perform() }
        inFlight = request
        isLoading = true
        await request.value
        inFlight = nil
        isLoading = false
    }

    private func perform() async {
        let today = todayProvider()
        if result == nil, let cached = await cacheReader(today) {
            result = cached
        }
        do {
            let read = try await loader(today)
            if Self.changes(result, to: read) {
                result = read
            }
            if failure != nil {
                failure = nil
            }
        } catch is CancellationError {
            return
        } catch APIError.cancelled {
            return
        } catch {
            failure = error
        }
        if hasLoaded == false {
            hasLoaded = true
        }
    }

    /// Whether `read` shows anything other than `current`: other events, or
    /// another source. A fresh read's time is not shown, so two fresh reads
    /// of the same events are the same.
    static func changes(_ current: CalendarReadResult?, to read: CalendarReadResult) -> Bool {
        guard let current else { return true }
        return current.page != read.page || current.isFromCache != read.isFromCache
            || (read.isFromCache && current.fetchedAt != read.fetchedAt)
    }
}
