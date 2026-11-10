import KanoNaviCore
import SwiftUI

/// Chooses the archive month on screen from the month index, newest first,
/// each with its number of items.
///
/// The menu draws its own label, so a long month title wraps and the row
/// grows with it at accessibility text sizes, where the title sits above the
/// chosen month.
struct ArchiveMonthPicker: View {
    let index: ArchiveMonthIndex
    @Binding var selection: ArchiveMonthKey?

    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Menu {
            Picker(selection: $selection) {
                ArchiveMonthOptions(index: index)
            } label: {
                Text(.Archive.month)
            }
            .pickerStyle(.inline)
        } label: {
            let layout =
                dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
                : AnyLayout(HStackLayout(spacing: 8))
            layout {
                Text(.Archive.month)
                    .foregroundStyle(.primary)
                if dynamicTypeSize.isAccessibilitySize == false {
                    Spacer(minLength: 0)
                }
                HStack(spacing: 4) {
                    Text(verbatim: chosenTitle)
                        .multilineTextAlignment(.leading)
                    Image(systemName: "chevron.up.chevron.down")
                        .imageScale(.small)
                        .accessibilityHidden(true)
                }
                .foregroundStyle(.tint)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        // A plain label keeps the title in the primary color; only the
        // chosen month is tinted, like a menu picker's value.
        .buttonStyle(.plain)
        .accessibilityLabel(Text(.Archive.month))
        .accessibilityValue(Text(verbatim: chosenTitle))
    }

    /// The chosen month with its count, as the menu lists it.
    private var chosenTitle: String {
        guard let selection, let month = index.month(selection) else { return "" }
        var resource = LocalizedStringResource.Archive.monthWithCount(
            selection.title(locale: locale), month.total)
        resource.locale = locale
        return String(localized: resource)
    }
}
