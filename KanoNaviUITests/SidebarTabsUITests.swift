import XCTest

/// The iPad's sidebar lists More's screens as tabs of their own, and the
/// open screen carries over when the person switches between the sidebar
/// and the bar at the top.
final class SidebarTabsUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .pad, "The sidebar is an iPad presentation")
        XCUIDevice.shared.orientation = .landscapeLeft
    }

    @MainActor
    func testSidebarScreenCarriesOverToTheBarAtTheTop() throws {
        let app = launch()

        showSidebar(true, in: app)
        XCTAssertFalse(app.tabButton("More").exists)
        attachScreenshot(named: "sidebar-en")
        app.cells["Journey"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Journey"].waitForExistence(timeout: 5))

        showSidebar(false, in: app)
        XCTAssertTrue(app.buttons["More"].firstMatch.isSelected)
        XCTAssertTrue(app.navigationBars["Journey"].waitForExistence(timeout: 5))
        attachScreenshot(named: "top-bar-more-journey-en")

        app.navigationBars["Journey"].buttons.firstMatch.tap()
        app.collectionViews.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        showSidebar(true, in: app)
        XCTAssertTrue(app.cells["Settings"].firstMatch.isSelected)
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testNotificationSettingsLinkOpensInEitherPresentation() throws {
        let app = launch()
        let link = try XCTUnwrap(URL(string: "kanonavi://settings/notifications"))

        showSidebar(true, in: app)
        app.open(link)
        XCTAssertTrue(app.navigationBars["Notifications"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.cells["Settings"].firstMatch.isSelected)

        app.cells["Now"].firstMatch.tap()
        showSidebar(false, in: app)
        app.open(link)
        XCTAssertTrue(app.navigationBars["Notifications"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["More"].firstMatch.isSelected)
    }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        XCTAssertTrue(app.tabButton("Now").waitForExistence(timeout: 10))
        return app
    }

    /// Turns the bar at the top into the sidebar, or back.
    @MainActor
    private func showSidebar(_ shown: Bool, in app: XCUIApplication) {
        guard app.showsTabSidebar != shown else { return }
        let toggle = app.buttons.matching(
            NSPredicate(
                format:
                    "identifier == 'ToggleSideBar' OR label IN {'Toggle sidebar', 'Hide Sidebar', 'Show Sidebar'}"
            )
        ).firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 5), "No sidebar button")
        toggle.tap()
        let item = app.cells["Settings"].firstMatch
        if shown {
            XCTAssertTrue(item.waitForExistence(timeout: 5), "No sidebar")
        } else {
            XCTAssertTrue(app.buttons["More"].firstMatch.waitForExistence(timeout: 5), "No More in the bar")
        }
    }

    @MainActor
    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
