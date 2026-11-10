import SwiftUI

/// A red dot followed by the word "Live", for an entry or channel that is
/// live now. The word carries the meaning, so the state never depends on
/// color alone.
///
/// Safe in widgets: it has no interactive parts.
public struct LiveIndicator: View {
    @ScaledMetric(relativeTo: .caption) private var dotSize = 8.0

    /// Creates the indicator.
    public init() {}

    public var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(.red)
                .frame(width: dotSize, height: dotSize)
                .accessibilityHidden(true)
            Text(ComponentStrings.live)
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(.red)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    LiveIndicator()
}
