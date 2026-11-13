import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// A single-document read through its states, against a stubbed transport
/// and a memory cache.
@MainActor
struct DocumentModelTests {
    private typealias F = DocumentFixtures
    private typealias Model = DocumentModel<F.NoteRequest>

    private func model(_ service: StubDocumentService, cache: SingleDocumentCache = SingleDocumentCache())
        throws -> Model
    {
        Model(client: try service.client(cache: cache), request: F.NoteRequest())
    }

    @Test func startsIdleWithNothingToShow() throws {
        let model = try model(StubDocumentService(.document("fresh")))

        #expect(model.phase == .idle)
        #expect(model.value == nil)
        #expect(model.notice == nil)
        #expect(model.failureReason == nil)
    }

    @Test func firstLoadReadsTheService() async throws {
        let model = try model(StubDocumentService(.document("fresh")))

        await model.load()

        #expect(model.value == F.Note(title: "fresh"))
        #expect(model.phase == .loaded)
        #expect(model.isSavedCopy == false)
        #expect(model.fetchedAt != nil)
        #expect(model.notice == nil)
    }

    @Test func cachedCopyShowsAtOnceThenTheFreshDocumentReplacesIt() async throws {
        let gate = TestGate()
        let service = StubDocumentService(.document("fresh"), gate: gate)
        let model = try model(service, cache: F.cache(holding: "cached"))

        let load = Task { await model.load() }
        try await service.arrived.wait()

        // The service has been asked and has not answered yet.
        #expect(model.value == F.Note(title: "cached"))
        #expect(model.phase == .loading)
        #expect(model.isSavedCopy == false)
        #expect(model.fetchedAt == F.cachedAt)
        #expect(model.notice == nil)

        await gate.open()
        await load.value

        #expect(model.value == F.Note(title: "fresh"))
        #expect(model.phase == .loaded)
        #expect(model.isSavedCopy == false)
        #expect(try #require(model.fetchedAt) > F.cachedAt)
        #expect(model.notice == nil)
    }

    @Test func cachedCopyStaysAndIsMarkedWhenTheServiceCannotBeRead() async throws {
        let model = try model(StubDocumentService(.offline), cache: F.cache(holding: "cached"))

        await model.load()

        #expect(model.value == F.Note(title: "cached"))
        #expect(model.phase == .loaded)
        #expect(model.isSavedCopy)
        #expect(model.fetchedAt == F.cachedAt)
        #expect(model.notice == .saved(fetchedAt: F.cachedAt))
        #expect(model.failureReason == nil)
    }

    @Test func nothingCachedAndNoServiceIsAFailedLoad() async throws {
        let model = try model(StubDocumentService(.offline))

        await model.load()

        #expect(model.value == nil)
        #expect(model.phase == .failed)
        #expect(model.notice == .loadFailed)
        #expect(model.failureReason == .offline)
        #expect(model.fetchedAt == nil)
    }

    @Test func missingDocumentReportsTheStatus() async throws {
        let model = try model(StubDocumentService(.status(404)))

        await model.load()

        #expect(model.phase == .failed)
        #expect(model.failureReason == .serverError(status: 404))
    }

    @Test func reloadAfterAFailedLoadShowsTheDocument() async throws {
        let service = StubDocumentService(.offline, .document("fresh"))
        let model = try model(service)

        await model.load()
        #expect(model.notice == .loadFailed)
        await model.reload()

        #expect(model.value == F.Note(title: "fresh"))
        #expect(model.phase == .loaded)
        #expect(model.notice == nil)
        #expect(model.failureReason == nil)
        #expect(await service.requestCount == 2)
    }

    @Test func appearingAgainAfterAFailureReadsAgain() async throws {
        let service = StubDocumentService(.offline, .document("fresh"))
        let model = try model(service)

        await model.load()
        await model.load()

        #expect(model.value == F.Note(title: "fresh"))
        #expect(await service.requestCount == 2)
    }

    @Test func failedReloadKeepsTheDocumentAsTheSavedCopy() async throws {
        let model = try model(StubDocumentService(.document("fresh"), .offline))

        await model.load()
        let firstFetch = try #require(model.fetchedAt)
        await model.reload()

        #expect(model.value == F.Note(title: "fresh"))
        #expect(model.phase == .loaded)
        #expect(model.isSavedCopy)
        // The copy is dated when the client stored it, during the first read.
        let savedAt = try #require(model.fetchedAt)
        #expect(savedAt <= firstFetch)
        #expect(model.notice == .saved(fetchedAt: savedAt))
    }

    @Test func failedReloadWithoutACachedCopyKeepsWhatWasReadBefore() async throws {
        let cache = SingleDocumentCache()
        let model = try model(StubDocumentService(.document("fresh"), .status(503)), cache: cache)

        await model.load()
        await cache.clear()
        await model.reload()

        #expect(model.value == F.Note(title: "fresh"))
        #expect(model.phase == .failed)
        #expect(model.notice == .updateFailed)
        #expect(model.failureReason == .serverError(status: 503))
    }

    @Test func savedCopyIsReplacedOnceTheServiceAnswersAgain() async throws {
        let service = StubDocumentService(.offline, .document("fresh"))
        let model = try model(service, cache: F.cache(holding: "cached"))

        await model.load()
        #expect(model.isSavedCopy)
        await model.reload()

        #expect(model.value == F.Note(title: "fresh"))
        #expect(model.isSavedCopy == false)
        #expect(model.notice == nil)
    }

    @Test func loadReadsOnceAndReloadReadsAgain() async throws {
        let service = StubDocumentService(.document("fresh"))
        let model = try model(service)

        await model.load()
        await model.load()
        #expect(await service.requestCount == 1)
        await model.reload()

        #expect(await service.requestCount == 2)
    }

    @Test func readsThatOverlapShareOneRequest() async throws {
        let gate = TestGate()
        let service = StubDocumentService(.document("fresh"), gate: gate)
        let model = try model(service)

        let first = Task { await model.load() }
        try await service.arrived.wait()
        let second = Task { await model.reload() }
        await Task.yield()
        await gate.open()
        await first.value
        await second.value

        #expect(model.value == F.Note(title: "fresh"))
        #expect(await service.requestCount == 1)
    }

    @Test func failureReasonsFollowTheClientErrors() {
        #expect(DocumentFailureReason(APIError.offline) == .offline)
        #expect(DocumentFailureReason(APIError.http(status: 500)) == .serverError(status: 500))
        #expect(DocumentFailureReason(APIError.decoding("bad")) == .unreadable)
        #expect(DocumentFailureReason(APIError.incompatible) == .updateNeeded)
        #expect(DocumentFailureReason(URLError(.badURL)) == .unreadable)
    }
}
