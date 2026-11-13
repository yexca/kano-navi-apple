import Foundation
import Testing

@testable import KanoNavi

/// A picture is known to be there, missing or failed before it is drawn.
@MainActor
struct LineBlogPictureLoadTests {
    private let request = MediaImageFixtures.request(MediaImageFixtures.uniqueURL())

    @Test func aPictureThatLoadsIsThere() async {
        let load = LineBlogPictureLoad()
        #expect(load.phase == .waiting)

        await load.load(
            request, with: MediaImageLoader { _ in MediaImageFixtures.png(width: 40, height: 30) })

        #expect(load.phase == .loaded)
    }

    @Test func aFileTheServerDoesNotHaveIsUnavailable() async {
        let load = LineBlogPictureLoad()

        await load.load(request, with: MediaImageLoader { _ in throw MediaImageError.unavailable })

        #expect(load.phase == .unavailable)
    }

    @Test func aFailedFetchCanBeTriedAgain() async {
        let load = LineBlogPictureLoad()
        let counter = FetchCounter()
        let loader = MediaImageLoader { _ in
            await counter.increment()
            guard await counter.count > 1 else { throw MediaImageError.failed }
            return MediaImageFixtures.png(width: 40, height: 30)
        }

        await load.load(request, with: loader)
        #expect(load.phase == .failed)

        await load.load(request, with: loader)
        #expect(load.phase == .loaded)
    }

    @Test func aLoadedPictureStaysLoaded() async {
        let load = LineBlogPictureLoad()
        await load.load(
            request, with: MediaImageLoader { _ in MediaImageFixtures.png(width: 40, height: 30) })

        let other = MediaImageFixtures.request(MediaImageFixtures.uniqueURL())
        await load.load(other, with: MediaImageLoader { _ in throw MediaImageError.failed })

        #expect(load.phase == .loaded)
    }
}
