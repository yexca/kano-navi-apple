import Foundation
import KanoNaviCore
import Observation

/// One read of the public API that is a whole document: the Journey, the
/// Works collection, the LINE BLOG index, one article or its comments.
///
///     @State private var model: DocumentModel<JourneyRequest>
///
///     init(client: APIClient) {
///         _model = State(initialValue: DocumentModel(client: client, request: JourneyRequest()))
///     }
///
///     var body: some View {
///         DocumentView(model: model) { journey in
///             List {
///                 if let notice = model.notice {
///                     Section { DocumentStatusNotice(notice: notice, reload: model.reload) }
///                 }
///                 …
///             }
///             .refreshableScreen(action: model.reload)
///         }
///     }
///
/// `load()` shows the copy cached on this device at once and then reads the
/// service. A failed read keeps what is on screen: `value` stays, and
/// `notice` says whether it is the cached copy (`isSavedCopy`, with
/// `fetchedAt`) or what was read before. With nothing to show, `phase` is
/// `.failed` and `failure` holds the error. These documents change only
/// with a server release, so nothing polls: read again with `reload()` from
/// pull to refresh and Try Again.
@Observable
final class DocumentModel<Request: APIRequest> {
    /// The document: from the service, or the cached copy.
    private(set) var value: Request.Response?
    private(set) var phase = DocumentPhase.idle
    /// `true` when the service could not be read and `value` is the copy
    /// cached on this device. `false` while the first read runs, even
    /// though `value` is the cached copy then.
    private(set) var isSavedCopy = false
    /// When `value` was read from the service.
    private(set) var fetchedAt: Date?
    /// The error of the latest read when it failed and nothing cached could
    /// stand in; cleared by the next read that ends with a value.
    private(set) var failure: (any Error)?

    let request: Request
    private let client: APIClient

    @ObservationIgnored private var inFlight: Task<Void, Never>?

    init(client: APIClient, request: Request) {
        self.client = client
        self.request = request
    }

    /// Why `value` is not a fresh read, or `nil` when it is or while the
    /// first read runs.
    var notice: DocumentNotice? {
        if phase == .failed {
            return value == nil ? .loadFailed : .updateFailed
        }
        guard isSavedCopy, let fetchedAt else { return nil }
        return .saved(fetchedAt: fetchedAt)
    }

    /// Why the latest read failed, or `nil` when it did not.
    var failureReason: DocumentFailureReason? {
        failure.map(DocumentFailureReason.init)
    }

    /// Reads the document unless a fresh one is already held: call it when
    /// the screen appears. The first call shows the cached copy while it
    /// reads.
    func load() async {
        if phase == .loaded, isSavedCopy == false { return }
        await read()
    }

    /// Reads the document again, for pull to refresh and Try Again.
    func reload() async {
        await read()
    }

    /// A read that starts while another runs waits for that one. The read
    /// is not tied to the caller's task, so a screen that goes away, or a
    /// refresh gesture SwiftUI cancels, does not turn it into a failure.
    private func read() async {
        if let running = inFlight {
            await running.value
            return
        }
        let task = Task { await performRead() }
        inFlight = task
        await task.value
        inFlight = nil
    }

    private func performRead() async {
        let previous = phase
        phase = .loading
        if value == nil, let cached = await client.cached(request) {
            value = cached
            fetchedAt = await client.cachedFetchedAt(request)
        }
        do {
            let result = try await client.readResult(request)
            value = result.value
            isSavedCopy = result.isFromCache
            fetchedAt = result.fetchedAt
            failure = nil
            phase = .loaded
        } catch APIError.cancelled {
            phase = previous
        } catch is CancellationError {
            phase = previous
        } catch {
            failure = error
            phase = .failed
        }
    }
}
