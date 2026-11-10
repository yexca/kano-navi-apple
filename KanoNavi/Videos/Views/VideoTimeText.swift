import KanoNaviComponents
import SwiftUI

/// A video's time in Japan time with its date, such as `Tue, Nov 10 21:00 JST`.
struct VideoTimeText: View {
    let time: Date?

    @Environment(\.locale) private var locale

    var body: some View {
        if let time {
            Text(verbatim: JSTTimeFormat.dateTime(time, locale: locale))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}
