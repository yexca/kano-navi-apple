import Foundation
import Observation

public enum DashboardPhase: Equatable, Sendable {
    case idle
    case loading
    case refreshing
    case failed(APIError)
}

@MainActor @Observable
public final class DashboardStore {
    public private(set) var snapshot: Dashboard?
    public private(set) var phase: DashboardPhase = .idle
    public private(set) var fetchedAt: Date?
    public private(set) var isIncompatible = false

    private let client: APIClient
    private let request: DashboardRequest
    private let clock: any RefreshClock
    private var loopTask: Task<Void, Never>?
    private var lastRevision: Int?
    private var nextRevisionPoll: Date?
    private var nextRevalidation: Date?
    private var transitionReloadAt: Date?
    private var refreshing = false

    public init(client: APIClient, days: Int = 7, clock: any RefreshClock = SystemRefreshClock()) {
        self.client = client; self.request = DashboardRequest(days: days); self.clock = clock
    }

    public func start() {
        stop()
        phase = snapshot == nil ? .loading : .refreshing
        loopTask = Task { [weak self] in
            guard let self else { return }
            await self.loadAtLaunch()
            await self.runLoop()
        }
    }

    public func stop() { loopTask?.cancel(); loopTask = nil }

    public func refresh() async {
        guard refreshing == false else { return }
        refreshing = true
        phase = snapshot == nil ? .loading : .refreshing
        do {
            let value = try await client.send(request)
            guard let projection = value.projection, projection.version == 1, value.events.allSatisfy({ $0.view != nil }), value.videos.allSatisfy({ $0.view != nil }) else { throw APIError.incompatible }
            snapshot = value; fetchedAt = clock.now; lastRevision = value.meta.revision ?? lastRevision; phase = .idle; isIncompatible = false
            transitionReloadAt = projection.nextTransitionAt
        } catch is CancellationError { phase = .failed(.cancelled) }
        catch let error as APIError { phase = .failed(error); isIncompatible = error == .incompatible }
        catch { phase = .failed(.decoding(String(describing: error))) }
        refreshing = false
    }

    private func loadAtLaunch() async {
        let cachedDate = await client.cachedFetchedAt(request)
        if let cached = await client.cached(request), cached.projection?.version == 1, cached.events.allSatisfy({ $0.view != nil }), cached.videos.allSatisfy({ $0.view != nil }) {
            snapshot = cached; fetchedAt = cachedDate; lastRevision = cached.meta.revision; transitionReloadAt = cached.projection?.nextTransitionAt; phase = .idle
        }
        await refresh()
        let now = clock.now; nextRevisionPoll = now.addingTimeInterval(30); nextRevalidation = now.addingTimeInterval(60)
    }

    private func runLoop() async {
        while Task.isCancelled == false {
            let now = clock.now
            let candidates = [nextRevisionPoll, nextRevalidation, transitionReloadAt].compactMap { $0 }.filter { $0 > now }
            let wakeAt = candidates.min() ?? now.addingTimeInterval(60)
            do { try await clock.sleep(for: .seconds(max(0, wakeAt.timeIntervalSince(now)))) } catch { return }
            if Task.isCancelled { return }
            let current = clock.now
            if let due = nextRevisionPoll, current >= due {
                nextRevisionPoll = current.addingTimeInterval(30)
                do {
                    let revision = try await client.send(RevisionRequest(since: lastRevision)).revision
                    if let lastRevision, revision != lastRevision { await refresh() }
                    self.lastRevision = revision
                } catch let error as APIError { phase = .failed(error) }
                catch { phase = .failed(.offline) }
            }
            if let due = nextRevalidation, current >= due { nextRevalidation = current.addingTimeInterval(60); await refresh() }
            if let due = transitionReloadAt, current >= due { transitionReloadAt = nil; await refresh() }
        }
    }
}
