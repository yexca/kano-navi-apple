import XCTest

extension XCUIApplication {
    /// The item of the tab named `label`. On iPhone it is a button in the tab
    /// bar; on iPad a plain button in the bar at the top, or a cell in the
    /// sidebar, with no tab bar around them. On a narrow iPad the bar at the
    /// top can hold a tab scrolled out of view, which `selectTab(_:)` reaches.
    func tabButton(_ label: String) -> XCUIElement {
        descendants(matching: .any).matching(
            NSPredicate(
                format: "label == %@ AND (elementType == %d OR elementType == %d)", label,
                XCUIElement.ElementType.button.rawValue, XCUIElement.ElementType.cell.rawValue)
        ).firstMatch
    }

    /// Whether the tabs are in a sidebar, which lists More's screens as tabs
    /// of their own, rather than a tab bar with More. The sidebar's first
    /// item, Now, is a cell; in a tab bar it is a button.
    var showsTabSidebar: Bool {
        cells.matching(NSPredicate(format: "label IN %@", ["Now", "いま", "现在"])).firstMatch.exists
    }

    /// Selects the tab named `label`. A tab the bar at the top has scrolled
    /// out of view, as on an iPad mini in portrait, is chosen in the sidebar.
    func selectTab(_ label: String, file: StaticString = #filePath, line: UInt = #line) {
        let button = tabButton(label)
        XCTAssertTrue(button.waitForExistence(timeout: 10), "No tab \(label)", file: file, line: line)
        // iPhone: a tab bar always shows every tab.
        let tabBarButton = tabBars.buttons[label]
        if tabBarButton.exists {
            tabBarButton.tap()
            return
        }

        let barFrame = button.frame
        if button.isHittable, isCovered(barFrame, except: label) == false {
            button.tap()
            return
        }

        let sidebarButton = buttons["ToggleSideBar"]
        XCTAssertTrue(sidebarButton.waitForExistence(timeout: 5), "No sidebar button", file: file, line: line)
        sidebarButton.tap()
        guard let item = hittableElement(labeled: label, awayFrom: barFrame, timeout: 5) else {
            XCTFail("Tab \(label) is not in the sidebar", file: file, line: line)
            return
        }
        item.tap()
    }

    /// Opens the screen More lists as `label`: in a sidebar it is a tab of
    /// its own, in a tab bar a row of the `moreLabel` tab.
    func openMoreScreen(
        _ label: String, more moreLabel: String, file: StaticString = #filePath, line: UInt = #line
    ) {
        let sidebarItem = cells[label].firstMatch
        if sidebarItem.waitForExistence(timeout: 2), sidebarItem.isHittable {
            sidebarItem.tap()
            return
        }
        selectTab(moreLabel, file: file, line: line)
        let row = collectionViews.buttons[label].firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10), "No More row \(label)", file: file, line: line)
        row.tap()
    }

    /// Whether another button, such as the iPad bar's arrow to its next page,
    /// lies over `frame`. A tab scrolled under the arrow still reports
    /// itself hittable, but a tap there misses it.
    private func isCovered(_ frame: CGRect, except label: String) -> Bool {
        buttons.allElementsBoundByIndex.contains { other in
            other.label != label && other.frame.intersects(frame) && other.frame.contains(frame) == false
        }
    }

    /// The first element labelled `label` outside `excludedFrame` that can
    /// be tapped, once one can.
    private func hittableElement(
        labeled label: String, awayFrom excludedFrame: CGRect, timeout: TimeInterval
    ) -> XCUIElement? {
        let matches = descendants(matching: .any).matching(NSPredicate(format: "label == %@", label))
        let deadline = Date.now.addingTimeInterval(timeout)
        repeat {
            let match = matches.allElementsBoundByIndex.first { element in
                element.frame.intersects(excludedFrame) == false && element.isHittable
            }
            if let match {
                return match
            }
            RunLoop.current.run(until: Date.now.addingTimeInterval(0.25))
        } while Date.now < deadline
        return nil
    }
}
