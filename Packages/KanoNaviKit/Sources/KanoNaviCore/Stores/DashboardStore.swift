import Foundation
import Observation

@MainActor
@Observable
public final class DashboardStore {
    public private(set) var snapshot: Dashboard?
    public private(set) var phase: DashboardPhase = .idle
    /// When `snapshot` was fetched from the service.
    public private(set) var fetchedAt: Date?
    /// Where `snapshot` came from, or `nil` before there is one. A failed
    /// refresh leaves it unchanged, so `.cache` with a `.failed` phase means
    /// the screen shows cached data because the refresh failed.
    public private(set) var source: DashboardSource?
    public private(set) var isIncompatible = false

    private let client: APIClient
    private let request: DashboardRequest
    private let clock: any RefreshClock
    private var loopTask: Task<Void, Never>?
    private var lastRevision: Int?
    private var nextRevisionPoll: Date?
    private var nextRevalidation: Date?
    private var transitionReloadAt: Date?
    private var refreshInFlight = false
    private var refreshWaiters: [CheckedContinuation<Void, Never>] = []
    private var lastPollError: APIError?

    public init(
        client: APIClient,
        days: Int = 7,
        clock: any RefreshClock = SystemRefreshClock()
    ) {
        self.client = client
        self.request = DashboardRequest(days: days)
        self.clock = clock
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

    public func stop() {
        loopTask?.cancel()
        loopTask = nil
    }

    public func refresh() async {
        if refreshInFlight {
            await withCheckedContinuation { continuation in
                refreshWaiters.append(continuation)
            }
            return
        }

        refreshInFlight = true
        await performRefresh()
        refreshInFlight = false
        let waiters = refreshWaiters
        refreshWaiters.removeAll()
        for waiter in waiters {
            waiter.resume()
        }
    }

    private func performRefresh() async {
        let previousPhase = phase
        phase = snapshot == nil ? .loading : .refreshing
        do {
            let value = try await client.send(request)
            snapshot = value
            fetchedAt = clock.now
            source = .network
            lastRevision = value.meta.revision ?? lastRevision
            transitionReloadAt = value.projection?.nextTransitionAt.flatMap { transition in
                transition > clock.now ? transition : nil
            }
            phase = .idle
            isIncompatible = false
            lastPollError = nil
        } catch is CancellationError {
            phase = previousPhase
        } catch let error as APIError {
            if error == .cancelled {
                phase = previousPhase
            } else {
                phase = .failed(error)
                isIncompatible = error == .incompatible
            }
        } catch {
            phase = .failed(.decoding(String(describing: error)))
        }
    }

    private func loadAtLaunch() async {
        let launchNow = clock.now
        nextRevisionPoll = launchNow.addingTimeInterval(30)
        nextRevalidation = launchNow.addingTimeInterval(60)
        if let cached = await client.cachedValue(request) {
            snapshot = cached.value
            fetchedAt = cached.fetchedAt
            source = .cache
            lastRevision = cached.value.meta.revision
            transitionReloadAt = cached.value.projection?.nextTransitionAt.flatMap { transition in
                transition > clock.now ? transition : nil
            }
            phase = .idle
        }
        await refresh()
    }

    private func runLoop() async {
        while Task.isCancelled == false {
            let now = clock.now
            let candidates = [nextRevisionPoll, nextRevalidation, transitionReloadAt]
                .compactMap { $0 }
                .filter { $0 > now }
            let wakeAt = candidates.min() ?? now.addingTimeInterval(60)
            do {
                try await clock.sleep(for: .seconds(max(0, wakeAt.timeIntervalSince(now))))
            } catch {
                return
            }
            if Task.isCancelled {
                return
            }

            let current = clock.now
            var shouldRefresh = false
            if let due = nextRevisionPoll, current >= due {
                nextRevisionPoll = current.addingTimeInterval(30)
                do {
                    let revision = try await client.send(RevisionRequest(since: lastRevision)).revision
                    if let lastRevision, revision != lastRevision {
                        shouldRefresh = true
                    }
                    self.lastRevision = revision
                    clearPollFailure()
                } catch let error as APIError where error == .cancelled {
                    return
                } catch is CancellationError {
                    return
                } catch let error as APIError {
                    recordPollFailure(error)
                } catch {
                    recordPollFailure(.offline)
                }
            }
            if let due = nextRevalidation, current >= due {
                nextRevalidation = current.addingTimeInterval(60)
                shouldRefresh = true
            }
            if let due = transitionReloadAt, current >= due {
                transitionReloadAt = nil
                shouldRefresh = true
            }
            if shouldRefresh {
                await refresh()
            }
        }
    }

    private func recordPollFailure(_ error: APIError) {
        guard lastPollError != error else { return }
        lastPollError = error
        phase = .failed(error)
    }

    private func clearPollFailure() {
        guard let lastPollError else { return }
        if phase == .failed(lastPollError) {
            phase = .idle
        }
        self.lastPollError = nil
    }
}
