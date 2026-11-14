import SwiftUI

/// A post's account avatar in a circle that grows with Dynamic Type up to a
/// limit: the image, the handle's initial or a person symbol on a sunken
/// fill, or the empty fill while nothing is known. Decorative; the header
/// names the account.
struct PostAvatarView: View {
    let avatar: PostAvatar

    @ScaledMetric(relativeTo: .subheadline) private var scaledDiameter = 40

    /// The diameter, kept small enough at accessibility sizes to leave the
    /// header room.
    private var diameter: CGFloat { min(scaledDiameter, 64) }

    var body: some View {
        Circle()
            .fill(.fill.secondary)
            .overlay {
                switch avatar {
                case .image(let url):
                    MediaImage(decorative: MediaImageSource(url: url), contentMode: .fill)
                case .initial(let letter):
                    Text(verbatim: letter)
                        .font(.system(size: diameter * 0.45, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                case .symbol:
                    Image(systemName: "person.fill")
                        .font(.system(size: diameter * 0.45))
                        .foregroundStyle(.secondary)
                case .placeholder:
                    EmptyView()
                }
            }
            .frame(width: diameter, height: diameter)
            .clipShape(.circle)
            .accessibilityHidden(true)
    }
}
