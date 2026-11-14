import KanoNaviCore
import SwiftUI

/// The videos newer than the collection, as a list section above the
/// uploads: a few at first, the rest on request.
struct WorksRecentSection: View {
    let recent: WorksRecentUploads

    @Environment(\.locale) private var locale
    @State private var isExpanded = false

    var body: some View {
        Section {
            ForEach(recent.shown(expanded: isExpanded)) { video in
                WorksRecentRow(video: video)
            }
            if recent.collapsedCount > 0 {
                Button(action: toggle) {
                    Text(isExpanded ? .Works.recentShowFewer : .Works.recentShowMore(recent.collapsedCount))
                }
            }
        } header: {
            Text(.Works.recentTitle)
        } footer: {
            Text(.Works.recentSince(WorksDateFormat.date(recent.since, locale: locale), recent.total))
        }
    }

    private func toggle() {
        withAnimation {
            isExpanded.toggle()
        }
    }
}
