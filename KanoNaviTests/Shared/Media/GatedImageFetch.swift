import Foundation

/// A stand-in for the network that answers only once its gate opens, so a
/// test can act while a fetch is in flight.
actor GatedImageFetch {
    private let data: Data
    /// Opens to let fetches answer.
    let gate = TestGate()
    /// Opens when the first fetch has started.
    let started = TestGate()
    private(set) var count = 0
    private(set) var cancelledCount = 0

    init(data: Data) {
        self.data = data
    }

    func data(from url: URL) async throws -> Data {
        count += 1
        await started.open()
        do {
            try await gate.wait()
        } catch {
            cancelledCount += 1
            throw error
        }
        return data
    }
}
