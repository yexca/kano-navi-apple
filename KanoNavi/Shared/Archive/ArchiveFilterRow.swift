import SwiftUI

/// An archive's filter choices as one row that scrolls sideways, for a
/// filter whose choices should not push the content down. The selected
/// choice is scrolled into view. `ArchiveFilterBar` wraps the same buttons
/// across lines instead.
///
/// The row scrolls across the whole space it is given and insets its first
/// and last choices by the standard margin, so give it the full width
/// rather than padding it: a screen's width in a scroll view, or a list
/// row's width with zero insets.
struct ArchiveFilterRow: View {
    let options: [ArchiveFilterOption]
    @Binding var selection: String?
    /// What the choices filter by, for VoiceOver.
    let title: LocalizedStringResource

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(options) { option in
                        ArchiveFilterButton(option: option, isSelected: option.code == selection) {
                            selection = option.code
                        }
                        .id(option.id)
                    }
                }
                // Every button takes the height of the tallest one.
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
            .scrollIndicators(.hidden)
            .onAppear {
                proxy.scrollTo(selectedID, anchor: .center)
            }
            .onChange(of: selection) {
                withAnimation {
                    proxy.scrollTo(selectedID, anchor: .center)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(title))
    }

    /// The selected choice's scroll ID, as `ArchiveFilterOption.id` gives it.
    private var selectedID: String {
        selection ?? ""
    }
}

#Preview {
    @Previewable @State var selection: String? = "f"
    ArchiveFilterRow(
        options: [ArchiveFilterOption(code: nil, label: .verbatim("All"), count: 120)]
            + "abcdefgh".map { letter in
                ArchiveFilterOption(code: String(letter), label: .verbatim("Choice \(letter)"), count: 9)
            },
        selection: $selection, title: "Filter")
}
