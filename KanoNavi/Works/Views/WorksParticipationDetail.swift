import KanoNaviCore
import SwiftUI

/// A participation work in full: its cover, what Kano did on it, where it
/// came out, the tracks she took part in, the whole track list and the
/// page the record follows.
struct WorksParticipationDetail: View {
    let work: WorksParticipation
    let notice: DocumentNotice?
    let reload: () async -> Void

    @ContentLocaleSetting private var contentLocale
    @Environment(\.locale) private var locale
    @State private var opened: WorksPicture?

    var body: some View {
        let contentLocale = contentLocale
        let title = work.title
        let tracks = WorksParticipationTracks(work)
        List {
            if let notice {
                Section {
                    DocumentStatusNotice(notice: notice, reload: reload)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    WorksHeroCover(image: work.cover, title: work.title, open: open)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(verbatim: work.title)
                            .font(.title2.bold())
                            .accessibilityAddTraits(.isHeader)
                        Text(verbatim: WorksDateFormat.date(work.date, locale: locale))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        WorksParticipationMarks(work: work)
                    }
                }
                .padding(.vertical, 4)
                ForEach(facts) { fact in
                    WorksFactRow(fact: fact)
                }
            }

            if tracks.separatesKanoTracks {
                Section {
                    ForEach(tracks.kano.enumerated(), id: \.offset) { _, track in
                        WorksParticipationTrackRow(
                            track: track, showsDisc: tracks.isMultiDisc, showsKanoMark: false)
                    }
                } header: {
                    Text(.Works.kanoTracks)
                }
                Section {
                    DisclosureGroup {
                        WorksParticipationTrackRows(discs: tracks.discs)
                    } label: {
                        Text(.Works.fullTrackList(tracks.total))
                    }
                }
            } else {
                Section {
                    WorksParticipationTrackRows(discs: tracks.discs)
                } header: {
                    Text(.Works.trackCount(tracks.total))
                }
            }

            if let source = work.sourceURL {
                Section {
                    WorksSourceLinkRow(url: source)
                }
            }
        }
        .readableContentWidth()
        .refreshableScreen {
            await reload()
        }
        .navigationTitle(Text(verbatim: work.title))
        .mediaViewer(item: $opened, in: gallery.pictures) { picture in
            picture.source
        } label: { picture in
            Text(verbatim: WorksImageCaption.title(of: picture.image, in: contentLocale) ?? title)
        } caption: { picture in
            WorksImageCaption(image: picture.image, fallbackTitle: title)
        }
    }

    private var gallery: WorksGallery {
        WorksGallery(images: [work.cover].compactMap(\.self))
    }

    private var facts: [WorksFact] {
        [
            WorksFact.plain(.label, work.label),
            WorksFact.plain(.event, work.event),
            WorksFact.plain(.catalog, work.catalog),
        ].compactMap(\.self)
    }

    private func open(_ image: WorksImage) {
        opened = gallery.picture(for: image)
    }
}

#Preview {
    NavigationStack {
        WorksParticipationDetail(work: WorksPreviewData.works.participation[0], notice: nil) {}
    }
    .environment(\.mediaImageLoader, WorksPreviewData.imageLoader)
}
