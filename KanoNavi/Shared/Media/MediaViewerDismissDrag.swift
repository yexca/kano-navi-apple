import CoreGraphics

/// A drag on the viewer that may close it: decided by its first movement,
/// so a drag that starts sideways turns the page and never closes.
nonisolated struct MediaViewerDismissDrag: Equatable, Sendable {
    private enum Direction: Sendable {
        case undecided
        case down
        case other
    }

    private var direction = Direction.undecided
    /// How far the viewer has been pulled down.
    private(set) var translation: CGFloat = 0

    /// A pull at least this far closes the viewer when the finger lifts.
    static let closeDistance: CGFloat = 120
    /// A flick heading at least this far closes it too.
    static let closePredictedDistance: CGFloat = 400

    /// Whether the viewer is being pulled down.
    var isActive: Bool { direction == .down }

    /// 0 at rest to 1 when pulled far, for fading the backdrop.
    var progress: CGFloat { min(translation / 300, 1) }

    /// Follows the finger.
    mutating func update(translation: CGSize) {
        if direction == .undecided {
            direction = translation.height > abs(translation.width) ? .down : .other
        }
        if direction == .down {
            self.translation = max(0, translation.height)
        }
    }

    /// Whether lifting the finger now closes the viewer. `predicted` is
    /// where the drag would end if it kept its speed.
    func closes(predicted: CGSize) -> Bool {
        guard isActive else { return false }
        return translation >= Self.closeDistance || predicted.height >= Self.closePredictedDistance
    }
}
