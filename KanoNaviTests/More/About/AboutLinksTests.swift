import Foundation
import Testing

@testable import KanoNavi

@MainActor
struct AboutLinksTests {
    @Test func linksPointAtTheWebBoardRepositoriesAndLicense() throws {
        let board = try #require(AboutLinks.webBoard)
        let app = try #require(AboutLinks.appRepository)
        let license = try #require(AboutLinks.appLicense)
        let service = try #require(AboutLinks.serviceRepository)

        #expect(board.absoluteString == "https://kano.yexca.net")
        #expect(app.absoluteString == "https://github.com/yexca/kano-navi-apple")
        #expect(license.absoluteString == "https://github.com/yexca/kano-navi-apple/blob/main/LICENSE")
        #expect(service.absoluteString == "https://github.com/yexca/kano-navi")
    }
}
