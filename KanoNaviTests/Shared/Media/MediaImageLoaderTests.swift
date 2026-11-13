import CoreGraphics
import Foundation
import Testing

@testable import KanoNavi

/// The loader against a stubbed media route (`StubMediaProtocol`) and, for
/// what happens while a fetch is in flight, a gated stand-in for the
/// network. Nothing leaves the process.
struct MediaImageLoaderTests {
    private typealias F = MediaImageFixtures

    private let server = StubMediaServer.shared
    private let notFound = Data(#"{"error":"media_not_found"}"#.utf8)

    private func loader() -> MediaImageLoader {
        MediaImageLoader(session: StubMediaServer.session())
    }

    @Test func loadsAndDownsamplesToTheSizeDrawn() async throws {
        let url = F.uniqueURL()
        server.stub(url, .response(status: 200, body: F.png(width: 400, height: 200)))

        let image = try await loader().image(for: F.request(url, width: 100, height: 50))

        #expect(image.width == 100)
        #expect(image.height == 50)
        #expect(server.requests(to: url).first?.value(forHTTPHeaderField: "Accept") == "image/*")
    }

    @Test func fetchesTheCopyTheRequestNames() async throws {
        let url = F.uniqueURL()
        let request = F.request(url, width: 300, height: 150, original: CGSize(width: 800, height: 400))
        server.stub(request.url, .response(status: 200, body: F.png(width: 320, height: 160)))

        let image = try await loader().image(for: request)

        #expect(request.url.query() == "w=320")
        #expect(image.width == 300)
        #expect(server.requests(to: request.url).count == 1)
        #expect(server.requests(to: url).isEmpty)
    }

    @Test func missingFileIsUnavailable() async {
        let url = F.uniqueURL()
        server.stub(url, .response(status: 404, body: notFound))

        await #expect(throws: MediaImageError.unavailable) {
            try await loader().image(for: F.request(url))
        }
    }

    @Test func bytesThatAreNotAnImageAreUnavailable() async {
        let url = F.uniqueURL()
        server.stub(url, .response(status: 200, body: Data("not an image".utf8)))

        await #expect(throws: MediaImageError.unavailable) {
            try await loader().image(for: F.request(url))
        }
    }

    @Test(arguments: [500, 503, 429])
    func serverErrorCanBeTriedAgain(status: Int) async {
        let url = F.uniqueURL()
        server.stub(url, .response(status: status, body: Data()))

        await #expect(throws: MediaImageError.failed) {
            try await loader().image(for: F.request(url))
        }
    }

    @Test func failedFetchSucceedsWhenTriedAgain() async throws {
        let url = F.uniqueURL()
        server.stub(
            url, .failure(.networkConnectionLost), .response(status: 200, body: F.png(width: 64, height: 64)))
        let loader = loader()
        let request = F.request(url)

        await #expect(throws: MediaImageError.failed) {
            try await loader.image(for: request)
        }
        let image = try await loader.image(for: request)

        #expect(image.width == 64)
        #expect(server.requests(to: url).count == 2)
    }

    @Test func loadedImageIsServedFromMemory() async throws {
        let url = F.uniqueURL()
        server.stub(url, .response(status: 200, body: F.png(width: 64, height: 64)))
        let loader = loader()
        let request = F.request(url)

        let first = try await loader.image(for: request)
        let second = try await loader.image(for: request)

        #expect(first === second)
        #expect(loader.memory.image(for: request) === first)
        #expect(server.requests(to: url).count == 1)
    }

    @Test func addressThatIsNotHTTPSIsNeverFetched() async throws {
        let url = try #require(URL(string: "http://example.com/media/journey/\(UUID().uuidString).png"))

        await #expect(throws: MediaImageError.unavailable) {
            try await loader().image(for: F.request(url))
        }
        #expect(server.requests(to: url).isEmpty)
    }

    @Test func waitersOfTheSameRequestShareOneFetch() async throws {
        let fetch = GatedImageFetch(data: F.png(width: 64, height: 64))
        let loader = MediaImageLoader { url in try await fetch.data(from: url) }
        let request = F.request(F.uniqueURL())

        async let first = loader.image(for: request)
        try await fetch.started.wait()
        async let second = loader.image(for: request)
        while await loader.waiterCount(for: request) < 2 {
            await Task.yield()
        }
        await fetch.gate.open()
        let images = try await (first, second)

        #expect(images.0 === images.1)
        #expect(await fetch.count == 1)
        #expect(await loader.waiterCount(for: request) == 0)
    }

    @Test func cancellingTheOnlyWaiterStopsTheFetch() async throws {
        let fetch = GatedImageFetch(data: F.png(width: 64, height: 64))
        let loader = MediaImageLoader { url in try await fetch.data(from: url) }
        let request = F.request(F.uniqueURL())

        let load = Task { try await loader.image(for: request) }
        try await fetch.started.wait()
        load.cancel()

        await #expect(throws: CancellationError.self) {
            try await load.value
        }
        #expect(await fetch.cancelledCount == 1)
        #expect(await loader.waiterCount(for: request) == 0)
        #expect(loader.memory.image(for: request) == nil)

        // The next view to ask starts a fetch of its own.
        await fetch.gate.open()
        let image = try await loader.image(for: request)
        #expect(image.width == 64)
        #expect(await fetch.count == 2)
    }

    @Test func cancellingOneWaiterLeavesTheFetchForTheOthers() async throws {
        let fetch = GatedImageFetch(data: F.png(width: 64, height: 64))
        let loader = MediaImageLoader { url in try await fetch.data(from: url) }
        let request = F.request(F.uniqueURL())

        let cancelled = Task { try await loader.image(for: request) }
        try await fetch.started.wait()
        let kept = Task { try await loader.image(for: request) }
        while await loader.waiterCount(for: request) < 2 {
            await Task.yield()
        }
        cancelled.cancel()
        while await loader.waiterCount(for: request) > 1 {
            await Task.yield()
        }
        await fetch.gate.open()

        let image = try await kept.value
        #expect(image.width == 64)
        await #expect(throws: CancellationError.self) {
            try await cancelled.value
        }
        #expect(await fetch.count == 1)
        #expect(await fetch.cancelledCount == 0)
    }
}
