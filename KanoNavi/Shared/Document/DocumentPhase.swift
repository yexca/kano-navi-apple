/// Where a `DocumentModel`'s latest read stands.
nonisolated enum DocumentPhase: Equatable, Sendable {
    /// Nothing has been asked for yet.
    case idle
    /// A read is running. The model may already hold a value: the copy
    /// cached on this device, or the one read before.
    case loading
    /// The latest read ended with a value, from the service or, when the
    /// service could not be read, from the cache (`isSavedCopy`).
    case loaded
    /// The latest read failed and nothing cached could stand in; see the
    /// model's `failure`. A value read earlier stays.
    case failed
}
