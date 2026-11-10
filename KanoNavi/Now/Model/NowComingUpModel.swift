import Foundation
import KanoNaviCore
import Observation

/// Reads the calendar range behind the Now tab's Coming Up section: today
/// and the 13 Japan days after it.
///
/// The first load shows the range cached on this device, if any, while the
/// service is read. A failed load keeps the last good range on screen and
/// records the failure beside it.
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

    init(
        loader: @escaping Loader, cacheReader: @escaping CacheReader = { _ in nil },
        today: @escaping () -> JapanDate = { .today }
    ) {
        self.loader = loader
        self.cacheReader = cacheReader
        self.todayProvider = today
    }

    /// Builds the loaders from the app's calendar reader.
    convenience init(calendar: CalendarReader) {
        let lastDay = NowComingUp.dayCount - 1
        self.init(
            loader: { today in try await calendar.readResult(from: today, to: today.addingDays(lastDay)) },
            cacheReader: { today in await calendar.cachedResult(from: today, to: today.addingDays(lastDay)) })
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
            result = try await loader(today)
            failure = nil
        } catch is CancellationError {
            return
        } catch APIError.cancelled {
            return
        } catch {
            failure = error
        }
        hasLoaded = true
    }
}
