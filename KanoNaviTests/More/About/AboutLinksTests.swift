import Foundation
import Testing

@testable import KanoNavi

@MainActor
struct AboutLinksTests {
    @Test func linksPointAtTheWebBoardAndRepository() throws {
        let board = try #require(AboutLinks.webBoard)
        let repository = try #require(AboutLinks.sourceRepository)

        #expect(board.absoluteString == "https://kano.yexca.net")
        #expect(repository.absoluteString == "https://github.com/yexca/kano-navi")
    }
}
