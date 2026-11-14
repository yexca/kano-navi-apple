/// Reads a screen again for the View ▸ Refresh command.
///
/// A screen keeps one instance for as long as it exists and points it at
/// its current action, so the focused value the command reads stays the
/// same object and publishing it does not update the menu each time the
/// screen redraws.
@MainActor
final class ScreenRefresh {
    private var action: @MainActor () async -> Void = {}

    /// Points the refresh at `action`. Called while the screen draws, so it
    /// changes nothing that is observed.
    func update(_ action: @escaping @MainActor () async -> Void) {
        self.action = action
    }

    func callAsFunction() async {
        await action()
    }
}
