import Foundation
import KanoNaviCore
import Observation

/// The post timeline's state: every post newest first, from the newest or
/// from the last day of a chosen month, for every account or one, paged as
/// the list scrolls.
///
/// Pages are offsets into the list, so a post added or removed moves the
/// posts after it from one page to the next. A page is appended without the
/// posts already listed. When a page was read at another data revision than
/// the first, or the service reports a new revision, the pages loaded for the
/// timeline on screen are read again from the first and replace its listing
/// at once; until then the listing stays as it is.
///
/// A failed read keeps what was loaded before and records the failure beside
/// it, so a screen shows both. A read the service could not answer may come
/// from the cache on this device; the listing says so and when it was read.
@Observable
final class PostTimelineModel {
    /// Reads the month index, usually `/api/posts/months` with the cache
    /// fallback.
    typealias MonthsLoader = @Sendable () async throws -> ArchiveMonthIndex
    /// Reads one page of a timeline.
    typealias PageLoader = @Sendable (PostTimelineQuery) async throws -> ArchivePage<PostTimelineEntry>

    /// The posts a timeline should show before `fill()` stops reading further
    /// pages; the list reads more as it scrolls.
    static let minimumShown = 10
    /// How often the loaded pages are read in a row while the data keeps
    /// changing under the reads, before the last result is shown anyway.
    static let maximumReads = 3

    /// The month index for the month picker, or `nil` before it has loaded.
    private(set) var index: ArchiveMonthIndex?
    /// The month the timeline on screen starts at, or `nil` for the newest
    /// post. Its first page loads with `loadIfNeeded()`.
    var start: ArchiveMonthKey?
    /// The account the timeline on screen lists, or `nil` for every post.
    var account: String?
    /// The dashboard's avatars, for the accounts a page names no avatar for.
    var avatarFallback = PostAvatarFallback() {
        didSet {
            guard avatarFallback != oldValue else { return }
            for (key, listing) in listings {
                setCards(cards(of: listing.items), for: key)
            }
        }
    }
    /// The pages loaded per timeline.
    private(set) var listings: [PostTimelineKey: ArchiveListing<PostTimelineEntry>] = [:]
    /// Each listing's posts as cards, built once per read.
    private var loadedCards: [PostTimelineKey: [PostCard]] = [:]
    /// Each listing's cards by Japan month, grouped once per read rather
    /// than on every look while the list scrolls.
    private var loadedSections: [PostTimelineKey: [PostTimelineSection]] = [:]
    /// The last failure reading the first pages, per timeline.
    private(set) var failures: [PostTimelineKey: any Error] = [:]
    /// The last failure reading a later page, per timeline.
    private(set) var moreFailures: [PostTimelineKey: any Error] = [:]
    private(set) var loadingKeys: Set<PostTimelineKey> = []
    private(set) var loadingMoreKeys: Set<PostTimelineKey> = []
    /// Timelines whose listing is the copy read from the cache when the model
    /// was created, which the first `loadIfNeeded()` reads again. Their copy
    /// is not called a fallback until that read says so.
    private(set) var launchCopies: Set<PostTimelineKey> = []
    /// Timelines read before the latest data revision, read again when shown.
    private(set) var staleKeys: Set<PostTimelineKey> = []
    /// The posts per lowercase account each start's latest first page counted
    /// over the whole timeline, whatever the account.
    private var pageCounts: [ArchiveMonthKey?: [String: Int]] = [:]

    @ObservationIgnored private var inFlight: [PostTimelineKey: Task<Void, Never>] = [:]
    @ObservationIgnored private var indexInFlight: Task<Void, Never>?
    @ObservationIgnored private var generation = 0

    private let loadMonths: MonthsLoader
    private let loadPage: PageLoader

    /// - Parameter cachedFirstPage: The newest page of every account as cached
    ///   on this device, read before the model is created, to show on the
    ///   first frame.
    init(
        months: @escaping MonthsLoader, page: @escaping PageLoader,
        cachedFirstPage: ArchivePage<PostTimelineEntry>? = nil
    ) {
        loadMonths = months
        loadPage = page
        if let cachedFirstPage {
            let key = PostTimelineKey()
            generation += 1
            store(ArchiveListing(firstPage: cachedFirstPage, generation: generation), for: key)
            pageCounts[nil] = cachedFirstPage.counts
            launchCopies.insert(key)
        }
    }

