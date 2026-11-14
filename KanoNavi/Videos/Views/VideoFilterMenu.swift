import KanoNaviComponents
import SwiftUI

/// The timeline's filter as a toolbar menu: an icon that fills while a
/// filter is active, and two inline pickers, kind and platform, so each
/// current choice carries a checkmark.
struct VideoFilterMenu: View {
    @Binding var filter: VideoTimelineFilter

    @Environment(\.locale) private var locale

    var body: some View {
        Menu {
            Picker(selection: $filter.kind) {
                Text(.Archive.all)
                    .tag(VideoShelfKind?.none)
                ForEach(VideoShelfKind.allCases) { kind in
                    Text(kind.label)
                        .tag(Optional(kind))
                }
            } label: {
                Text(.Videos.kind)
            }
            .pickerStyle(.inline)

            Picker(selection: $filter.platform) {
                Text(.Archive.all)
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
                Text(.Videos.filter)
            } icon: {
                Image(systemName: ArchiveFilterMenu.symbol(isFiltered: filter.isActive))
            }
        }
        .accessibilityValue(Text(verbatim: chosen))
        .accessibilityIdentifier("videos.filter")
    }

    /// The chosen kind and platform, as VoiceOver reads the menu's value.
    private var chosen: String {
        [filter.kind?.label ?? .Archive.all, filter.platform?.name ?? .Archive.all]
            .map { resource in
                var resource = resource
                resource.locale = locale
                return String(localized: resource)
            }
            .formatted(.list(type: .and, width: .narrow).locale(locale))
    }
}

#Preview {
    @Previewable @State var filter = VideoTimelineFilter()
    NavigationStack {
        Text(verbatim: "\(filter)")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VideoFilterMenu(filter: $filter)
                }
            }
    }
}
