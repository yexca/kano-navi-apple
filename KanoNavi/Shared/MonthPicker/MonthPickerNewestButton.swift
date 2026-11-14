import SwiftUI

/// The month grid's first choice: the timeline from its newest item.
struct MonthPickerNewestButton: View {
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        if isSelected {
            button.buttonStyle(.borderedProminent)
        } else {
            button.buttonStyle(.bordered)
        }
    }

    private var button: some View {
        Button(action: action) {
            Label {
                Text(.Archive.newest)
            } icon: {
                Image(systemName: "arrow.up.to.line")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonBorderShape(.roundedRectangle(radius: 12))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("month.newest")
    }
}
