import SwiftUI

/// Marks a members-only entry.
struct NowMembersChip: View {
    var body: some View {
        Label {
            Text(.Now.membersOnly)
        } icon: {
            Image(systemName: "star.fill")
                .foregroundStyle(.green)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(.green.opacity(0.15), in: .capsule)
        .labelStyle(NowCompactLabelStyle())
    }
}

#Preview {
    NowMembersChip()
}
