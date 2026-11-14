import KanoNaviComponents
import SwiftUI

/// A filter's choices as a toolbar menu: an icon that fills while a choice
/// other than All is active, and the choices as an inline picker, each with
/// its count when known, so the current one carries a checkmark.
struct ArchiveFilterMenu: View {
    let options: [ArchiveFilterOption]
    @Binding var selection: String?
    /// What the choices filter by, the menu's name for VoiceOver.
    let title: LocalizedStringResource

    @Environment(\.locale) private var locale

    var body: some View {
        Menu {
            Picker(selection: $selection) {
                ForEach(options) { option in
                    ArchiveFilterMenuItem(option: option)
                        .tag(option.code)
                }
            } label: {
                Text(title)
            }
            .pickerStyle(.inline)
        } label: {
            Label {
                Text(title)
            } icon: {
                Image(systemName: Self.symbol(isFiltered: selection != nil))
            }
        }
        .accessibilityValue(Text(verbatim: chosenName))
    }

    /// The symbol of an All choice, in this menu and in the Videos tab's
    /// platform menu.
    static let allSymbol = "square.grid.2x2"

    /// The menu's symbol: filled while a filter is active.
    static func symbol(isFiltered: Bool) -> String {
        isFiltered ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
    }

    /// The chosen option's name, as VoiceOver reads the menu's value.
    private var chosenName: String {
        options.first { $0.code == selection }.map { $0.label.text(locale: locale) } ?? ""
    }
}

#Preview {
    @Previewable @State var selection: String?
    NavigationStack {
        Text(verbatim: selection ?? "All")
            .toolbar {
                ToolbarItem(placement: .barLeading) {
                    ArchiveFilterMenu(
                        options: [
                            ArchiveFilterOption(code: nil, label: .verbatim("All"), count: 12),
                            ArchiveFilterOption(code: "a", label: .verbatim("@example"), count: 9),
                            ArchiveFilterOption(
                                code: "b", label: .verbatim("Bilibili"), logo: .bilibili, count: 3),
                        ], selection: $selection, title: "Filter")
                }
            }
    }
}
