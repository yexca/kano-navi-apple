import KanoNaviCore
import SwiftUI

/// The Works entry's content: the way into releases, participation and
/// uploads first, so they are in reach at any text size, then the newest
/// releases, and what the collection covers.
struct WorksHomeList: View {
    let works: WorksResponse
    let notice: DocumentNotice?
    let reload: () async -> Void

    @Environment(\.locale) private var locale

    /// How many of the newest releases the entry shows.
    private static let latestCount = 8

    var body: some View {
        List {
            if let notice {
                Section {
                    DocumentStatusNotice(notice: notice, reload: reload)
                }
            }

            Section {
                WorksAreaRow(
                    destination: .releases, title: .Works.areaReleases, detail: .Works.areaReleasesDetail,
                    systemImage: "opticaldisc", count: works.summary.personal, identifier: "releases")
                WorksAreaRow(
                    destination: .participation, title: .Works.areaParticipation,
                    detail: .Works.areaParticipationDetail, systemImage: "person.2.wave.2",
                    count: works.summary.participation, identifier: "participation")
                WorksAreaRow(
                    destination: .uploads, title: .Works.areaUploads, detail: .Works.areaUploadsDetail,
                    systemImage: "play.rectangle.on.rectangle", count: works.summary.uploads,
                    identifier: "uploads")
            } header: {
                WorksSummaryHeader(summary: works.summary)
            } footer: {
                Text(.Works.summaryLead)
            }

            Section {
                WorksLatestShelf(
                    releases: WorksReleaseShelf(releases: works.personal).latest(Self.latestCount)
                )
                .listRowInsets(EdgeInsets())
            } header: {
                Text(.Works.latestReleases)
            } footer: {
                VStack(alignment: .leading, spacing: 8) {
                    Text(.Works.updatedThrough(WorksDateFormat.date(works.updatedAt, locale: locale)))
                    Text(.Works.disclaimer)
                }
            }
        }
        .refreshable {
            await reload()
        }
    }
}

#Preview {
    NavigationStack {
        WorksHomeList(works: WorksPreviewData.works, notice: nil) {}
    }
    .environment(\.mediaImageLoader, WorksPreviewData.imageLoader)
}