    /// The timeline on screen.
    var key: PostTimelineKey { PostTimelineKey(start: start, account: account) }

    /// The pages loaded for the timeline on screen.
    var listing: ArchiveListing<PostTimelineEntry>? { listings[key] }

    /// The loaded posts of the timeline on screen, in the timeline's order.
    var cards: [PostCard] { loadedCards[key] ?? [] }

    /// The loaded posts by Japan month.
    var sections: [PostTimelineSection] { loadedSections[key] ?? [] }

    /// Whether the pages of the timeline on screen are being read.
    var isLoading: Bool { loadingKeys.contains(key) }

    /// Whether a later page of the timeline on screen is loading.
    var isLoadingMore: Bool { loadingMoreKeys.contains(key) }

    /// Whether another page of the timeline on screen can be loaded.
    var canLoadMore: Bool { listing?.hasNext == true }

    /// The last failure reading a later page of the timeline on screen.
    var moreFailure: (any Error)? { moreFailures[key] }

    /// The posts per lowercase account in the timeline from the start on
    /// screen, or empty before a page of it has loaded.
    var counts: [String: Int] { pageCounts[start] ?? [:] }

    /// Every post in the timeline from the start on screen, or `nil` before
    /// a page of it has loaded.
    var allCount: Int? {
        if let all = listings[PostTimelineKey(start: start)] {
            return all.total
        }
        return pageCounts[start].map { $0.values.reduce(0, +) }
    }

    /// Why the timeline on screen is not a fresh read, or `nil` when it is.
    var notice: ArchiveNotice? {
        if failures[key] != nil {
            return listing == nil ? .loadFailed : .updateFailed
        }
        guard let listing, listing.isFromCache, launchCopies.contains(key) == false else { return nil }
        return .saved(fetchedAt: listing.fetchedAt)
    }

    /// Loads the month index and the timeline on screen unless they are
    /// loaded and current, then reads on until it shows enough posts.
    func loadIfNeeded() async {
        let key = key
        async let months: Void = readIndex(onlyIfMissing: true)
        if listings[key] == nil || launchCopies.contains(key) || staleKeys.contains(key) {
            await read(key)
        }
        await months
        await fill()
    }

    /// Reads the month index and the loaded pages of the timeline on screen
    /// again, for pull to refresh and retry.
    func refresh() async {
        let key = key
        async let months: Void = readIndex()
        await read(key)
        await months
    }

    /// Takes in a new data revision of the service, such as the dashboard's:
    /// marks every timeline read at another revision out of date, and reads
    /// the month index and the loaded pages of the timeline on screen again.
    /// What is on screen stays until those reads return.
    ///
    /// - Parameter revision: The new revision, or `nil` when it is unknown
    ///   and every timeline is out of date.
    func reloadAfterChange(revision: Int? = nil) async {
        for (key, listing) in listings where revision == nil || listing.revision != revision {
            staleKeys.insert(key)
        }
        let key = key
        async let months: Void = readIndex()
        // A read that is running may have started before the change.
        if let running = inFlight[key] {
            await running.value
        }
        if listings[key] != nil, staleKeys.contains(key) {
            await read(key)
        }
        await months
    }

    /// Reads further pages while the timeline shows fewer than
    /// `minimumShown` posts, until it ends, a read fails or the task is
    /// cancelled.
    func fill() async {
        while Task.isCancelled == false, cards.count < Self.minimumShown, canLoadMore, moreFailure == nil {
            let page = listing?.page
            await loadMore()
            // Another read is running, or this one was cancelled: leave the
            // rest to it and to the list.
            guard listing?.page != page else { return }
        }
    }

