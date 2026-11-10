import KanoNaviCore
import SwiftUI

/// An entry's state in words, with a symbol and tint: upcoming, live, on
/// sale, done, pending, cancelled or cancellation suspected.
///
/// The live state shows a ``LiveIndicator``. Labels come from
/// `DisplayCodeLabels.eventState(_:)`, so a state the app does not know yet
/// shows a neutral label. Safe in widgets.
public struct EventStateBadge: View {
    private let state: EventState

    /// Creates a badge for the state the server decided, usually
    /// `event.displayState`.
    public init(state: EventState) {
        self.state = state
    }

    public var body: some View {
        if state == .live {
            LiveIndicator()
        } else {
            ComponentChip(
                title: DisplayCodeLabels.eventState(state), systemImage: systemImage, tint: tint)
        }
    }

    private var systemImage: String {
        switch state {
        case .upcoming: "clock"
        case .live: "dot.radiowaves.left.and.right"
        case .open: "cart"
        case .done: "checkmark"
        case .pending: "questionmark.circle"
        case .cancelled: "xmark.circle"
        case .cancellationReview: "exclamationmark.triangle"
        case .unknown: "circle.dashed"
        }
    }

    private var tint: Color {
        switch state {
        case .upcoming: .blue
        case .live: .red
        case .open: .green
        case .done, .unknown: .secondary
        case .pending, .cancellationReview: .orange
        case .cancelled: .red
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        ForEach(
            [EventState.upcoming, .live, .open, .done, .pending, .cancelled, .cancellationReview],
            id: \.rawValue
        ) { state in
            EventStateBadge(state: state)
        }
    }
}
