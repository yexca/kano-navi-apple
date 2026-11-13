import CoreGraphics
import Foundation
import Testing

@testable import KanoNavi

/// The decoded images kept in memory stay within their budget.
struct MediaImageMemoryCacheTests {
    private typealias F = MediaImageFixtures

    private func image(width: Int, height: Int) throws -> CGImage {
        try MediaImageDecoder.image(
            from: F.png(width: width, height: height),
            for: F.request(F.uniqueURL(), width: CGFloat(width), height: CGFloat(height)))
    }

    @Test func dropsTheLeastRecentlyUsedImageBeyondTheBudget() throws {
        let image = try image(width: 100, height: 100)
        let cost = image.bytesPerRow * image.height
        let cache = MediaImageMemoryCache(costLimit: cost * 2)
        let first = F.request(F.uniqueURL())
        let second = F.request(F.uniqueURL())
        let third = F.request(F.uniqueURL())

        cache.insert(image, for: first)
        cache.insert(image, for: second)
        // Reading the first makes the second the least recently used.
        #expect(cache.image(for: first) != nil)
        cache.insert(image, for: third)

        #expect(cache.image(for: second) == nil)
        #expect(cache.image(for: first) != nil)
        #expect(cache.image(for: third) != nil)
        #expect(cache.totalCost == cost * 2)
    }

    @Test func doesNotKeepAnImageLargerThanTheBudget() throws {
        let image = try image(width: 100, height: 100)
        let cache = MediaImageMemoryCache(costLimit: 1000)
        let request = F.request(F.uniqueURL())

        cache.insert(image, for: request)

        #expect(cache.image(for: request) == nil)
        #expect(cache.totalCost == 0)
    }

    @Test func findsTheLargestCopyOfAFileWhateverItsSize() throws {
        let url = F.uniqueURL()
        let original = CGSize(width: 2000, height: 2000)
        let thumbnail = F.request(url, width: 100, height: 100, original: original)
        let medium = F.request(url, width: 400, height: 400, original: original)
        let cache = MediaImageMemoryCache(costLimit: 10_000_000)

        #expect(cache.largestImage(of: url) == nil)
        cache.insert(try image(width: 100, height: 100), for: thumbnail)
        cache.insert(try image(width: 400, height: 400), for: medium)

        #expect(thumbnail.url != medium.url)
        #expect(cache.largestImage(of: url)?.width == 400)
        #expect(cache.largestImage(of: F.uniqueURL()) == nil)
    }

    @Test func removeAllEmptiesTheCache() throws {
        let cache = MediaImageMemoryCache(costLimit: 10_000_000)
        let request = F.request(F.uniqueURL())
        cache.insert(try image(width: 50, height: 50), for: request)

        cache.removeAll()

        #expect(cache.image(for: request) == nil)
        #expect(cache.totalCost == 0)
    }
}
