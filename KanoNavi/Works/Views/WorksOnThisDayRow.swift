import KanoNaviCore
import SwiftUI

/// One work of On This Day: its cover beside its title and how many years
/// ago it came out. A release or participation work opens its page, an
/// upload its watch page. At accessibility text sizes the cover is left
/// out so the title has the row's width.
struct WorksOnThisDayRow: View {
    let entry: WorksOnThisDay.Entry

    var body: some View {
        switch entry.work {
        case .release(let release):
            NavigationLink(value: WorksDestination.release(release.id)) {
                content
            }
        case .participation(let work):
            NavigationLink(value: WorksDestination.participationWork(work.id)) {
                content
            }
        case .upload(let card):
            WorksUploadWatchButton(card: card) {
                content
            }
            .foregroundStyle(.primary)
        }
    }

    private var content: some View {
        WorksOnThisDayLabel(entry: entry)
            .accessibilityIdentifier("works.onThisDay." + entry.id)
    }
}
