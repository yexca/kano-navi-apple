import XCTest

extension XCUIApplication {
    /// The button of the tab named `label`. On iPhone it is in the tab bar;
    /// on iPad the tabs are plain buttons in the bar at the top or in the
    /// sidebar, with no tab bar around them. On a narrow iPad the bar at the
    /// top can hold a tab scrolled out of view, which `selectTab(_:)` reaches.
    func tabButton(_ label: String) -> XCUIElement {
        buttons[label].firstMatch
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
