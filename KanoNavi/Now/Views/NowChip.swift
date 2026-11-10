import SwiftUI

/// A neutral chip for a translated display code, such as a type or a form.
struct NowChip: View {
    let label: LocalizedStringResource

    var body: some View {
        Text(label)
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.fill.tertiary, in: .capsule)
    }
}
