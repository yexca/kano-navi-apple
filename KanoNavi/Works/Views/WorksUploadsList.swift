import KanoNaviCore
import SwiftUI

/// The Uploads screen's content: notices, the newer videos, the kind
/// filter as one row that scrolls sideways and the uploads by year.
struct WorksUploadsList: View {
    let catalog: WorksUploadCatalog
    /// The videos newer than the collection; `nil` without any or while searching.
    let recent: WorksRecentUploads?
    @Binding var kind: String?
    let order: WorksOrder
    /// Whether a search query narrows the catalog.
    let isSearching: Bool
    let listNotice: DocumentNotice?
    /// Why the covers and newer videos are not a fresh read.
    let storedNotice: DocumentNotice?
    let reload: () async -> Void

    var body: some View {
        let groups = catalog.groups(kind: kind, order: order)
        let showsCovers = catalog.showsCovers(kind: kind)
        List {
            if listNotice != nil || storedNotice != nil {
                Section {
                    if let listNotice {
                        DocumentStatusNotice(notice: listNotice, reload: reload)
                    }
                    // One notice is enough when both reads failed: the list's
                    // says the page is not current.
                    if listNotice == nil, let storedNotice {
                        WorksStoredNotice(notice: storedNotice, reload: reload)
                    }
                }
            }

            if let recent {
                WorksRecentSection(recent: recent)
            }

            Section {
                ArchiveFilterRow(options: catalog.options, selection: $kind, title: .Works.filterKind)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
            }

            ForEach(groups) { group in
                Section {
                    ForEach(group.items) { item in
                        WorksUploadRow(item: item, showsCover: showsCovers)
                    }
                } header: {
                    WorksListYearHeader(year: group.year, count: group.items.count)
                }
            }

            if let empty = WorksUploadsEmptyState(
                isEmpty: groups.isEmpty, isSearching: isSearching, kind: kind)
            {
                Section {
                    WorksUploadsEmptyView(state: empty)
                }
            }
        }
        .refreshable {
            await reload()
        }
    }
}

#Preview {
    @Previewable @State var kind: String?
    NavigationStack {
        WorksUploadsList(
            catalog: WorksUploadCatalog(list: WorksPreviewData.uploadList, stored: WorksPreviewData.uploads),
            recent: WorksRecentUploads(WorksPreviewData.uploads),
            kind: $kind, order: .newestFirst, isSearching: false, listNotice: nil, storedNotice: .loadFailed
        ) {}
    }
    .environment(\.mediaImageLoader, WorksPreviewData.imageLoader)
}
