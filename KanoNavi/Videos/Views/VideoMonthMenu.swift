import KanoNaviCore
import SwiftUI

/// Starts the timeline at a month: a calendar button whose menu lists
/// Newest, then each month of the index, newest first with its number of
/// videos, the current choice with a checkmark.
struct VideoMonthMenu: View {
    let index: ArchiveMonthIndex
    /// The chosen month, or `nil` for the newest video.
    @Binding var selection: ArchiveMonthKey?

    @Environment(\.locale) private var locale

    var body: some View {
        Menu {
            Picker(selection: $selection) {
                Text(.Videos.newest)
                    .tag(ArchiveMonthKey?.none)
                ArchiveMonthOptions(index: index)
            } label: {
                Text(.Videos.jumpToMonth)
            }
            .pickerStyle(.inline)
        } label: {
            Label {
                Text(.Videos.jumpToMonth)
            } icon: {
                Image(systemName: "calendar")
            }
        }
        .accessibilityValue(Text(verbatim: chosen))
        .accessibilityIdentifier("videos.month")
    }

    /// The chosen month's title, or Newest, as VoiceOver reads the value.
    private var chosen: String {
        if let selection {
            return selection.title(locale: locale)
        }
        var resource = LocalizedStringResource.Videos.newest
        resource.locale = locale
        return String(localized: resource)
    }
}
