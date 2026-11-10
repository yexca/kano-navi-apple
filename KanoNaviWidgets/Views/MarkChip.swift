import SwiftUI

/// A small capsule holding one qualifying word, such as "Members".
struct MarkChip: View {
    let label: LocalizedStringResource

    var body: some View {
        Text(label)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(.quaternary, in: .capsule)
    }
}
