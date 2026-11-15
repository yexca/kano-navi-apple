import Foundation
import Testing

@testable import KanoNavi

@MainActor
struct NowPictureTests {
    @Test func profileViewerPagesFromTheBannerToTheAvatar() throws {
        var profile = NowProfile(dashboard: try DashboardFixture().dashboard())
        profile.bannerURL = URL(string: "https://example.com/media/profile/banner")
        profile.avatarURL = URL(string: "https://example.com/media/profile/avatar")

        let pictures = NowPicture.profile(profile)

        #expect(pictures.map(\.role) == [.banner, .avatar])
        #expect(pictures.map(\.url.lastPathComponent) == ["banner", "avatar"])
    }

    @Test func profileViewerLeavesOutAMissingImage() throws {
        var profile = NowProfile(dashboard: try DashboardFixture().dashboard())
        profile.bannerURL = nil
        profile.avatarURL = URL(string: "https://example.com/media/profile/avatar")

        #expect(NowPicture.profile(profile).map(\.role) == [.avatar])
    }
}
