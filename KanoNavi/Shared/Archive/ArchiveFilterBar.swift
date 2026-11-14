import KanoNaviComponents
import SwiftUI

/// An archive's filter choices as a wrapping row of buttons, each with the
/// month's count; the selected one is prominent. `ArchiveFilterRow` puts
/// the same buttons in one row that scrolls sideways.
struct ArchiveFilterBar: View {
    let options: [ArchiveFilterOption]
    @Binding var selection: String?
    /// What the choices filter by, for VoiceOver.
    let title: LocalizedStringResource

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(options) { option in
                ArchiveFilterButton(option: option, isSelected: option.code == selection) {
                    selection = option.code
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(title))
    }
}
