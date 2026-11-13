import KanoNaviCore
import SwiftUI

/// The participation works as a list with a section per year.
struct WorksParticipationList: View {
    let groups: [WorksYearGroup<WorksParticipation>]
    let notice: DocumentNotice?
    let reload: () async -> Void

    var body: some View {
        List {
            if let notice {
                Section {
                    DocumentStatusNotice(notice: notice, reload: reload)
                }
            }
            ForEach(groups) { group in
                Section {
                    ForEach(group.items) { work in
                        NavigationLink(value: WorksDestination.participationWork(work.id)) {
                            WorksParticipationRow(work: work)
                        }
                        .accessibilityIdentifier("works.participation." + work.id)
                    }
                } header: {
                    WorksListYearHeader(year: group.year, count: group.items.count)
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
        WorksParticipationList(
            groups: WorksYearGroup.groups(
                of: WorksPreviewData.works.participation, order: .newestFirst, date: \.date),
            notice: nil
        ) {}
    }
    .environment(\.mediaImageLoader, WorksPreviewData.imageLoader)
}
