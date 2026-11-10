import SwiftUI

/// Stands in for the spotlight when the projection names no ticket.
struct NowEmptyTicket: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(.Now.spotlightNext)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(.Now.spotlightNoneTitle)
                .font(.title3.weight(.bold))
            Text(.Now.spotlightNoneMessage)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        NowEmptyTicket()
    }
}
