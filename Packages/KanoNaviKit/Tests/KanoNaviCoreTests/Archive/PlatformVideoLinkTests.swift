import Foundation
import Testing

@testable import KanoNaviCore

struct PlatformVideoLinkTests {
    @Test func buildsWatchPagesInTheBoardsOrder() {
        let ids = PlatformVideoIDs(
            niconico: "sm100", youtube: ["yt-AAA_1"], youtubeMembers: ["ytm2"], bilibili: "BV1xx")
        let links = ids.links
        #expect(
            links.map(\.url.absoluteString) == [
                "https://www.nicovideo.jp/watch/sm100",
                "https://www.youtube.com/watch?v=yt-AAA_1",
                "https://www.youtube.com/watch?v=ytm2",
                "https://www.bilibili.com/video/BV1xx",
            ])
        #expect(links.map(\.platform) == [.niconico, .youtube, .youtube, .bilibili])
        #expect(links.map(\.isMembersOnly) == [false, false, true, false])
    }

    @Test(arguments: ["", "bad id", "a/b", "x?y=1", "ｓｍ１"])
    func rejectsIDsThatAreNotPlainPlatformIDs(id: String) {
        #expect(PlatformVideoLink(platform: .youtube, id: id) == nil)
        #expect(PlatformVideoLink.watchURL(platform: .niconico, id: id) == nil)
    }

    @Test func leavesOutAnUnusableIDAndKeepsTheRest() {
        let ids = PlatformVideoIDs(youtube: ["yt1", "bad id"], youtubeMembers: ["ytm1"], bilibili: "BV2yy")
        #expect(ids.links.map(\.id) == ["yt1", "ytm1", "BV2yy"])
    }
}
