import SwiftUI

/// A track's number, by default in a column that keeps titles aligned.
struct WorksTrackNumber: View {
    let number: Int
    /// Holds the width of two digits so titles line up.
    var alignsInColumn = true

    @ScaledMetric(relativeTo: .body) private var width: CGFloat = 26

    var body: some View {
        Text(number, format: .number)
            .monospacedDigit()
            .foregroundStyle(.secondary)
            .frame(minWidth: alignsInColumn ? width : nil, alignment: .trailing)
            .accessibilityLabel(Text(.Works.trackNumber(number)))
    }
}
