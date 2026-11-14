import XCTest

final class ScheduleModeUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        MainActor.assumeIsolated {
            XCUIDevice.shared.appearance = .light
        }
    }

    @MainActor
    func testSwitchesAcrossAllModesInLightAppearance() throws {
        XCUIDevice.shared.appearance = .light

        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US",
            "-scheduleMode", "list",
        ]
        app.launch()

        app.selectTab("Schedule")
        XCTAssertTrue(app.buttons["Today"].waitForExistence(timeout: 5))

        for mode in ["Details", "Stacked", "Compact", "Details", "List"] {
            switchMode(to: mode, in: app)
            XCTAssertTrue(app.buttons["Today"].exists)
        }
    }

    @MainActor
    func testSwitchesModesInDarkAppearanceAtLargestAccessibilitySize() throws {
        XCUIDevice.shared.appearance = .dark

        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US",
            "-scheduleMode", "list",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL",
        ]
        app.launch()

        app.selectTab("Schedule")
        XCTAssertTrue(app.buttons["Today"].waitForExistence(timeout: 5))

        for mode in ["Details", "Stacked", "Compact", "List"] {
            switchMode(to: mode, in: app)
            XCTAssertTrue(app.buttons["Today"].exists)
        }
    }

    @MainActor
    private func switchMode(to mode: String, in app: XCUIApplication) {
        let menu = app.buttons["View"].firstMatch
        XCTAssertTrue(menu.waitForExistence(timeout: 5))
        menu.tap()

        let item = app.buttons[mode].firstMatch
        XCTAssertTrue(item.waitForExistence(timeout: 5))
        item.tap()
    }
}
