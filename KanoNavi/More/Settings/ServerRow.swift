import KanoNaviCore
import SwiftUI

/// One server in the server list: its name and address, and a checkmark
/// when the app reads it. Tapping it selects it.
struct ServerRow: View {
    let server: ServiceServer
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    server.nameText
                        .foregroundStyle(.primary)
                    Text(verbatim: server.displayAddress)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                }
            }
            .contentShape(.rect)
        }
        // Draws the row as a list row, not as the gray bar a Mac form gives
        // a bordered button.
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
