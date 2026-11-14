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

        // In order along the tab bar, the iPad's bar at the top or its sidebar.
        let labels = ["Now", "Schedule", "Posts", "Videos", "More"]
        for label in labels {
            XCTAssertTrue(app.tabButton(label).exists, label)
        }
        let frames = Dictionary(uniqueKeysWithValues: labels.map { ($0, app.tabButton($0).frame) })
        let ordered = labels.sorted { first, second in
            let a = frames[first] ?? .zero
            let b = frames[second] ?? .zero
            return (a.minY, a.minX) < (b.minY, b.minX)
        }
        XCTAssertEqual(ordered, labels)

        app.tabButton("Schedule").tap()
        // The Schedule bar's title is the month on screen; Today is its own.
        XCTAssertTrue(app.buttons["Today"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabButton("Schedule").isSelected)
    }
}
