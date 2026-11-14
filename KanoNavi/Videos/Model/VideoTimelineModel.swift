import Foundation
import KanoNaviCore
import Observation

/// The video timeline's state: every dated video newest first, from the
/// newest or from the last day of a chosen month, paged as the list scrolls
/// and narrowed on the device by kind and platform.
///
/// A failed read keeps what was loaded before and records the failure beside
/// it, so a screen shows both. A read the service could not answer may come
/// from the cache on this device; the listing says so and when it was read.
@Observable
final class VideoTimelineModel {
    /// Reads the month index, usually `/api/videos/months` with the cache
    /// fallback.
    typealias MonthsLoader = @Sendable () async throws -> ArchiveMonthIndex
    /// Reads one page of the timeline.
    typealias PageLoader = @Sendable (VideoTimelineQuery) async throws -> ArchivePage<Video>

    /// The videos a filter should show before `fill()` stops reading further
    /// pages; the list reads more as it scrolls.
    static let minimumShown = 10

    /// The month index for the month menu, or `nil` before it has loaded.
    private(set) var index: ArchiveMonthIndex?
    /// The month the timeline on screen starts at, or `nil` for the newest
    /// video. Its first page loads with `loadIfNeeded()`.
    var start: ArchiveMonthKey?
    var filter = VideoTimelineFilter()
    /// The pages loaded per start.
    private(set) var listings: [ArchiveMonthKey?: ArchiveListing<Video>] = [:]
    /// Each listing's videos as cards, built once per page read.
    private var loadedCards: [ArchiveMonthKey?: [VideoCard]] = [:]
    /// The last failure reading a first page, per start.
    private(set) var failures: [ArchiveMonthKey?: any Error] = [:]
    /// The last failure reading a later page, per start.
    private(set) var moreFailures: [ArchiveMonthKey?: any Error] = [:]
    private(set) var loadingStarts: Set<ArchiveMonthKey?> = []
    private(set) var loadingMoreStarts: Set<ArchiveMonthKey?> = []

    @ObservationIgnored private var inFlight: [ArchiveMonthKey?: Task<Void, Never>] = [:]
    @ObservationIgnored private var indexInFlight: Task<Void, Never>?
    @ObservationIgnored private var generation = 0

    private let loadMonths: MonthsLoader
    private let loadPage: PageLoader

    init(months: @escaping MonthsLoader, page: @escaping PageLoader) {
        loadMonths = months
        loadPage = page
    }

    /// The pages loaded for the timeline on screen.
    var listing: ArchiveListing<Video>? { listings[start] }

    /// Every video loaded for the timeline on screen, whatever the filter.
    var loadedCount: Int { listing?.items.count ?? 0 }

    /// The loaded videos the filter shows, in the timeline's order.
    var cards: [VideoCard] {
        (loadedCards[start] ?? []).compactMap(filter.apply)
    }

    /// The shown videos by Japan month.
    var sections: [VideoTimelineSection] {
        VideoTimelineSection.grouping(cards)
    }

    /// Whether the first page of the timeline on screen is loading.
    var isLoading: Bool { loadingStarts.contains(start) }

    /// Whether a later page of the timeline on screen is loading.
    var isLoadingMore: Bool { loadingMoreStarts.contains(start) }

    /// Whether another page of the timeline on screen can be loaded.
    var canLoadMore: Bool { listing?.hasNext == true }

    /// The last failure reading a later page of the timeline on screen.
    var moreFailure: (any Error)? { moreFailures[start] }

    /// Why the timeline on screen is not a fresh read, or `nil` when it is.
    var notice: ArchiveNotice? {
        if failures[start] != nil {
            return listing == nil ? .loadFailed : .updateFailed
        }
        guard let listing, listing.isFromCache else { return nil }
        return .saved(fetchedAt: listing.fetchedAt)
    }

    /// Loads the month index and the first page on screen unless they are
    /// loaded, then reads on until the filter shows enough videos.
    func loadIfNeeded() async {
        let start = start
        async let months: Void = readIndex(onlyIfMissing: true)
        if listings[start] == nil {
            await readFirstPage(start)
        }
        await months
        await fill()
    }

    /// Reads the month index and the first page on screen again, for pull to
    /// refresh and retry. Later pages are read again as the list scrolls.
    func refresh() async {
        let start = start
        async let months: Void = readIndex()
        await readFirstPage(start)
        await months
    }

    /// Reads further pages while the filter shows fewer than
    /// `minimumShown` videos, until the timeline ends, a read fails or the
    /// task is cancelled.
    func fill() async {
        while Task.isCancelled == false, cards.count < Self.minimumShown, canLoadMore, moreFailure == nil {
            let page = listing?.page
            await loadMore()
            // Another read is running, or this one was cancelled: leave the
            // rest to it and to the list.
            guard listing?.page != page else { return }
        }
    }

    /// Reads the next page of the timeline on screen and appends it.
    func loadMore() async {
        let start = start
        guard let listing = listings[start], listing.hasNext,
            loadingMoreStarts.contains(start) == false, loadingStarts.contains(start) == false
        else { return }
        loadingMoreStarts.insert(start)
        defer { loadingMoreStarts.remove(start) }
        do {
            let page = try await loadPage(VideoTimelineQuery(start: start, page: listing.page + 1))
            guard var current = listings[start], current.generation == listing.generation else { return }
            current.append(page, id: \.id)
            store(current, for: start)
            moreFailures[start] = nil
        } catch is CancellationError {
            return
        } catch APIError.cancelled {
            return
        } catch {
            moreFailures[start] = error
        }
    }

    private func store(_ listing: ArchiveListing<Video>, for start: ArchiveMonthKey?) {
        listings[start] = listing
        loadedCards[start] = listing.items.map(VideoCard.init(video:))
    }

    private func readIndex(onlyIfMissing: Bool = false) async {
        if onlyIfMissing, index != nil { return }
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
            index = try await loadMonths()
        } catch {
            // The menu waits for an index; the timeline does not need one.
        }
    }

    /// Reads a first page. A read that starts while another of the same
    /// start runs waits for that one instead of sending its own.
    private func readFirstPage(_ start: ArchiveMonthKey?) async {
        if let running = inFlight[start] {
            await running.value
            return
        }
        let request = Task { await performFirstPageRead(start) }
        inFlight[start] = request
        loadingStarts.insert(start)
        await request.value
        inFlight[start] = nil
        loadingStarts.remove(start)
    }

    private func performFirstPageRead(_ start: ArchiveMonthKey?) async {
        do {
            let page = try await loadPage(VideoTimelineQuery(start: start, page: 1))
            generation += 1
            store(ArchiveListing(firstPage: page, generation: generation), for: start)
            failures[start] = nil
            moreFailures[start] = nil
        } catch is CancellationError {
            return
        } catch APIError.cancelled {
            return
        } catch {
            failures[start] = error
        }
    }
}
