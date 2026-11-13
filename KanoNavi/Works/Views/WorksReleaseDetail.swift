import KanoNaviCore
import SwiftUI

/// A personal release in full: covers, label and catalog, tracks by disc,
/// disc photos, each edition, store bonuses and where to listen. Every
/// image opens the full-screen viewer over all of the release's pictures.
struct WorksReleaseDetail: View {
    let release: WorksRelease
    let notice: DocumentNotice?
    let reload: () async -> Void

    @ContentLocaleSetting private var contentLocale
    @State private var opened: WorksPicture?

    var body: some View {
        let locale = contentLocale
        let title = release.title
        List {
            if let notice {
                Section {
                    DocumentStatusNotice(notice: notice, reload: reload)
                }
            }

            Section {
                WorksReleaseHeader(release: release, open: open)
                ForEach(facts) { fact in
                    WorksFactRow(fact: fact)
                }
            }

            WorksReleaseTrackSection(tracks: release.tracks, hasEditions: release.editions.isEmpty == false)

            WorksImageSection(
                title: .Works.discPhotos, images: WorksGallery.discPhotos(of: release), open: open)

            ForEach(WorksEditionSummary.summaries(of: release)) { summary in
                WorksEditionSection(summary: summary, releaseTitle: release.title, open: open)
            }

            WorksStoreBonusSection(
                bonuses: release.storeBonuses, isForAnyEdition: release.editions.isEmpty == false,
                releaseTitle: release.title, open: open)

            WorksStoreSection(listings: release.stores)
        }
        .refreshable {
            await reload()
        }
        .navigationTitle(Text(verbatim: release.title))
        .mediaViewer(item: $opened, in: gallery.pictures) { picture in
            picture.source
        } label: { picture in
            Text(verbatim: WorksImageCaption.title(of: picture.image, in: locale) ?? title)
        } caption: { picture in
            WorksImageCaption(image: picture.image, fallbackTitle: title)
        }
    }

    private var gallery: WorksGallery {
        WorksGallery(release: release)
    }

    private var facts: [WorksFact] {
        [WorksFact.localized(.label, release.label), WorksFact.localized(.catalog, release.catalog)]
            .compactMap(\.self)
    }

    private func open(_ image: WorksImage) {
        opened = gallery.picture(for: image)
    }
}

#Preview {
    NavigationStack {
        WorksReleaseDetail(release: WorksPreviewData.works.personal[0], notice: nil) {}
    }
    .environment(\.mediaImageLoader, WorksPreviewData.imageLoader)
}
