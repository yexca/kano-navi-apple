import KanoNaviCore
import SwiftUI
import Testing

@testable import KanoNaviComponents

#if canImport(UIKit)
    import UIKit
#endif

struct PlatformLogoTests {
    @Test func eventPlatformsWithALogoMapToIt() {
        #expect(PlatformLogo(EventPlatform.youtube) == .youtube)
        #expect(PlatformLogo(EventPlatform.bilibili) == .bilibili)
        #expect(PlatformLogo(EventPlatform.other) == nil)
        #expect(PlatformLogo(EventPlatform.unknown("twitch")) == nil)
    }

    @Test func worksPlatformsWithoutALogoMapToNil() {
        #expect(PlatformLogo(VideoPlatform.youtube) == .youtube)
        #expect(PlatformLogo(VideoPlatform.bilibili) == .bilibili)
        #expect(PlatformLogo(VideoPlatform.niconico) == nil)
    }

    #if canImport(UIKit)
        @Test(arguments: PlatformLogo.allCases)
        func logoIsASymbolInThePackage(_ logo: PlatformLogo) throws {
            let image = try #require(UIImage(named: logo.symbolName, in: .module, with: nil))
            #expect(image.isSymbolImage)
        }

        /// A button at an accessibility text size asks for the large symbol
        /// scale; a template without the scale the system needs draws nothing.
        @Test(arguments: PlatformLogo.allCases, [Image.Scale.small, .medium, .large])
        @MainActor func logoDrawsAtEveryScaleAndTextSize(_ logo: PlatformLogo, scale: Image.Scale) throws {
            for size in [DynamicTypeSize.xSmall, .large, .accessibility1, .accessibility5] {
                let view = logo.image
                    .imageScale(scale)
                    .dynamicTypeSize(size)
                    .foregroundStyle(.black)
                let renderer = ImageRenderer(content: view)
                let image = try #require(renderer.cgImage)
                #expect(Self.inkedPixels(in: image) > 0, "\(logo) at \(size) with \(scale) scale")
            }
        }

        /// The number of pixels the image draws on, read from its alpha.
        private static func inkedPixels(in image: CGImage) -> Int {
            let width = image.width
            let height = image.height
            var pixels = [UInt8](repeating: 0, count: width * height * 4)
            let drawn = pixels.withUnsafeMutableBytes { buffer in
                guard
                    let context = CGContext(
                        data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8,
                        bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
                else { return false }
                context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
                return true
            }
            guard drawn else { return 0 }
            return stride(from: 3, to: pixels.count, by: 4).count { pixels[$0] > 0 }
        }
    #endif
}