    /// Reads the next page of the timeline on screen and appends it without
    /// the posts already listed. When the page was read at another revision
    /// than the first, the loaded pages are read again.
    func loadMore() async {
        let key = key
        guard listings[key]?.hasNext == true, loadingMoreKeys.contains(key) == false else { return }
        loadingMoreKeys.insert(key)
        defer { loadingMoreKeys.remove(key) }
        // A read of the loaded pages replaces the listing; go on from it.
        if let running = inFlight[key] {
            await running.value
        }
        for _ in 0..<Self.maximumReads {
            guard let listing = listings[key], listing.hasNext else { return }
            do {
                let page = try await loadPage(key.page(listing.page + 1))
                guard var current = listings[key] else { return }
                // The pages were read again meanwhile: read the page after
                // theirs instead.
                guard current.generation == listing.generation else { continue }
                current.append(page, id: \.post.id)
                store(current, for: key)
                moreFailures[key] = nil
                if current.isMixed {
                    await read(key)
                }
                return
            } catch is CancellationError {
                return
            } catch APIError.cancelled {
                return
            } catch {
                moreFailures[key] = error
                return
            }
        }
    }

    private func store(_ listing: ArchiveListing<PostTimelineEntry>, for key: PostTimelineKey) {
        listings[key] = listing
        setCards(cards(of: listing.items), for: key)
        // A newer revision outdates the timelines read before it.
        guard let revision = listing.revision else { return }
        for (other, earlier) in listings where other != key {
            if let earlierRevision = earlier.revision, earlierRevision < revision {
                staleKeys.insert(other)
            }
        }
    }

    private func setCards(_ cards: [PostCard], for key: PostTimelineKey) {
        loadedCards[key] = cards
        loadedSections[key] = PostTimelineSection.grouping(cards)
    }

    private func cards(of entries: [PostTimelineEntry]) -> [PostCard] {
        entries.map { entry in
            // The page's avatars win over the dashboard's for its accounts.
            let avatars = (avatarFallback.accountAvatars ?? [:]).merging(entry.accountAvatars ?? [:]) { $1 }
            return PostCard(
                post: entry.post, accountAvatars: avatars, profileAvatarURL: avatarFallback.profileAvatarURL)
        }
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
            // The picker waits for an index; the timeline does not need one.
        }
    }

    /// Reads the timeline's loaded pages again, or its first page when none
    /// is loaded. A read that starts while another of the same timeline runs
    /// waits for that one instead of sending its own.
    private func read(_ key: PostTimelineKey) async {
        if let running = inFlight[key] {
            await running.value
            return
        }
        let request = Task { await performRead(key) }
        inFlight[key] = request
        loadingKeys.insert(key)
        await request.value
        inFlight[key] = nil
        loadingKeys.remove(key)
    }

    private func performRead(_ key: PostTimelineKey) async {
        // As many pages as are loaded, so the list keeps its length and the
        // posts on screen stay.
        let pageCount = listings[key]?.page ?? 1
        do {
            var result = try await readPages(key, through: pageCount)
            var reads = 1
            while result.listing.isMixed, reads < Self.maximumReads {
                result = try await readPages(key, through: pageCount)
                reads += 1
            }
            generation += 1
            result.listing.generation = generation
            store(result.listing, for: key)
            pageCounts[key.start] = result.counts
            failures[key] = nil
            moreFailures[key] = nil
            staleKeys.remove(key)
        } catch is CancellationError {
            return
        } catch APIError.cancelled {
            return
        } catch {
            failures[key] = error
        }
        launchCopies.remove(key)
    }

    /// Reads pages 1 through `pageCount`, or until the timeline ends, into
    /// one listing, with the first page's account counts.
    private func readPages(_ key: PostTimelineKey, through pageCount: Int) async throws -> (
        listing: ArchiveListing<PostTimelineEntry>, counts: [String: Int]
    ) {
        let first = try await loadPage(key.page(1))
        var listing = ArchiveListing(firstPage: first, generation: 0)
        var next = 2
        while next <= pageCount, listing.hasNext {
            listing.append(try await loadPage(key.page(next)), id: \.post.id)
            next += 1
        }
        return (listing, first.counts)
    }
}
