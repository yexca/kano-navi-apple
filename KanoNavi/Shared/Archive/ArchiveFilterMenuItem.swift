import KanoNaviComponents
import SwiftUI

/// One choice of a filter menu: its logo when it has one, and its name with
/// its count when known, such as "@example (9)".
struct ArchiveFilterMenuItem: View {
    let option: ArchiveFilterOption

    @Environment(\.locale) private var locale

    var body: some View {
        if let logo = option.logo {
            Label {
                Text(verbatim: title)
            } icon: {
                logo.image
            }
        } else {
            Text(verbatim: title)
        }
    }

    private var title: String {
        let name = option.label.text(locale: locale)
        guard let count = option.count else { return name }
        var resource = LocalizedStringResource.Archive.filterWithCount(name, count)
        resource.locale = locale
        return String(localized: resource)
    }
}
