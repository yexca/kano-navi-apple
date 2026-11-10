import KanoNaviCore
import SwiftUI

/// The month menu's choices: each month of the index with its count, tagged
/// with its key.
struct ArchiveMonthOptions: View {
    let index: ArchiveMonthIndex

    @Environment(\.locale) private var locale

    var body: some View {
        ForEach(index.months, id: \.month) { month in
            if let key = ArchiveMonthKey(rawValue: month.month) {
                Text(.Archive.monthWithCount(key.title(locale: locale), month.total))
                    .tag(Optional(key))
            }
        }
    }
}
