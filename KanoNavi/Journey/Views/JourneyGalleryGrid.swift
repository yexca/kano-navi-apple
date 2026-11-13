import KanoNaviCore
import SwiftUI

/// Every Journey image as a grid of cropped thumbnails, filtered by identity
/// and by what the image shows. A thumbnail opens the viewer over the
/// filtered images, with each one's provenance as the caption.
struct JourneyGalleryGrid: View {
    let journey: JourneyResponse
    @Binding var branch: String?
    @Binding var category: String?
    let notice: DocumentNotice?
    let reload: () async -> Void

    @ContentLocaleSetting private var contentLocale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var opened: JourneyMedia?

    var body: some View {
        let gallery = JourneyGallery(journey)
        let categories = gallery.categories(branch: branch)
        let items = gallery.items(branch: branch, category: category)
        let tileSize: CGFloat = dynamicTypeSize.isAccessibilitySize ? 150 : 104
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                JourneyListHeader(
                    branches: journey.branches, branch: $branch, counts: gallery.branchCounts,
                    total: gallery.items.count, countLabel: { .Journey.imageCount($0) }, notice: notice,
                    reload: reload)
                JourneyCategoryFilter(
                    categories: categories, total: gallery.items(branch: branch, category: nil).count,
                    selection: $category
                )
                .padding(.horizontal)

                if items.isEmpty {
                    JourneyEmptyNote(message: .Journey.galleryEmpty)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: tileSize), spacing: 4)], spacing: 4) {
                        ForEach(items) { media in
                            JourneyGalleryTile(media: media) {
                                opened = media
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                JourneyFooter(updatedAt: journey.updatedAt)
            }
        }
        .refreshable {
            await reload()
        }
        .onChange(of: branch) {
            keepCategory(in: gallery.categories(branch: branch))
        }
        // The identity may have changed while the timeline was shown.
        .onAppear {
            keepCategory(in: gallery.categories(branch: branch))
        }
        .mediaViewer(item: $opened, in: items, source: \.imageSource) { [contentLocale] media in
            Text(verbatim: media.title(in: contentLocale))
        } caption: { media in
            JourneyMediaCaption(media: media)
        }
    }

    /// Shows every image again when the chosen category has none for the new
    /// identity.
    private func keepCategory(in categories: [JourneyCategoryCount]) {
        if let category, categories.contains(where: { $0.id == category }) == false {
            self.category = nil
        }
    }
}
