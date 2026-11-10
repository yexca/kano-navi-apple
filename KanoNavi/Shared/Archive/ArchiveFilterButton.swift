import SwiftUI

/// One archive filter choice: its name and the month's count for it.
struct ArchiveFilterButton: View {
    let option: ArchiveFilterOption
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
            HStack(spacing: 4) {
                nameAndIcon
                count
            }
        }
        .font(.subheadline)
        .buttonBorderShape(.capsule)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("archive.filter." + option.id)
    }

    private var nameAndIcon: some View {
        HStack(spacing: 4) {
            if let systemImage = option.systemImage {
                Image(systemName: systemImage)
                    .accessibilityHidden(true)
            }
            name
        }
    }

    @ViewBuilder
    private var count: some View {
        if let count = option.count {
            Text(count, format: .number)
                .monospacedDigit()
                .opacity(0.75)
        }
    }

    @ViewBuilder
    private var name: some View {
        switch option.label {
        case .localized(let resource): Text(resource)
        case .verbatim(let string): Text(verbatim: string)
        }
    }
}
