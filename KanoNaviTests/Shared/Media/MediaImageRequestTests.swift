import CoreGraphics
import Foundation
import Testing

@testable import KanoNavi

/// Which copy a place on screen fetches and how large it decodes it.
struct MediaImageRequestTests {
    private let url = URL(string: "https://example.com/media/works/aaaaaaaaaaaa.jpg")!

    private func request(
        original: CGSize?, box: CGSize, scale: CGFloat = 1, mode: MediaImageRequest.Mode = .fit
    ) -> MediaImageRequest {
        MediaImageRequest(
            source: MediaImageSource(url: url, pixelSize: original), size: box, displayScale: scale,
            mode: mode)
    }

    @Test func fittedImageAsksForTheCopyCoveringItsBox() {
        let request = request(
            original: CGSize(width: 800, height: 1600), box: CGSize(width: 100, height: 200), scale: 3)

        #expect(request.url.absoluteString == "https://example.com/media/works/aaaaaaaaaaaa.jpg?w=320")
        #expect(request.originalURL == url)
        #expect(request.pixelWidth == 300)
        #expect(request.pixelHeight == 600)
    }

    @Test func croppedImageAsksForTheWidthItIsDrawnAtNotTheBoxWidth() {
        // A wide picture covering a square is drawn twice as wide as the square.
        let request = request(
            original: CGSize(width: 1600, height: 800), box: CGSize(width: 100, height: 100), scale: 2,
            mode: .fill)

        #expect(request.url.query() == "w=640")
    }

    @Test func fittedImageInATallerBoxIsLimitedByItsWidth() {
        let request = request(
            original: CGSize(width: 3000, height: 2000), box: CGSize(width: 400, height: 900))

        #expect(request.url.query() == "w=640")
    }

    @Test func unknownSizeLoadsTheOriginal() {
        let fitted = request(original: nil, box: CGSize(width: 100, height: 67), scale: 3)
        let cropped = request(original: nil, box: CGSize(width: 100, height: 100), scale: 3, mode: .fill)

        #expect(fitted.url == url)
        #expect(cropped.url == url)
        // The fitted box's height is a placeholder, so only its width counts.
        #expect(fitted.pixelHeight == 0)
        #expect(cropped.pixelHeight == 300)
    }

    @Test func sameFileAtTheSameSizeIsOneRequest() {
        let size = CGSize(width: 640, height: 640)
        let first = request(original: size, box: CGSize(width: 120, height: 120), scale: 3, mode: .fill)
        let second = request(original: size, box: CGSize(width: 120, height: 120), scale: 3, mode: .fill)
        let larger = request(original: size, box: CGSize(width: 200, height: 200), scale: 3, mode: .fill)

        #expect(first == second)
        #expect(first.cacheKey == second.cacheKey)
        #expect(first.cacheKey != larger.cacheKey)
    }

    @Test func decodesNoLargerThanTheBoxNeeds() {
        let cropped = request(original: nil, box: CGSize(width: 200, height: 200), mode: .fill)
        let fitted = request(original: nil, box: CGSize(width: 200, height: 200))
        let fittedByWidth = request(
            original: CGSize(width: 640, height: 320), box: CGSize(width: 200, height: 100))

        #expect(cropped.decodedMaxPixelSize(imageWidth: 640, imageHeight: 320) == 400)
        // Unknown shape: fitted by its width alone.
        #expect(fitted.decodedMaxPixelSize(imageWidth: 640, imageHeight: 1280) == 400)
        #expect(fittedByWidth.decodedMaxPixelSize(imageWidth: 640, imageHeight: 320) == 200)
    }

    @Test func neverEnlargesAndCapsVeryLargeFiles() {
        let small = request(original: nil, box: CGSize(width: 300, height: 300), mode: .fill)
        let huge = request(original: nil, box: CGSize(width: 20000, height: 20000), mode: .fill)

        #expect(small.decodedMaxPixelSize(imageWidth: 100, imageHeight: 50) == 100)
        #expect(
            huge.decodedMaxPixelSize(imageWidth: 10000, imageHeight: 5000)
                == MediaImageRequest.maximumPixelDimension)
    }

    @Test func sourceWithoutAPositiveSizeHasNone() {
        #expect(MediaImageSource(url: url, width: 800, height: nil).pixelSize == nil)
        #expect(MediaImageSource(url: url, width: 0, height: 600).pixelSize == nil)
        #expect(MediaImageSource(url: url, width: 800, height: 400).aspectRatio == 2)
    }
}
