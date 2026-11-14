import SwiftUI

/// The timeline's kind filter as a toolbar menu: the filter icon, filled
/// while a kind is chosen, and the kinds as an inline picker, so the current
/// one carries a checkmark.
struct VideoKindMenu: View {
    @Binding var selection: VideoShelfKind?

    var body: some View {
        Menu {
            Picker(selection: $selection) {
                Label {
                    Text(.Archive.all)
                } icon: {
                    Image(systemName: ArchiveFilterMenu.allSymbol)
                }
                .tag(VideoShelfKind?.none)
                ForEach(VideoShelfKind.allCases) { kind in
                    Label {
                        Text(kind.label)
                    } icon: {
                        Image(systemName: kind.symbol)
                    }
                    .tag(Optional(kind))
                }
            } label: {
                Text(.Videos.kind)
            }
            .pickerStyle(.inline)
        } label: {
            Label {
                Text(.Videos.kind)
            } icon: {
                Image(systemName: ArchiveFilterMenu.symbol(isFiltered: selection != nil))
            }
        }
        .accessibilityValue(Text(selection?.label ?? .Archive.all))
        .accessibilityIdentifier("videos.kind")
    }
}

#Preview {
    @Previewable @State var selection: VideoShelfKind?
    NavigationStack {
        Text(verbatim: selection?.rawValue ?? "all")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VideoKindMenu(selection: $selection)
                }
            }
    }
}
