import KanoNaviCore
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
    #endif
}
