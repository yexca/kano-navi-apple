import XCTest

final class NotificationSettingsUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        MainActor.assumeIsolated {
            XCUIDevice.shared.appearance = .light
        }
    }

    @MainActor
    func testNotificationSettingsLightAndExpandedControls() throws {
        XCUIDevice.shared.appearance = .light

        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        openNotificationSettings(in: app)
        enableNotificationsIfNeeded(in: app)

        XCTAssertTrue(app.switches["Live Now"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.switches["Kano’s X Posts"].exists || app.switches["Kano's X Posts"].exists)
        attachScreenshot(named: "notifications-en-light-top")

        app.swipeUp()
        XCTAssertTrue(app.switches["Merchandise Sale Opens"].waitForExistence(timeout: 5))
        attachScreenshot(named: "notifications-en-light-bottom")
    }

    @MainActor
    func testNotificationSettingsDarkAndLargestAccessibilitySize() throws {
        XCUIDevice.shared.appearance = .dark

        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(zh-Hans)",
            "-AppleLocale", "zh_CN",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL",
        ]
        app.launch()

        app.tabBars.buttons.element(boundBy: 4).tap()
        let settingsButton = app.collectionViews.buttons["设置"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 10))
        settingsButton.tap()

        let notificationsButton = app.collectionViews.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "通知")
        ).firstMatch
        XCTAssertTrue(notificationsButton.waitForExistence(timeout: 5))
        notificationsButton.tap()

        let masterToggle = app.switches["启用通知"]
        XCTAssertTrue(masterToggle.waitForExistence(timeout: 5))
        if !app.switches["正在直播提醒"].exists {
            tapSwitchThumb(masterToggle)
            acceptSystemNotificationPromptIfPresent()
        }

        XCTAssertTrue(app.switches["正在直播提醒"].waitForExistence(timeout: 5))
        attachScreenshot(named: "notifications-zh-dark-ax5-top")

        app.swipeUp()
        app.swipeUp()
        attachScreenshot(named: "notifications-zh-dark-ax5-bottom")
    }

    @MainActor
    private func openNotificationSettings(in app: XCUIApplication) {
        app.tabBars.buttons["More"].tap()
        XCTAssertTrue(app.navigationBars["More"].waitForExistence(timeout: 10))

        app.collectionViews.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        let notificationsButton = app.collectionViews.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "Notifications")
        ).firstMatch
        XCTAssertTrue(notificationsButton.waitForExistence(timeout: 5))
        notificationsButton.tap()
        XCTAssertTrue(app.navigationBars["Notifications"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func enableNotificationsIfNeeded(in app: XCUIApplication) {
        let masterToggle = app.switches["Allow Notifications"]
        XCTAssertTrue(masterToggle.waitForExistence(timeout: 5))
        if !app.switches["Live Now"].exists {
            tapSwitchThumb(masterToggle)
            acceptSystemNotificationPromptIfPresent()
        }
    }

    @MainActor
    private func tapSwitchThumb(_ toggle: XCUIElement) {
        let innerSwitch = toggle.switches.firstMatch
        if innerSwitch.exists {
            innerSwitch.tap()
        } else {
            toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        }
    }

    @MainActor
    private func acceptSystemNotificationPromptIfPresent() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let alert = springboard.alerts.firstMatch
        guard alert.waitForExistence(timeout: 3) else { return }
        for label in ["Allow", "允许", "許可"] where alert.buttons[label].exists {
            alert.buttons[label].tap()
            return
        }
        if alert.buttons.count >= 2 {
            alert.buttons.element(boundBy: 1).tap()
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
