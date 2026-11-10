import Foundation
import KanoNaviCore
import Observation

/// A month archive's state: the month index, the selected month and filter,
/// and the pages loaded for each month and filter.
///
/// A failed read keeps what was loaded before and records the failure beside
/// it, so a screen shows both. A read the service could not answer may come
/// from the cache on this device; the listing says so and when it was read.
@Observable
final class ArchiveModel<Item: Sendable> {
    /// Reads the month index, usually `/api/videos/months` or
    /// `/api/posts/months` with the cache fallback.
    typealias MonthsLoader = @Sendable () async throws -> ArchiveMonthIndex
    /// Reads one page of a month under a filter.
    typealias PageLoader = @Sendable (ArchiveQuery) async throws -> ArchivePage<Item>

    /// The month index, or `nil` before it has loaded.
    private(set) var index: ArchiveMonthIndex?
    /// The last failure reading the month index, cleared by a success.
    private(set) var indexFailure: (any Error)?
    /// The month on screen; its first page loads with `loadIfNeeded()`.
    var selectedMonth: ArchiveMonthKey?
    /// The selected filter code, or `nil` for all items.
    var filter: String?
    private(set) var listings: [ArchiveKey: ArchiveListing<Item>] = [:]
    /// The last failure reading a first page, per month and filter.
    private(set) var failures: [ArchiveKey: any Error] = [:]
    /// The last failure reading a later page, per month and filter.
    private(set) var moreFailures: [ArchiveKey: any Error] = [:]
    private(set) var loadingKeys: Set<ArchiveKey> = []
    private(set) var loadingMoreKeys: Set<ArchiveKey> = []
    /// The counts per filter code each month's latest first page reported.
    private var pageCounts: [ArchiveMonthKey: [String: Int]] = [:]

    @ObservationIgnored private var inFlight: [ArchiveKey: Task<Void, Never>] = [:]
    @ObservationIgnored private var indexInFlight: Task<Void, Never>?
    @ObservationIgnored private var generation = 0

    private let loadMonths: MonthsLoader
    private let loadPage: PageLoader
    private let itemID: (Item) -> String

    init(
        months: @escaping MonthsLoader, page: @escaping PageLoader, itemID: @escaping (Item) -> String
    ) {
        loadMonths = months
        loadPage = page
        self.itemID = itemID
    }

    /// The month and filter on screen.
    var key: ArchiveKey? {
        selectedMonth.map { ArchiveKey(month: $0, filter: filter) }
    }

    /// The months of the index, newest first.
    var months: [ArchiveMonthKey] { index?.keys ?? [] }

    /// The pages loaded for the month and filter on screen.
    var listing: ArchiveListing<Item>? { key.flatMap { listings[$0] } }

    /// The items on screen, in server order.
    var items: [Item] { listing?.items ?? [] }

    /// Whether a later page of the month on screen is loading.
    var isLoadingMore: Bool { key.map { loadingMoreKeys.contains($0) } ?? false }

    /// Whether another page of the month on screen can be loaded.
    var canLoadMore: Bool { listing?.hasNext == true }

    /// The last failure reading a later page of the month on screen.
    var moreFailure: (any Error)? { key.flatMap { moreFailures[$0] } }

    /// Whether the index loaded and lists no month: nothing is stored.
    var isEmpty: Bool { index?.months.isEmpty == true }

    /// The selected month's items per filter code: from its latest first
    /// page, else from the month index.
    var counts: [String: Int] {
        guard let selectedMonth else { return [:] }
        return pageCounts[selectedMonth] ?? index?.month(selectedMonth)?.counts ?? [:]
    }

    /// Every item of the selected month, whatever the filter.
    var allCount: Int? {
        guard let selectedMonth else { return nil }
        if let counts = pageCounts[selectedMonth] {
            return counts.values.reduce(0, +)
        }
        return index?.month(selectedMonth)?.total
    }

    /// Why the month on screen is not a fresh read, or `nil` when it is.
    var notice: ArchiveNotice? {
        guard let key else {
            return index == nil && indexFailure != nil ? .loadFailed : nil
        }
        if failures[key] != nil {
            return listings[key] == nil ? .loadFailed : .updateFailed
        }
        guard let listing = listings[key], listing.isFromCache else { return nil }
        return .saved(fetchedAt: listing.fetchedAt)
    }

    /// Loads the month index unless it is loaded, selects its newest month
    /// when none is selected, and loads the first page on screen unless it is
    /// loaded.
    func loadIfNeeded() async {
        if index == nil {
            await readIndex()
        }
        guard let key, listings[key] == nil else { return }
        await readFirstPage(key)
    }

    /// Reads the month index and the first page on screen again, for pull to
    /// refresh and retry. Later pages are read again as the list scrolls.
    func refresh() async {
        await readIndex()
        guard let key else { return }
        await readFirstPage(key)
    }

    /// Reads the next page of the month on screen and appends it.
    func loadMore() async {
        guard let key, let listing = listings[key], listing.hasNext,
            loadingMoreKeys.contains(key) == false, loadingKeys.contains(key) == false
        else { return }
        loadingMoreKeys.insert(key)
        defer { loadingMoreKeys.remove(key) }
        do {
            let page = try await loadPage(key.page(listing.page + 1))
            guard var current = listings[key], current.generation == listing.generation else { return }
            current.append(page, id: itemID)
            listings[key] = current
            moreFailures[key] = nil
        } catch is CancellationError {
            return
        } catch APIError.cancelled {
            return
        } catch {
            moreFailures[key] = error
        }
    }

    private func readIndex() async {
        if let running = indexInFlight {
            await running.value
            return
        }
        let request = Task { await performIndexRead() }
        indexInFlight = request
        await request.value
        indexInFlight = nil
    }

    private func performIndexRead() async {
        do {
            let index = try await loadMonths()
            self.index = index
            indexFailure = nil
            // Keep the month on screen while the index still lists it.
            if selectedMonth.map(index.keys.contains) != true {
                selectedMonth = index.keys.first
            }
        } catch is CancellationError {
            return
        } catch APIError.cancelled {
            return
        } catch {
            indexFailure = error
        }
    }

    /// Reads a first page. A read that starts while another of the same
    /// month and filter runs waits for that one instead of sending its own.
    private func readFirstPage(_ key: ArchiveKey) async {
        if let running = inFlight[key] {
            await running.value
            return
        }
        let request = Task { await performFirstPageRead(key) }
        inFlight[key] = request
        loadingKeys.insert(key)
        await request.value
        inFlight[key] = nil
        loadingKeys.remove(key)
    }

    private func performFirstPageRead(_ key: ArchiveKey) async {
        do {
            let page = try await loadPage(key.page(1))
            generation += 1
            listings[key] = ArchiveListing(firstPage: page, generation: generation)
            pageCounts[key.month] = page.counts
            failures[key] = nil
            moreFailures[key] = nil
        } catch is CancellationError {
            return
        } catch APIError.cancelled {
            return
        } catch {
            failures[key] = error
        }
    }
}
