import Foundation
import Testing

@testable import KanoNavi

/// The `w` a client may ask the media route for.
struct MediaImageVariantTests {
    @Test(arguments: [
        (1, 320), (320, 320), (321, 640), (640, 640), (641, 960), (960, 960), (961, 1280), (1280, 1280),
        (1281, 1920), (1920, 1920),
    ])
    func picksTheSmallestListedWidthThatCoversThePixelsDrawn(pixelWidth: Int, expected: Int) {
        #expect(MediaImageVariant.width(pixelWidth: pixelWidth, originalWidth: 4000) == expected)
    }

    @Test func loadsTheOriginalWhenNoListedWidthCoversThePixelsDrawn() {
        #expect(MediaImageVariant.width(pixelWidth: 1921, originalWidth: 4000) == nil)
    }

    @Test(arguments: [(100, 200), (100, 319), (500, 639), (700, 800), (1300, 1919)])
    func loadsTheOriginalWhenTheCoveringWidthIsAboveTheKnownWidth(pixelWidth: Int, originalWidth: Int) {
        #expect(MediaImageVariant.width(pixelWidth: pixelWidth, originalWidth: originalWidth) == nil)
    }

    @Test(arguments: [(100, 320, 320), (500, 640, 640), (700, 960, 960), (1300, 1920, 1920)])
    func acceptsAListedWidthEqualToTheKnownWidth(pixelWidth: Int, originalWidth: Int, expected: Int) {
        #expect(MediaImageVariant.width(pixelWidth: pixelWidth, originalWidth: originalWidth) == expected)
    }

    @Test func loadsTheOriginalWhenTheWidthIsUnknown() {
        #expect(MediaImageVariant.width(pixelWidth: 100, originalWidth: nil) == nil)
        #expect(MediaImageVariant.width(drawnWidth: 100, displayScale: 3, originalWidth: nil) == nil)
    }

    @Test(arguments: [
        (130.0, 1.0, 320), (130.0, 2.0, 320), (130.0, 3.0, 640), (106.5, 3.0, 320), (107.0, 3.0, 640),
        (440.0, 3.0, 1920), (320.0, 2.0, 640),
    ])
    func countsPixelsNotPoints(drawnWidth: Double, displayScale: Double, expected: Int) {
        #expect(
            MediaImageVariant.width(drawnWidth: drawnWidth, displayScale: displayScale, originalWidth: 4000)
                == expected)
    }

    @Test func neverAsksForAnUnlistedWidth() {
        let originals: [Int?] = [nil, 1, 100, 320, 500, 640, 800, 959, 1280, 1919, 1920, 4000]
        for original in originals {
            for pixelWidth in stride(from: 1, through: 2500, by: 37) {
                guard let width = MediaImageVariant.width(pixelWidth: pixelWidth, originalWidth: original)
                else { continue }
                #expect(MediaImageVariant.widths.contains(width))
                #expect(width >= pixelWidth)
                #expect(width <= original ?? 0)
            }
        }
    }

    @Test func addsTheWidthToTheAddress() throws {
        let url = try #require(URL(string: "https://example.com/media/journey/aaaaaaaaaaaa.jpg"))

        #expect(
            MediaImageVariant.url(url, width: 640).absoluteString
                == "https://example.com/media/journey/aaaaaaaaaaaa.jpg?w=640")
        #expect(MediaImageVariant.url(url, width: nil) == url)
    }

    @Test func keepsOtherQueryItemsAndReplacesAnEarlierWidth() throws {
        let versioned = try #require(URL(string: "https://example.com/media/abc?v=123"))
        let sized = try #require(URL(string: "https://example.com/media/abc?w=320&v=123"))

        #expect(
            MediaImageVariant.url(versioned, width: 320).absoluteString
                == "https://example.com/media/abc?v=123&w=320"
        )
        #expect(
            MediaImageVariant.url(sized, width: 960).absoluteString
                == "https://example.com/media/abc?v=123&w=960")
        #expect(
            MediaImageVariant.url(sized, width: nil).absoluteString == "https://example.com/media/abc?v=123")
    }
}
