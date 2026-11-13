/// A gate a test opens to let stubbed work continue. Waiting on an open
/// gate returns at once; a waiter whose task is cancelled throws
/// `CancellationError`.
actor TestGate {
    private var isOpen = false
    private var waiters: [Int: CheckedContinuation<Void, any Error>] = [:]
    private var lastID = 0

    func open() {
        isOpen = true
        for continuation in waiters.values {
            continuation.resume()
        }
        waiters.removeAll()
    }

    func wait() async throws {
        if isOpen { return }
        try Task.checkCancellation()
        lastID += 1
        let id = lastID
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                waiters[id] = continuation
            }
        } onCancel: {
            Task { await self.cancel(id) }
        }
    }

    private func cancel(_ id: Int) {
        waiters.removeValue(forKey: id)?.resume(throwing: CancellationError())
    }
}
