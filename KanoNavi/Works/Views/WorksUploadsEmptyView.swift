import SwiftUI

/// What the Uploads screen shows in place of rows: that the search found
/// nothing, that the chosen kind has no upload, or that the collection
/// lists none.
struct WorksUploadsEmptyView: View {
    let state: WorksUploadsEmptyState

    var body: some View {
        switch state {
        case .search:
            ContentUnavailableView.search
        case .kind:
            ContentUnavailableView {
                Label {
                    Text(.Works.uploadsEmptyKind)
                } icon: {
                    Image(systemName: "line.3.horizontal.decrease")
                }
            }
        case .list:
            ContentUnavailableView {
                Label {
                    Text(.Works.uploadsEmpty)
                } icon: {
                    Image(systemName: "play.rectangle.on.rectangle")
                }
            }
        }
    }
}
