import XCTest

final class LaunchTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchShowsTabsAndSwitchesToSchedule() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        XCTAssertTrue(app.navigationBars["Now"].waitForExistence(timeout: 10))

        let tabs = app.tabBars.buttons.allElementsBoundByIndex.map(\.label)
        XCTAssertEqual(tabs, ["Now", "Schedule", "Posts", "Videos", "More"])

        app.tabBars.buttons["Schedule"].tap()
        XCTAssertTrue(app.navigationBars["Schedule"].waitForExistence(timeout: 5))
    }
}
