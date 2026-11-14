import KanoNaviComponents
import SwiftUI

/// A round button whose icon shows the chosen platform and whose menu
/// switches the shelf between all platforms and one.
struct VideoPlatformMenu: View {
    let platforms: [VideoShelfPlatform]
    @Binding var selection: VideoShelfPlatform?

    var body: some View {
        Menu {
            Picker(selection: $selection) {
                Label {
                    Text(.Archive.all)
                } icon: {
                    Image(systemName: Self.allSymbol)
                }
                .tag(VideoShelfPlatform?.none)
                ForEach(platforms) { platform in
                    Label {
                        Text(platform.name)
                    } icon: {
                        platform.logo.image
                    }
                    .tag(Optional(platform))
                }
            } label: {
                Text(.Videos.platform)
            }
            .pickerStyle(.inline)
        } label: {
            icon
        }
        .font(.subheadline)
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .accessibilityLabel(Text(.Videos.platform))
        .accessibilityValue(Text(selection?.name ?? .Archive.all))
        .accessibilityIdentifier("videos.platform")
    }

    /// The symbol for every platform.
    private static let allSymbol = "play.rectangle.on.rectangle"

    @ViewBuilder
    private var icon: some View {
        if let selection {
            selection.logo.image
        } else {
            Image(systemName: Self.allSymbol)
        }
    }
}

#Preview {
    @Previewable @State var selection: VideoShelfPlatform?
    VideoPlatformMenu(platforms: VideoShelfPlatform.allCases, selection: $selection)
}
