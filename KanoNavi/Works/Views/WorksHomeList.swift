import KanoNaviCore
import SwiftUI

/// The Works entry's content: the way into releases, participation and
/// uploads first, so they are in reach at any text size, then the newest
/// uploads and the works that came out on this day in past years. How
/// current the collection is sits behind the info button.
struct WorksHomeList: View {
    let works: WorksResponse
    /// The upload list, or `nil` while its read has no value.
    let uploadList: WorksUploadListResponse?
    /// The stored covers and newer videos, or `nil` while that read has no value.
    let storedUploads: WorksUploadsResponse?
    let notice: DocumentNotice?
    let reload: () async -> Void
    /// The Japan date On This Day matches; today unless a preview sets it.
    var today: JapanDate = .today

    @State private var isShowingInfo = false

    /// How many of the newest uploads the entry shows.
    private static let latestCount = 4

    var body: some View {
        let uploads = WorksUploadCard.newestFirst(list: uploadList, stored: storedUploads)
        let onThisDay = WorksOnThisDay(
            releases: works.personal, participation: works.participation, uploads: uploads, today: today)
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

            if uploads.isEmpty == false {
                Section {
                    WorksLatestUploadsShelf(cards: Array(uploads.prefix(Self.latestCount)))
                        .listRowInsets(EdgeInsets())
                } header: {
                    Text(.Works.latestUploads)
                }
            }

            if onThisDay.entries.isEmpty == false {
                Section {
                    ForEach(onThisDay.entries) { entry in
                        WorksOnThisDayRow(entry: entry)
                    }
                } header: {
                    Text(.Works.onThisDay)
                }
            }
        }
        .refreshableScreen {
            await reload()
        }
        .toolbar {
            ToolbarItem(placement: .barTrailing) {
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
        WorksHomeList(
            works: WorksPreviewData.works, uploadList: WorksPreviewData.uploadList,
            storedUploads: WorksPreviewData.uploads, notice: nil, reload: {},
            today: JapanDate(year: 2026, month: 5, day: 5))
    }
    .environment(\.mediaImageLoader, WorksPreviewData.imageLoader)
}
