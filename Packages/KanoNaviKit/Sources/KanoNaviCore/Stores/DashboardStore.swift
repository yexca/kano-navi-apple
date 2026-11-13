import Foundation
import Observation

@MainActor
@Observable
public final class DashboardStore {
    private static let pollInterval: TimeInterval = 30
    private static let revalidationInterval: TimeInterval = 60
    private static let defaultStreamRetry: TimeInterval = 5
    private static let maxStreamFailures = 3
    private static let streamFallbackDuration: TimeInterval = 300
    nonisolated private static let maxPushJitter: TimeInterval = 3

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
    private let stream: (any RevisionStreamSource)?
    private let pushJitter: @Sendable () -> TimeInterval

    private var loopTask: Task<Void, Never>?
    private var sleepTask: Task<Void, Never>?
    private var streamTask: Task<Void, Never>?
    private var pushTask: Task<Void, Never>?
    private var lastRevision: Int?
    private var pushedRevision: Int?
    private var pushPending = false
    private var streamCooldownUntil: Date?
    private var nextRevisionPoll: Date?
    private var nextRevalidation: Date?
    private var transitionReloadAt: Date?
    private var refreshInFlight = false
    private var refreshWaiters: [CheckedContinuation<Void, Never>] = []
    private var lastPollError: APIError?

    public init(
        client: APIClient,
        days: Int = 7,
        clock: any RefreshClock = SystemRefreshClock(),
        stream: (any RevisionStreamSource)? = nil,
        pushJitter: (@Sendable () -> TimeInterval)? = nil
    ) {
        self.client = client
        self.request = DashboardRequest(days: days)
        self.clock = clock
        self.stream = stream
        self.pushJitter = pushJitter ?? { Double.random(in: 0...Self.maxPushJitter) }
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
        pushTask?.cancel()
        pushTask = nil
        streamTask?.cancel()
        streamTask = nil
        sleepTask?.cancel()
        sleepTask = nil
        loopTask?.cancel()
        loopTask = nil
        pushPending = false
    }

    public func refresh() async {
        if refreshInFlight {
            await withCheckedContinuation { continuation in
                refreshWaiters.append(continuation)
            }
            return
        }

        if pushTask != nil {
            pushTask?.cancel()
            pushTask = nil
            pushPending = true
        }

        refreshInFlight = true
        await performRefresh()
        refreshInFlight = false
        let waiters = refreshWaiters
        refreshWaiters.removeAll()
        for waiter in waiters {
            waiter.resume()
        }

        if pushPending {
            pushPending = false
            if let pushedRevision, lastRevision == nil || pushedRevision != lastRevision {
                schedulePushRefresh()
            }
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
        if stream == nil || isInStreamCooldown(at: launchNow) {
            nextRevisionPoll = launchNow.addingTimeInterval(Self.pollInterval)
        } else {
            nextRevisionPoll = nil
        }
        nextRevalidation = launchNow.addingTimeInterval(Self.revalidationInterval)
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
        guard Task.isCancelled == false else { return }
        startStreamIfNeeded()
        await refresh()
    }

    private func runLoop() async {
        while Task.isCancelled == false {
            let now = clock.now
            let candidates = [nextRevisionPoll, nextRevalidation, transitionReloadAt]
                .compactMap { $0 }
                .filter { $0 > now }
            let wakeAt = candidates.min() ?? now.addingTimeInterval(Self.revalidationInterval)
            guard await sleepUntil(wakeAt) else {
                return
            }

            let current = clock.now
            var shouldRefresh = false
            if let due = nextRevisionPoll, current >= due {
                nextRevisionPoll = current.addingTimeInterval(Self.pollInterval)
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
                nextRevalidation = current.addingTimeInterval(Self.revalidationInterval)
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

    private func sleepUntil(_ wakeAt: Date) async -> Bool {
        let delay = max(0, wakeAt.timeIntervalSince(clock.now))
        let waiter = Task<Void, Never> { [clock] in
            _ = try? await clock.sleep(for: .seconds(delay))
        }
        sleepTask = waiter
        await waiter.value
        if sleepTask == waiter {
            sleepTask = nil
        }
        return Task.isCancelled == false
    }

    private func wakeLoop() {
        sleepTask?.cancel()
        sleepTask = nil
    }

    private func isInStreamCooldown(at now: Date) -> Bool {
        guard let streamCooldownUntil else { return false }
        return now < streamCooldownUntil
    }

    private func startStreamIfNeeded() {
        guard stream != nil, streamTask == nil else { return }
        streamTask = Task { [weak self] in
            await self?.runStream()
        }
    }

    private func runStream() async {
        guard let stream else { return }
        var consecutiveFailures = 0
        var retryDelay = Self.defaultStreamRetry

        while Task.isCancelled == false {
            if let cooldownUntil = streamCooldownUntil {
                let remaining = cooldownUntil.timeIntervalSince(clock.now)
                if remaining > 0 {
                    do {
                        try await clock.sleep(for: .seconds(remaining))
                    } catch {
                        return
                    }
                    if Task.isCancelled {
                        return
                    }
                }
                streamCooldownUntil = nil
            }

            do {
                for try await message in stream.connect() {
                    if Task.isCancelled {
                        return
                    }
                    switch message {
                    case .retry(let milliseconds):
                        retryDelay = max(0.1, TimeInterval(milliseconds) / 1000)
                    case .revision(let revision):
                        consecutiveFailures = 0
                        nextRevisionPoll = nil
                        clearPollFailure()
                        handlePushedRevision(revision)
                    }
                }
                if Task.isCancelled {
                    return
                }
                consecutiveFailures += 1
                if consecutiveFailures >= Self.maxStreamFailures {
                    enterPollingFallback(retryAfter: nil)
                    consecutiveFailures = 0
                } else {
                    try await clock.sleep(for: .seconds(retryDelay))
                }
            } catch is CancellationError {
                return
            } catch let RevisionStreamError.unavailable(retryAfter) {
                if Task.isCancelled {
                    return
                }
                enterPollingFallback(retryAfter: retryAfter)
                consecutiveFailures = 0
            } catch {
                if Task.isCancelled {
                    return
                }
                consecutiveFailures += 1
                if consecutiveFailures >= Self.maxStreamFailures {
                    enterPollingFallback(retryAfter: nil)
                    consecutiveFailures = 0
                } else {
                    do {
                        try await clock.sleep(for: .seconds(retryDelay))
                    } catch {
                        return
                    }
                }
            }
        }
    }

    private func enterPollingFallback(retryAfter: TimeInterval?) {
        let now = clock.now
        let cooldown = max(Self.streamFallbackDuration, retryAfter ?? 0)
        streamCooldownUntil = now.addingTimeInterval(cooldown)
        if nextRevisionPoll == nil {
            nextRevisionPoll = now.addingTimeInterval(Self.pollInterval)
            wakeLoop()
        }
    }

    private func handlePushedRevision(_ revision: Int) {
        pushedRevision = revision
        if refreshInFlight {
            pushPending = true
        } else if lastRevision == nil || revision != lastRevision {
            schedulePushRefresh()
        }
    }

    private func schedulePushRefresh() {
        pushTask?.cancel()
        let delay = max(0, pushJitter())
        pushTask = Task { [weak self] in
            guard let self else { return }
            if delay > 0 {
                do {
                    try await self.clock.sleep(for: .seconds(delay))
                } catch {
                    return
                }
            }
            guard Task.isCancelled == false else { return }
            self.pushTask = nil
            await self.refresh()
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
