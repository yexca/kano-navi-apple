import Foundation
import Synchronization

@testable import KanoNaviCore

final class ManualRefreshClock: RefreshClock, Sendable {
  private struct Waiter: Sendable {
    let id: UUID
    let deadline: Date
    let continuation: CheckedContinuation<Void, Error>
  }

  private struct State: Sendable {
    var now: Date
    var waiters: [Waiter] = []
  }

  private let state: Mutex<State>

  init(now: Date) {
    state = Mutex(State(now: now))
  }

  var now: Date {
    state.withLock { $0.now }
  }

  func advance(by interval: TimeInterval) {
    advance(to: now.addingTimeInterval(interval))
  }

  func advance(to date: Date) {
    let due: [CheckedContinuation<Void, Error>] = state.withLock { state in
      state.now = max(state.now, date)
      let ready = state.waiters.filter { $0.deadline <= state.now }
      state.waiters.removeAll { $0.deadline <= state.now }
      return ready.map(\.continuation)
    }
    for continuation in due {
      continuation.resume()
    }
  }

  func sleep(for duration: Duration) async throws {
    let interval =
      Double(duration.components.seconds)
      + Double(duration.components.attoseconds) / 1_000_000_000_000_000_000
    let deadline = now.addingTimeInterval(interval)
    try Task.checkCancellation()
    let id = UUID()
    try await withTaskCancellationHandler {
      try await withCheckedThrowingContinuation { continuation in
        let resumeImmediately = state.withLock { state in
          if state.now >= deadline || Task.isCancelled {
            return true
          }
          state.waiters.append(Waiter(id: id, deadline: deadline, continuation: continuation))
          return false
        }
        if resumeImmediately {
          continuation.resume()
        }
      }
    } onCancel: {
      let continuation: CheckedContinuation<Void, Error>? = state.withLock { state in
        guard let index = state.waiters.firstIndex(where: { $0.id == id }) else {
          return nil
        }
        return state.waiters.remove(at: index).continuation
      }
      continuation?.resume(throwing: CancellationError())
    }
  }
}
