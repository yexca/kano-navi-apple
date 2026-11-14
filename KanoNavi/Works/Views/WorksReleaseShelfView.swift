import KanoNaviCore
import SwiftUI

/// The shelf's content: the format filter as one row that scrolls sideways,
/// then each year's releases as a grid of covers, or as rows at
/// accessibility text sizes.
struct WorksReleaseShelfView: View {
    let shelf: WorksReleaseShelf
    @Binding var format: String?
    let order: WorksOrder
    let notice: DocumentNotice?
    let reload: () async -> Void

    var body: some View {
        let groups = shelf.groups(format: format, order: order)
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                if let notice {
                    DocumentStatusNotice(notice: notice, reload: reload)
                        .padding(.horizontal)
                }
                // Full width: the row scrolls from edge to edge and insets itself.
                ArchiveFilterRow(options: shelf.options, selection: $format, title: .Works.filterFormat)
                ForEach(groups) { group in
                    WorksReleaseYearSection(group: group)
                        .padding(.horizontal)
                }
                if groups.isEmpty {
                    ContentUnavailableView {
                        Label {
                            Text(.Works.releasesEmpty)
                        } icon: {
                            Image(systemName: "opticaldisc")
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await reload()
        }
    }
}

#Preview {
    @Previewable @State var format: String?
    NavigationStack {
        WorksReleaseShelfView(
            shelf: WorksReleaseShelf(releases: WorksPreviewData.works.personal), format: $format,
            order: .newestFirst, notice: nil
        ) {}
    }
    .environment(\.mediaImageLoader, WorksPreviewData.imageLoader)
}
