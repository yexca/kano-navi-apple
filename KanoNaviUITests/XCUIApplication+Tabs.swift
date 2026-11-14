import XCTest

extension XCUIApplication {
    /// The button of the tab named `label`. On iPhone it is in the tab bar;
    /// on iPad the tabs are plain buttons in the bar at the top or in the
    /// sidebar, with no tab bar around them.
    func tabButton(_ label: String) -> XCUIElement {
        buttons[label].firstMatch
    }
}
