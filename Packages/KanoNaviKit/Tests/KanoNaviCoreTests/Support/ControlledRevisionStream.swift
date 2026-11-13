import Foundation
import Synchronization

@testable import KanoNaviCore

final class ControlledRevisionStream: RevisionStreamSource, Sendable {
    enum Step: Sendable {
        case open
        case fail(any Error)
    }

    private struct State: Sendable {
        var steps: [Step]
        var connectCount = 0
        var terminatedCount = 0
        var activeContinuations: [UUID: AsyncThrowingStream<RevisionStreamMessage, any Error>.Continuation] =
            [:]
    }

    private let state: Mutex<State>

    init(steps: [Step] = [.open]) {
        state = Mutex(State(steps: steps))
    }

    var connectCount: Int {
        state.withLock { $0.connectCount }
    }

    var terminatedCount: Int {
        state.withLock { $0.terminatedCount }
    }

    var activeStreamCount: Int {
        state.withLock { $0.activeContinuations.count }
    }

    func connect() -> AsyncThrowingStream<RevisionStreamMessage, any Error> {
        let id = UUID()
        return AsyncThrowingStream { continuation in
            let step: Step = state.withLock { current in
                current.connectCount += 1
                let next = current.steps.isEmpty ? Step.open : current.steps.removeFirst()
                if case .open = next {
                    current.activeContinuations[id] = continuation
                }
                return next
            }

            continuation.onTermination = { [self] _ in
                state.withLock { current in
                    current.activeContinuations.removeValue(forKey: id)
                    current.terminatedCount += 1
                }
            }

            if case .fail(let error) = step {
                continuation.finish(throwing: error)
            }
        }
    }

    func send(_ message: RevisionStreamMessage) {
        let continuations = state.withLock { Array($0.activeContinuations.values) }
        for continuation in continuations {
            continuation.yield(message)
        }
    }

    func dropCurrent(error: (any Error)? = RevisionStreamError.disconnected) {
        let continuations = state.withLock {
            current -> [AsyncThrowingStream<RevisionStreamMessage, any Error>.Continuation] in
            let values = Array(current.activeContinuations.values)
            current.activeContinuations.removeAll()
            return values
        }
        for continuation in continuations {
            if let error {
                continuation.finish(throwing: error)
            } else {
                continuation.finish()
            }
        }
    }
}
