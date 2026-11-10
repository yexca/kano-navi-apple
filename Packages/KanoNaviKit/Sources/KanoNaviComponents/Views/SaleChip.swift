import KanoNaviCore
import SwiftUI

/// Marks the calendar entry where a sale opens or closes, from a
/// `CalendarEntryView.saleMark`. Safe in widgets.
public struct SaleChip: View {
    private let mark: SaleMark

    /// Creates a chip for a sale mark from the API.
    public init(mark: SaleMark) {
        self.mark = mark
    }

    public var body: some View {
        ComponentChip(title: DisplayCodeLabels.saleMark(mark), systemImage: systemImage, tint: tint)
    }

    private var systemImage: String {
        switch mark {
        case .opens: "cart.badge.plus"
        case .closes: "cart.badge.minus"
        case .unknown: "cart"
        }
    }

    private var tint: Color {
        switch mark {
        case .opens: .green
        case .closes: .orange
        case .unknown: .secondary
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        SaleChip(mark: .opens)
        SaleChip(mark: .closes)
    }
}
