import CoreGraphics
import Foundation
import Testing

@testable import KanoNavi

/// An article's pictographs are loaded up front, each file once.
@MainActor
struct LineBlogPictographStoreTests {
    @Test func loadsEveryFileAndMarksTheOnesThatCannotBeShown() async {
        let good = source("good.png")
        let missing = source("missing.png")
        let loader = MediaImageLoader { url in
            guard url == good.url else { throw MediaImageError.unavailable }
            return MediaImageFixtures.png(width: 20, height: 20)
        }
        let store = LineBlogPictographStore()

        await store.load([good, missing], with: loader, displayScale: 2)

        #expect(store.images[good.url]?.width == 20)
        #expect(store.images[missing.url] == nil)
        #expect(store.unavailable == [missing.url])
    }

    @Test func aFileHeldAlreadyIsNotFetchedAgain() async {
        let pictograph = source("once.png")
        let counter = FetchCounter()
        let loader = MediaImageLoader(memoryCostLimit: 0) { _ in
            await counter.increment()
            return MediaImageFixtures.png(width: 20, height: 20)
        }
        let store = LineBlogPictographStore()

        await store.load([pictograph], with: loader, displayScale: 2)
        await store.load([pictograph], with: loader, displayScale: 2)

        #expect(await counter.count == 1)
    }

    private func source(_ name: String) -> MediaImageSource {
        MediaImageSource(url: MediaImageFixtures.uniqueURL(name), width: 20, height: 20)
    }
}
