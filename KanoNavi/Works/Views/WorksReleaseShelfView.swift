import KanoNaviCore
import SwiftUI

/// The shelf's content: each year's releases as a grid of covers, or as rows
/// at accessibility text sizes, under the format filter, one row that scrolls
/// sideways pinned in the bar area so it stays while the shelf scrolls.
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
        // On the scroll view alone: around the bar, the filter row's own
        // scroll view would take a refresh control's room and hide its chips.
        .refreshableScreen {
            await reload()
        }
        .safeAreaBar(edge: .top) {
            // Full width: the row scrolls from edge to edge and insets itself.
            ArchiveFilterRow(options: shelf.options, selection: $format, title: .Works.filterFormat)
        }
        // A firm edge under the chips, so covers never show through them.
        .scrollEdgeEffectStyle(.hard, for: .top)
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
