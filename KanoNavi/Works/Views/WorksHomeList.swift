import KanoNaviCore
import SwiftUI

/// The Works entry's content: the way into releases, participation and
/// uploads first, so they are in reach at any text size, then the newest
/// releases. How current the collection is sits behind the info button.
struct WorksHomeList: View {
    let works: WorksResponse
    let notice: DocumentNotice?
    let reload: () async -> Void

    @State private var isShowingInfo = false

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
                    destination: .releases, title: .Works.areaReleases, systemImage: "opticaldisc",
                    count: works.summary.personal, identifier: "releases")
                WorksAreaRow(
                    destination: .participation, title: .Works.areaParticipation,
                    systemImage: "person.2.wave.2", count: works.summary.participation,
                    identifier: "participation")
                WorksAreaRow(
                    destination: .uploads, title: .Works.areaUploads,
                    systemImage: "play.rectangle.on.rectangle", count: works.summary.uploads,
                    identifier: "uploads")
            } header: {
                WorksSummaryHeader(summary: works.summary)
            }

            Section {
                WorksLatestShelf(
                    releases: WorksReleaseShelf(releases: works.personal).latest(Self.latestCount)
                )
                .listRowInsets(EdgeInsets())
            } header: {
                Text(.Works.latestReleases)
            }
        }
        .refreshable {
            await reload()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(.Works.info, systemImage: "info.circle") {
                    isShowingInfo = true
                }
                .accessibilityIdentifier("works.info")
            }
        }
        .sheet(isPresented: $isShowingInfo) {
            WorksInfoSheet(updatedAt: works.updatedAt)
        }
    }
}

#Preview {
    NavigationStack {
        WorksHomeList(works: WorksPreviewData.works, notice: nil) {}
    }
    .environment(\.mediaImageLoader, WorksPreviewData.imageLoader)
}
