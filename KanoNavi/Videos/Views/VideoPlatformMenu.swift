import KanoNaviComponents
import SwiftUI

/// The timeline's platform filter as a toolbar menu: its icon is the chosen
/// platform's logo, or the All symbol, and the platforms are an inline
/// picker, so the current one carries a checkmark.
struct VideoPlatformMenu: View {
    @Binding var selection: VideoShelfPlatform?

    var body: some View {
        Menu {
            Picker(selection: $selection) {
                Label {
                    Text(.Archive.all)
                } icon: {
                    Image(systemName: ArchiveFilterMenu.allSymbol)
                }
                .tag(VideoShelfPlatform?.none)
                ForEach(VideoShelfPlatform.allCases) { platform in
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
            Label {
                Text(.Videos.platform)
            } icon: {
                if let selection {
                    selection.logo.image
                } else {
                    Image(systemName: ArchiveFilterMenu.allSymbol)
                }
            }
        }
        .accessibilityValue(Text(selection?.name ?? .Archive.all))
        .accessibilityIdentifier("videos.platform")
    }
}

#Preview {
    @Previewable @State var selection: VideoShelfPlatform?
    NavigationStack {
        Text(verbatim: selection?.rawValue ?? "all")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VideoPlatformMenu(selection: $selection)
                }
            }
    }
}
